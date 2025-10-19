import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScanResult {
  final String imageData;
  final String plantName;
  final String condition;
  final List<String> preventiveMeasures;
  final DateTime timestamp;
  final double confidence;

  ScanResult({
    required this.imageData,
    required this.plantName,
    required this.condition,
    required this.preventiveMeasures,
    required this.timestamp,
    required this.confidence,
  });

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      imageData: json['imageData'] as String,
      plantName: json['plantName'] as String,
      condition: json['condition'] as String,
      preventiveMeasures: (json['preventiveMeasures'] as List).cast<String>(),
      timestamp: DateTime.parse(json['timestamp']),
      confidence: json['confidence'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageData': imageData,
      'plantName': plantName,
      'condition': condition,
      'preventiveMeasures': preventiveMeasures,
      'timestamp': timestamp.toIso8601String(),
      'confidence': confidence,
    };
  }
}


class MyCropDetection extends StatefulWidget {
  const MyCropDetection({super.key});

  @override
  State<MyCropDetection> createState() => _MyCropDetectionState();
}

class _MyCropDetectionState extends State<MyCropDetection> {
  final String _apiKey = 'MY_GEMINI_API_KEY';
  final String _apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-05-20:generateContent?key=';

  File? _selectedImage;
  Uint8List? _selectedImageBytes;
  String _initialMessage = 'Select an image to detect a plant disease.';
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  List<ScanResult> _recentScans = [];
  ScanResult? _currentScanResult;
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _loadRecentScans();
  }

  Future<void> _loadRecentScans() async {
    _prefs = await SharedPreferences.getInstance();
    final scansString = _prefs.getStringList('recentScans') ?? [];
    if (scansString.isNotEmpty) {
      setState(() {
        _recentScans = scansString
            .map((e) => ScanResult.fromJson(jsonDecode(e)))
            .toList();
      });
    }
  }

  Future<void> _saveScanResult(ScanResult newScan) async {
    final updatedScans = [newScan, ..._recentScans];
    final scansToSave = updatedScans.take(2).toList();
    final scansString = scansToSave.map((e) => jsonEncode(e.toJson())).toList();
    await _prefs.setStringList('recentScans', scansString);
    setState(() {
      _recentScans = scansToSave;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        if (!kIsWeb) {
          _selectedImage = File(pickedFile.path);
        }
        _currentScanResult = null;
        _isLoading = true;
        _initialMessage = 'Analyzing...';
      });
      _selectedImageBytes = await pickedFile.readAsBytes();
      await _detectDisease(pickedFile);
    }
  }

  Future<void> _detectDisease(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final promptText = """
        Analyze this image of a plant leaf and provide a disease diagnosis.
        Return the result as a single JSON object with the following structure:
        {
          "plantName": "The common name of the plant/crop",
          "condition": "Healthy" or "Disease Name",
          "preventiveMeasures": ["A list of actionable steps for treatment or prevention"],
          "confidence": "A numerical confidence score as a percentage (e.g., 95.5)"
        }
        If the plant appears healthy, set the condition to "Healthy" and the preventiveMeasures list to an empty array.
        Do not include any extra text outside the JSON object.
      """;

      final payload = {
        "contents": [
          {
            "parts": [
              {"text": promptText},
              {
                "inlineData": {
                  "mimeType": imageFile.mimeType ?? 'image/jpeg',
                  "data": base64Image,
                },
              },
            ],
          },
        ],
      };

      final response = await http.post(
        Uri.parse('$_apiUrl$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final generatedText =
            jsonResponse['candidates'][0]['content']['parts'][0]['text'];

        final startIndex = generatedText.indexOf('{');
        final endIndex = generatedText.lastIndexOf('}');

        if (startIndex != -1 && endIndex != -1) {
          final jsonString = generatedText.substring(startIndex, endIndex + 1);
          final parsedJson = jsonDecode(jsonString);

          final tempConfidence =
              double.tryParse(
                parsedJson['confidence'].toString().replaceAll('%', '').trim(),
              ) ??
              0.0;

          final newScan = ScanResult(
            imageData: base64Image,
            plantName: parsedJson['plantName'] as String,
            condition: parsedJson['condition'] as String,
            preventiveMeasures: (parsedJson['preventiveMeasures'] as List)
                .cast<String>(),
            timestamp: DateTime.now(),
            confidence: tempConfidence,
          );

          setState(() {
            _currentScanResult = newScan;
          });

          await _saveScanResult(newScan);
        } else {
          setState(() {
            _initialMessage =
                'Error: The API response did not contain valid JSON. Please try again with a clearer image.';
          });
        }
      } else {
        setState(() {
          _initialMessage =
              'Error: API call failed with status code ${response.statusCode}. Please check your API key and network connection.';
        });
      }
    } catch (e) {
      setState(() {
        _initialMessage = 'Error: An exception occurred. $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _timeAgo(DateTime timestamp) {
    Duration difference = DateTime.now().difference(timestamp);
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'just now';
    }
  }

  Widget _buildCurrentScanDisplay(ScanResult result) {
    Color conditionColor = result.condition.toLowerCase() == 'healthy'
        ? Colors.green
        : Colors.red;

    return _glassCard(
      child: Column(
        children: [
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),

              child: Image.memory(
                base64Decode(result.imageData),
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Plant Name:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(result.plantName, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),
                  Text(
                    'Condition:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    result.condition,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: conditionColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (result.preventiveMeasures.isNotEmpty)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Preventive Measures:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...result.preventiveMeasures.map(
                      (measure) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              color: Colors.green,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                measure,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _glassCard({required Widget child, double borderRadius = 20}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.25),
                Colors.white.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Farming App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text(
            'Plant Detection',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.transparent,
          centerTitle: true,
          elevation: 0,
        ),
        body: Stack(
          children: [
            // Background
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/bg.jpg'),
                  fit: BoxFit.cover,
                  //image: NetworkImage( 'https://images.unsplash.com/photo-1497250681960-ef046c08a56e?fm=jpg&q=60&w=3000&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Nnx8Z3JlZW4lMjBuYXR1cmV8ZW58MHx8MHx8fDA%3D', ), fit: BoxFit.cover,
                ),
              ),
            ),
            //  📜 Foreground Content
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 85),
                  //   Scan Card
                  _glassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            'Scan Plant Health',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Take a photo of your plant \nto detect diseases and get instant recommendations',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 16),
                          //  Buttons
                          ElevatedButton.icon(
                            onPressed: _isLoading
                                ? null
                                : () => _pickImage(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Take Photo '),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.withOpacity(0.85),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: _isLoading
                                ? null
                                : () => _pickImage(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Choose from Gallery '),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(
                                color: Colors.white.withOpacity(0.6),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                          SizedBox(height: 10),
                          if (_isLoading) ...[
                            const SizedBox(height: 24),
                            const CircularProgressIndicator(
                              color: Colors.green,
                            ),
                          ],
                          if (_currentScanResult != null)
                            _buildCurrentScanDisplay(_currentScanResult!),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  //   Recent Scans
                  if (_recentScans.isNotEmpty) ...[
                    Text(
                      'Recent Scans',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ..._recentScans.map(
                      (scan) => _glassCard(
                        borderRadius: 16,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  base64Decode(scan.imageData),
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      scan.condition,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            scan.condition.toLowerCase() ==
                                                'healthy'
                                            ? Colors.greenAccent
                                            : Colors.redAccent,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${scan.confidence.toStringAsFixed(0)}% confidence',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    _timeAgo(scan.timestamp),
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (scan.condition.toLowerCase() != 'healthy')
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.25),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'High',
                                        style: TextStyle(
                                          color: Colors.redAccent,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  //  Photography Tips
                  _glassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                color: Colors.yellowAccent,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Photography Tips',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Text(
                            '✓ Ensure good lighting conditions',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '✓ Focus on affected areas clearly',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '✓ Use a solid background for contrast',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
