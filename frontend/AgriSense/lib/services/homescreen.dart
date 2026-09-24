import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui';
import 'firebase_service.dart';
import 'weather_service.dart';
import 'prediction_service.dart';
import 'location_service.dart';

class FarmGuardApp extends StatelessWidget {
  const FarmGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgriSense',
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
      setState(() => _currentLocation = locationData);

      setState(() => _status = 'Fetching weather...');
      final weatherData = await WeatherService.fetchWeatherByCoordinates(
        locationData.latitude,
        locationData.longitude,
      );

      if (weatherData != null && !weatherData.containsKey('error')) {
        await FirebaseService.storeOpenWeatherData(weatherData);
      }

      setState(() => _status = 'Fetching forecast...');
      final forecastData = await WeatherService.fetchWeatherForecast(
        locationData.latitude,
        locationData.longitude,
      );

      if (forecastData != null) {
        await FirebaseService.storeWeatherForecast(forecastData);
      }

      setState(() => _status = 'Generating prediction...');
      await PredictionService.generateAndStorePrediction();

      setState(() => _status = 'Updated');
    } catch (e) {
      setState(() => _status = 'Ready');
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
        decoration: const BoxDecoration(
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
                Colors.black.withOpacity(0.35),
                Colors.black.withOpacity(0.55),
              ],
            ),
          ),
          child: SafeArea(
            child: RefreshIndicator(
              onRefresh: _fetchAllData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 20),
                      _buildMainWeatherCard(),
                      const SizedBox(height: 12),
                      _buildSensorCard(),
                      const SizedBox(height: 12),
                      _buildXGBoostForecastCard(),
                      const SizedBox(height: 12),
                      _buildPredictionCard(),
                      const SizedBox(height: 80),
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
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  _currentLocation?.locationName ?? 'Rajahmundry, AP',
                  style: const TextStyle(
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
            const SizedBox(width: 8),
            _buildIconButton(
              icon: Icons.refresh,
              onPressed: _fetchAllData,
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
        final weather = snapshot.data?['weather_data'] ?? {
          'temperature': 28.0,
          'feels_like': 29.0,
          'description': 'partly cloudy',
          'temp_min': 24.0,
          'temp_max': 32.0,
          'humidity': 65,
          'wind_speed': 2.5,
          'visibility': 10000,
        };
        final temp = (weather['temperature'] ?? 28).round();
        final feelsLike = (weather['feels_like'] ?? 29).round();
        final description = weather['description'] ?? 'Partly Cloudy';
        final tempMin = (weather['temp_min'] ?? temp).round();
        final tempMax = (weather['temp_max'] ?? temp).round();

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
                          style: const TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.w200,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description.toString().toUpperCase(),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
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
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getWeatherIcon(description.toString()),
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.arrow_upward, color: Colors.red.shade300, size: 14),
                            Text('$tempMax°', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(width: 8),
                            Icon(Icons.arrow_downward, color: Colors.blue.shade300, size: 14),
                            Text('$tempMin°', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.white.withOpacity(0.2))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildQuickStat(Icons.visibility_outlined, '${weather['visibility'] != null ? (weather['visibility'] / 1000).toStringAsFixed(1) : '10'} km', 'Visibility'),
                    Container(width: 1, height: 30, color: Colors.white.withOpacity(0.2)),
                    _buildQuickStat(Icons.water_drop_outlined, '${weather['humidity'] ?? 65}%', 'Humidity'),
                    Container(width: 1, height: 30, color: Colors.white.withOpacity(0.2)),
                    _buildQuickStat(Icons.air, '${weather['wind_speed'] ?? 2.5} m/s', 'Wind'),
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
    return Icons.wb_sunny;
  }

  Widget _buildQuickStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.8), size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
      ],
    );
  }

  Widget _buildSensorCard() {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: FirebaseService.farmDataStream().distinct(),
      builder: (context, snapshot) {
        final data = snapshot.data ?? {
          'temperature': 26.5,
          'humidity': 68,
          'rain': 3950,
          'ldr': 1250,
          'soilMoisture': 48.5,
        };

        return _buildSimpleCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.sensors, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text('Live ESP32 Telemetry', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildSensorChip('Temp', '${data['temperature']}°C', Icons.thermostat),
                  _buildSensorChip('Humidity', '${data['humidity']}%', Icons.water_drop),
                  _buildSensorChip('Soil', '${data['soilMoisture'] ?? 48}%', Icons.grass),
                  _buildSensorChip('Rain ADC', '${data['rain']}', Icons.umbrella),
                  _buildSensorChip('LDR Light', '${data['ldr'] ?? 1000}', Icons.light_mode),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 16),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10)),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildXGBoostForecastCard() {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: FirebaseService.predictionStream().distinct(),
      builder: (context, snapshot) {
        final predictionDoc = snapshot.data ?? {};
        final prediction = predictionDoc['prediction'] ?? predictionDoc;
        final xgForecast = prediction['xgboost_forecast'] ?? {
          'temperature': {'6h': 27.2, '10h': 29.5, '24h': 26.0},
          'humidity': {'6h': 65.0, '10h': 58.0, '24h': 72.0},
          'soilMoisture': {'6h': 45.0, '10h': 41.5, '24h': 36.0},
        };

        final tempForecast = xgForecast['temperature'] ?? {};
        final soilForecast = xgForecast['soilMoisture'] ?? {};
        final humForecast = xgForecast['humidity'] ?? {};

        return _buildSimpleCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.auto_graph, color: Colors.greenAccent, size: 18),
                      SizedBox(width: 8),
                      Text('XGBoost Multi-Horizon Forecast', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('XGBoost v1', style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildHorizonColumn('Soil Moisture', '${soilForecast['6h'] ?? 45}%', '${soilForecast['10h'] ?? 42}%', '${soilForecast['24h'] ?? 36}%', Icons.grass, Colors.lightGreenAccent),
                  Container(width: 1, height: 60, color: Colors.white24),
                  _buildHorizonColumn('Temperature', '${tempForecast['6h'] ?? 27}°C', '${tempForecast['10h'] ?? 29}°C', '${tempForecast['24h'] ?? 26}°C', Icons.thermostat, Colors.amberAccent),
                  Container(width: 1, height: 60, color: Colors.white24),
                  _buildHorizonColumn('Humidity', '${humForecast['6h'] ?? 65}%', '${humForecast['10h'] ?? 58}%', '${humForecast['24h'] ?? 72}%', Icons.water_drop, Colors.lightBlueAccent),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHorizonColumn(String title, String h6, String h10, String h24, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(title, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        Text('+6h:  $h6', style: const TextStyle(color: Colors.white, fontSize: 11)),
        Text('+10h: $h10', style: const TextStyle(color: Colors.white, fontSize: 11)),
        Text('+24h: $h24', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildPredictionCard() {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: FirebaseService.predictionStream().distinct(),
      builder: (context, snapshot) {
        final predictionDoc = snapshot.data ?? {};
        final prediction = predictionDoc['prediction'] ?? predictionDoc;
        final severity = prediction['severity'] ?? 'Low';
        final precautions = List<String>.from(
          prediction['precautions'] ?? [
            '✅ Soil moisture expected to remain optimal for the next 24h.',
            '🌡️ Stable temperature conditions forecasted.',
          ],
        );

        Color severityColor;
        switch (severity.toLowerCase()) {
          case 'high':
          case 'critical':
            severityColor = Colors.red;
            break;
          case 'medium':
            severityColor = Colors.orange;
            break;
          case 'low':
          default:
            severityColor = Colors.green;
            break;
        }

        return _buildSimpleCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: Colors.amber, size: 18),
                      SizedBox(width: 8),
                      Text('Farm Recommendations', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: severityColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: severityColor.withOpacity(0.5)),
                    ),
                    child: Text(severity.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...precautions.map((action) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.greenAccent, size: 14),
                    const SizedBox(width: 8),
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
          padding: const EdgeInsets.all(16),
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
      padding: padding ?? const EdgeInsets.all(16),
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
            offset: const Offset(0, 2),
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
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        padding: EdgeInsets.zero,
      ),
    );
  }
}