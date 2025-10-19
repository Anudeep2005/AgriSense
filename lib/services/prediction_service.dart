
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'firebase_service.dart';

class PredictionService {
  static const String _apiKey = "MY_GEMINI_API_KEY";
  static const String _geminiApiUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key=$_apiKey";

  static Future<void> generateAndStorePrediction() async {
    try {
      print('Starting prediction generation...');

      final combinedData = await FirebaseService.preparePredictionPayload();
      
      if (combinedData.containsKey('error')) {
        throw Exception('Failed to prepare data: ${combinedData['error']}');
      }

      print('Data prepared for analysis');

      final prompt = _buildAnalysisPrompt(combinedData);
      final prediction = await _callGeminiAPI(prompt);
      await FirebaseService.storePrediction(prediction);
      
      print('Prediction generated and stored successfully');

    } catch (e, stackTrace) {
      print('🚨 PredictionService error: $e');
      print('Stack trace: $stackTrace');
      await _storeErrorPrediction(e.toString());
      rethrow;
    }
  }

  static String _buildAnalysisPrompt(Map<String, dynamic> data) {
    final farmData = data['farm_sensors'];
    final weatherData = data['weather_data'];
    final forecast = data['forecast_data'];
    
    final temperature = farmData?['temperature'] ?? 'N/A';
    final humidity = farmData?['humidity'] ?? 'N/A';
    final rainLevel = farmData?['rain'] ?? 'N/A';
    final soilMoisture = farmData?['soilMoisture'] ?? 'N/A';
    final lightLevel = farmData?['ldr'] ?? 'N/A';
    
    final weatherTemp = weatherData?['temperature'] ?? 'N/A';
    final weatherHumidity = weatherData?['humidity'] ?? 'N/A';
    final weatherDescription = weatherData?['description'] ?? 'N/A';
    final windSpeed = weatherData?['wind_speed'] ?? 'N/A';
    final pressure = weatherData?['pressure'] ?? 'N/A';

    String forecastSummary = 'No forecast available';
    if (forecast != null && forecast is List && forecast.isNotEmpty) {
      forecastSummary = '5-DAY WEATHER FORECAST:\n';
      for (var day in forecast) {
        forecastSummary += '- ${day['day']} (${day['date']}): ${day['temp']}°C, ${day['description']}, Rain chance: ${day['rain_chance']}%\n';
      }
    }

    return '''
You are an expert agricultural advisor AI. Analyze farm sensor data, current weather, and 5-day forecast to provide farming recommendations.

CURRENT FARM SENSOR DATA:
- Temperature: ${temperature}°C
- Humidity: ${humidity}%
- Rain Sensor: ${rainLevel} (4095 = no rain, lower = rain)
- Soil Moisture: ${soilMoisture}%
- Light Level: ${lightLevel}

CURRENT WEATHER:
- Conditions: ${weatherDescription}
- Temperature: ${weatherTemp}°C
- Humidity: ${weatherHumidity}%
- Wind Speed: ${windSpeed} m/s
- Pressure: ${pressure} hPa

$forecastSummary

Based on current conditions AND upcoming weather forecast, analyze:
1. Immediate and upcoming farming risks
2. Weather impacts on crops (next 5 days)
3. Irrigation planning based on forecast
4. Pest/disease risk with weather changes
5. Best timing for farming activities

IMPORTANT: Respond ONLY with valid JSON:

{
  "severity": "High/Medium/Low",
  "weather_prediction": [
    "Analysis point 1 including forecast insights",
    "Analysis point 2 about upcoming conditions"
  ],
  "precautions": [
    "Specific action 1 with timing",
    "Specific action 2 considering forecast",
    "Specific action 3 for next days",
    "Specific action 4 for farm planning"
  ]
}

SEVERITY:
- High: Urgent action (extreme weather coming, immediate risks)
- Medium: Attention needed (forecast shows challenges)
- Low: Normal conditions (routine monitoring)

Focus on ACTIONABLE advice with specific timing based on the 5-day forecast.
''';
  }

  static Future<Map<String, dynamic>> _callGeminiAPI(String prompt) async {
    try {
      final requestBody = {
        "contents": [{"parts": [{"text": prompt}]}],
        "generationConfig": {
          "temperature": 0.2,
          "topK": 1,
          "topP": 0.8,
          "maxOutputTokens": 1500,
        },
        "safetySettings": [
          {"category": "HARM_CATEGORY_HARASSMENT", "threshold": "BLOCK_NONE"},
          {"category": "HARM_CATEGORY_HATE_SPEECH", "threshold": "BLOCK_NONE"},
          {"category": "HARM_CATEGORY_SEXUALLY_EXPLICIT", "threshold": "BLOCK_NONE"},
          {"category": "HARM_CATEGORY_DANGEROUS_CONTENT", "threshold": "BLOCK_NONE"}
        ]
      };

      print('Calling Gemini API...');
      
      final response = await http.post(
        Uri.parse(_geminiApiUrl),
        headers: {"Content-Type": "application/json", "Accept": "application/json"},
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 30));

      print('Gemini API response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return _parseGeminiResponse(response.body);
      } else {
        throw Exception('Gemini API error ${response.statusCode}: ${response.body}');
      }

    } catch (e) {
      print('Gemini API call failed: $e');
      throw Exception('Failed to get AI prediction: $e');
    }
  }

  static Map<String, dynamic> _parseGeminiResponse(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);
      print('Raw Gemini response received');

      final candidates = decoded["candidates"] as List?;
      if (candidates == null || candidates.isEmpty) {
        throw Exception("No candidates in Gemini response");
      }

      final content = candidates[0]["content"];
      final parts = content["parts"] as List?;
      final rawText = parts?[0]["text"] as String?;
      
      if (rawText == null || rawText.isEmpty) {
        throw Exception("No text in Gemini response");
      }

      print('Gemini raw text received');

      String cleanedText = rawText.trim();
      if (cleanedText.startsWith('```json')) {
        cleanedText = cleanedText.replaceFirst('```json', '').trim();
      }
      if (cleanedText.endsWith('```')) {
        cleanedText = cleanedText.substring(0, cleanedText.lastIndexOf('```')).trim();
      }

      Map<String, dynamic> prediction;
      try {
        prediction = jsonDecode(cleanedText);
      } catch (parseError) {
        print('JSON parsing failed, extracting manually...');
        prediction = _extractPredictionFromText(rawText);
      }

      return _validateAndStandardizePrediction(prediction);

    } catch (e) {
      print('Response parsing error: $e');
      throw Exception('Failed to parse AI response: $e');
    }
  }

  static Map<String, dynamic> _extractPredictionFromText(String text) {
    String severity = 'Medium';
    List<String> weatherPrediction = [];
    List<String> precautions = [];

    final severityMatch = RegExp(r'"severity":\s*"(High|Medium|Low)"', caseSensitive: false).firstMatch(text);
    if (severityMatch != null) {
      severity = severityMatch.group(1)!;
    }

    final weatherMatches = RegExp(r'"weather_prediction":\s*\[(.*?)\]', dotAll: true).firstMatch(text);
    if (weatherMatches != null) {
      weatherPrediction = RegExp(r'"([^"]+)"').allMatches(weatherMatches.group(1)!)
          .map((m) => m.group(1)!).toList();
    }

    final precautionMatches = RegExp(r'"precautions":\s*\[(.*?)\]', dotAll: true).firstMatch(text);
    if (precautionMatches != null) {
      precautions = RegExp(r'"([^"]+)"').allMatches(precautionMatches.group(1)!)
          .map((m) => m.group(1)!).toList();
    }

    return {
      'severity': severity,
      'weather_prediction': weatherPrediction.isEmpty ? ['Weather analysis unavailable'] : weatherPrediction,
      'precautions': precautions.isEmpty ? ['Monitor conditions closely'] : precautions,
    };
  }

  static Map<String, dynamic> _validateAndStandardizePrediction(Map<String, dynamic> prediction) {
    String severity = prediction['severity']?.toString() ?? 'Medium';
    severity = severity[0].toUpperCase() + severity.substring(1).toLowerCase();
    if (!['High', 'Medium', 'Low'].contains(severity)) {
      severity = 'Medium';
    }

    List<String> weatherPrediction = [];
    if (prediction['weather_prediction'] is List) {
      weatherPrediction = (prediction['weather_prediction'] as List).map((item) => item.toString()).toList();
    }

    List<String> precautions = [];
    if (prediction['precautions'] is List) {
      precautions = (prediction['precautions'] as List).map((item) => item.toString()).toList();
    }

    if (weatherPrediction.isEmpty) {
      weatherPrediction = ['Weather conditions require monitoring'];
    }
    
    if (precautions.isEmpty) {
      precautions = ['Monitor crop conditions', 'Ensure adequate water supply'];
    }

    print('Validated prediction: Severity=$severity');

    return {
      'severity': severity,
      'weather_prediction': weatherPrediction,
      'precautions': precautions,
      'generated_at': DateTime.now().toUtc().toIso8601String(),
    };
  }

  static Future<void> _storeErrorPrediction(String error) async {
    try {
      final errorPrediction = {
        'severity': 'Medium',
        'weather_prediction': ['Unable to generate analysis', 'System experiencing difficulties'],
        'precautions': ['Continue monitoring', 'Follow standard practices', 'Retry later'],
        'error': error,
        'generated_at': DateTime.now().toUtc().toIso8601String(),
      };

      await FirebaseService.storePrediction(errorPrediction);
      print(' Error prediction stored');
      
    } catch (e) {
      print(' Failed to store error prediction: $e');
    }
  }

  static bool shouldTriggerNotification(String severity) {
    return ['High', 'Medium'].contains(severity);
  }

  static String getNotificationMessage(String severity, List<String> precautions) {
    switch (severity) {
      case 'High':
        return 'URGENT: High severity conditions detected! ${precautions.first}';
      case 'Medium':
        return 'ALERT: Conditions require attention. ${precautions.first}';
      default:
        return 'Weather update available.';
    }
  }
}