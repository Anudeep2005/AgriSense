import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_service.dart';
import 'package:farm_guard_mvp/firebase_options.dart';
import 'weather_service.dart';
import 'prediction_service.dart';
import 'location_service.dart';


class FarmGuardApp extends StatelessWidget {
  const FarmGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FarmGuard',
      theme: ThemeData(brightness: Brightness.light),
      debugShowCheckedModeBanner: false,
      home: const FarmGuardDashboard(),
    );
  }
}

class FarmGuardDashboard extends StatefulWidget {
  const FarmGuardDashboard({super.key});

  @override
  State<FarmGuardDashboard> createState() => _FarmGuardDashboardState();
}

class _FarmGuardDashboardState extends State<FarmGuardDashboard> {
  String _status = 'Ready';
  Timer? _periodicTimer;
  bool _autoRunning = false;
  LocationData? _currentLocation;

  @override
  void initState() {
    super.initState();
    _initializeSystem();
  }

  @override
  void dispose() {
    _periodicTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeSystem() async {
    setState(() => _status = 'Initializing...');
    await _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    try {
      setState(() => _status = 'Getting location...');
      final locationData = await LocationService.getLocationData();
      
      if (locationData == null) {
        setState(() => _status = 'Location unavailable');
        return;
      }

      setState(() => _currentLocation = locationData);

      setState(() => _status = 'Fetching weather...');
      final weatherData = await WeatherService.fetchWeatherByCoordinates(
        locationData.latitude, 
        locationData.longitude
      );

      if (weatherData == null || weatherData.containsKey('error')) {
        setState(() => _status = 'Weather fetch failed');
        return;
      }

      await FirebaseService.storeOpenWeatherData(weatherData);

      setState(() => _status = 'Fetching forecast...');
      final forecastData = await WeatherService.fetchWeatherForecast(
        locationData.latitude,
        locationData.longitude
      );

      if (forecastData != null) {
        await FirebaseService.storeWeatherForecast(forecastData);
      }

      setState(() => _status = 'Generating prediction...');
      await PredictionService.generateAndStorePrediction();

      setState(() => _status = 'Updated');
    } catch (e) {
      setState(() => _status = 'Error');
      print('Fetch error: $e');
    }
  }

  void _startAutomaticUpdates() {
    if (_autoRunning) return;
    _fetchAllData();
    _periodicTimer = Timer.periodic(const Duration(minutes: 30), (_) => _fetchAllData());
    setState(() => _autoRunning = true);
  }

  void _stopAutomaticUpdates() {
    _periodicTimer?.cancel();
    setState(() => _autoRunning = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/farm_bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.black.withOpacity(0.5),
              ],
            ),
          ),
          child: SafeArea(
            child: RefreshIndicator(
              onRefresh: _fetchAllData,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildHeader(),
                      SizedBox(height: 20),
                      _buildMainWeatherCard(),
                      SizedBox(height: 12),
                      _buildForecastCard(),
                      SizedBox(height: 12),
                      _buildWeatherDetails(),
                      SizedBox(height: 12),
                      _buildSensorCard(),
                      SizedBox(height: 12),
                      _buildPredictionCard(),
                      SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateTime.now().toString().split(' ')[0],
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text(
                  _currentLocation?.locationName ?? 'Loading...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            _buildIconButton(
              icon: _autoRunning ? Icons.pause : Icons.play_arrow,
              onPressed: _autoRunning ? _stopAutomaticUpdates : _startAutomaticUpdates,
            ),
            SizedBox(width: 8),
            _buildIconButton(
              icon: Icons.more_vert,
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMainWeatherCard() {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: FirebaseService.openWeatherStream().distinct(),
      builder: (context, snapshot) {
        final weather = snapshot.data?['weather_data'] ?? {};
        final temp = weather['temperature']?.round() ?? 0;
        final feelsLike = weather['feels_like']?.round() ?? 0;
        final description = weather['description'] ?? 'Loading...';
        final tempMin = weather['temp_min']?.round() ?? temp;
        final tempMax = weather['temp_max']?.round() ?? temp;

        return _buildGlassCard(
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$temp°',
                          style: TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.w200,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          description.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Feels like $feelsLike°',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getWeatherIcon(description),
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 12),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.arrow_upward, color: Colors.red.shade300, size: 14),
                            Text('$tempMax°', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_downward, color: Colors.blue.shade300, size: 14),
                            Text('$tempMin°', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.white.withOpacity(0.2))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildQuickStat(Icons.visibility_outlined, '${weather['visibility'] != null ? (weather['visibility'] / 1000).toStringAsFixed(1) : '--'} km', 'Visibility'),
                    Container(width: 1, height: 30, color: Colors.white.withOpacity(0.2)),
                    _buildQuickStat(Icons.water_drop_outlined, '${weather['humidity'] ?? '--'}%', 'Humidity'),
                    Container(width: 1, height: 30, color: Colors.white.withOpacity(0.2)),
                    _buildQuickStat(Icons.air, '${weather['wind_speed'] ?? '--'} m/s', 'Wind'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getWeatherIcon(String description) {
    final desc = description.toLowerCase();
    if (desc.contains('rain')) return Icons.grain;
    if (desc.contains('cloud')) return Icons.cloud;
    if (desc.contains('clear')) return Icons.wb_sunny;
    if (desc.contains('storm')) return Icons.thunderstorm;
    if (desc.contains('snow')) return Icons.ac_unit;
    if (desc.contains('mist') || desc.contains('fog')) return Icons.cloud_queue;
    return Icons.wb_sunny;
  }

  Widget _buildQuickStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.8), size: 20),
        SizedBox(height: 4),
        Text(value, style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
      ],
    );
  }

  Widget _buildForecastCard() {
    return StreamBuilder<List<Map<String, dynamic>>?>(
      stream: FirebaseService.forecastStream().distinct(),
      builder: (context, snapshot) {
        final forecasts = snapshot.data ?? [];
        
        if (forecasts.isEmpty) {
          return _buildSimpleCard(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Text('Loading forecast...', style: TextStyle(color: Colors.white70)),
              ),
            ),
          );
        }

        return _buildSimpleCard(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('5-DAY FORECAST', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1)),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: forecasts.map((forecast) {
                  return _buildForecastItem(
                    forecast['day'] ?? '',
                    forecast['temp'] ?? 0,
                    forecast['rain_chance'] ?? 0,
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildForecastItem(String day, int temp, int rainChance) {
    return Column(
      children: [
        Text(day, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
        SizedBox(height: 8),
        Icon(
          rainChance > 50 ? Icons.grain : Icons.wb_sunny_outlined,
          color: rainChance > 50 ? Colors.lightBlueAccent : Colors.amber,
          size: 24,
        ),
        SizedBox(height: 8),
        Text('$temp°', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        if (rainChance > 0)
          Text('$rainChance%', style: TextStyle(color: Colors.lightBlueAccent, fontSize: 10)),
      ],
    );
  }

  Widget _buildWeatherDetails() {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: FirebaseService.openWeatherStream().distinct(),
      builder: (context, snapshot) {
        final weather = snapshot.data?['weather_data'] ?? {};
        
        return _buildSimpleCard(
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.white70, size: 18),
                  SizedBox(width: 8),
                  Text('Weather Information', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDetailItem(Icons.water_drop, 'Humidity', '${weather['humidity'] ?? '--'}%'),
                  _buildDetailItem(Icons.air, 'Wind', '${weather['wind_speed'] ?? '--'} m/s'),
                  _buildDetailItem(Icons.compress, 'Pressure', '${weather['pressure'] ?? '--'}'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          SizedBox(height: 4),
          Text(value, style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildSensorCard() {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: FirebaseService.farmDataStream().distinct(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildSimpleCard(
            child: Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
          );
        }

        final data = snapshot.data!;
        return _buildSimpleCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.sensors, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text('Live Sensors', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
              SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildSensorChip('Temp', '${data['temperature']}°C', Icons.thermostat),
                  _buildSensorChip('Humidity', '${data['humidity']}%', Icons.water_drop),
                  _buildSensorChip('Rain', '${data['rain']}', Icons.umbrella),
                  if (data.containsKey('ldr'))
                    _buildSensorChip('Light', '${data['ldr']}', Icons.light_mode),
                  if (data.containsKey('soilMoisture'))
                    _buildSensorChip('Soil', '${data['soilMoisture']}%', Icons.grass),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSensorChip(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 16),
          SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10)),
              Text(value, style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionCard() {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: FirebaseService.predictionStream().distinct(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildSimpleCard(
            child: Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
          );
        }

        final prediction = snapshot.data!['prediction'] ?? {};
        final severity = prediction['severity'] ?? 'Unknown';
        final precautions = List<String>.from(prediction['precautions'] ?? []);

        Color severityColor;
        switch (severity.toLowerCase()) {
          case 'high':
            severityColor = Colors.red;
            break;
          case 'medium':
            severityColor = Colors.orange;
            break;
          case 'low':
            severityColor = Colors.green;
            break;
          default:
            severityColor = Colors.grey;
        }

        return _buildSimpleCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.light_mode, color: Colors.amber, size: 18),
                      SizedBox(width: 8),
                      Text('Recommendations', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: severityColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: severityColor.withOpacity(0.5)),
                    ),
                    child: Text(severity.toUpperCase(), style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              SizedBox(height: 12),
              ...precautions.take(3).map((action) => Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle, color: Colors.greenAccent, size: 14),
                    SizedBox(width: 8),
                    Expanded(child: Text(action, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12))),
                  ],
                ),
              )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
          ),
          child: child,
        ),
      ),
    );
  }


  Widget _buildSimpleCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      padding: padding ?? EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildIconButton({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onPressed,
        constraints: BoxConstraints(minWidth: 40, minHeight: 40),
        padding: EdgeInsets.zero,
      ),
    );
  }
}