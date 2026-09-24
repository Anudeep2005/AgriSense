import 'dart:convert';
import 'package:http/http.dart' as http;
import 'firebase_service.dart';
import 'env_config.dart';

class PredictionService {
  static final String _backendPredictUrl = "${EnvConfig.backendUrl}/api/predictions/predict";

  static Future<void> generateAndStorePrediction() async {
    try {
      print('Starting XGBoost environmental prediction generation...');

      final combinedData = await FirebaseService.preparePredictionPayload();
      
      if (combinedData.containsKey('error')) {
        throw Exception('Failed to prepare telemetry data: ${combinedData['error']}');
      }

      final farmData = combinedData['farm_sensors'] ?? {};
      final weatherData = combinedData['weather_data'] ?? {};

      final currentTelemetry = {
        'timestamp': DateTime.now().toUtc().toIso8601String(),
        'temperature': (farmData['temperature'] ?? weatherData['temperature'] ?? 25.0).toDouble(),
        'humidity': (farmData['humidity'] ?? weatherData['humidity'] ?? 70.0).toDouble(),
        'soil_moisture': (farmData['soilMoisture'] ?? 45.0).toDouble(),
        'rain': (farmData['rain'] ?? 4095.0).toDouble(),
        'ldr_value': (farmData['ldr'] ?? 1000.0).toDouble(),
        'wind_speed': (weatherData['wind_speed'] ?? 1.5).toDouble(),
        'pressure': (weatherData['pressure'] ?? 1013.25).toDouble(),
        'cloudiness': (weatherData['cloudiness'] ?? 20.0).toDouble(),
      };

      print('Calling Node backend XGBoost prediction API...');
      
      final response = await http.post(
        Uri.parse(_backendPredictUrl),
        headers: {"Content-Type": "application/json", "Accept": "application/json"},
        body: jsonEncode({"current": currentTelemetry, "history": [currentTelemetry]}),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final predictionData = decoded['predictions'] ?? {};

        final standardizedPrediction = {
          'severity': _deriveSeverity(predictionData),
          'xgboost_forecast': predictionData,
          'precautions': _derivePrecautions(predictionData),
          'generated_at': DateTime.now().toUtc().toIso8601String(),
          'model_source': 'xgboost_9models',
        };

        await FirebaseService.storePrediction(standardizedPrediction);
        print('XGBoost prediction stored successfully in Firebase');
      } else {
        print('Node backend prediction failed with code ${response.statusCode}, falling back to static rules');
        await _storeFallbackPrediction(currentTelemetry);
      }

    } catch (e, stackTrace) {
      print('🚨 PredictionService error: $e');
      print('Stack trace: $stackTrace');
      await _storeErrorPrediction(e.toString());
    }
  }

  static String _deriveSeverity(Map<String, dynamic> predictions) {
    final soil = predictions['soilMoisture'] ?? {};
    final soil6h = (soil['6h'] ?? 50.0).toDouble();
    final temp = predictions['temperature'] ?? {};
    final temp6h = (temp['6h'] ?? 25.0).toDouble();

    if (soil6h <= 25.0 || temp6h >= 38.0) return 'High';
    if (soil6h <= 30.0 || temp6h >= 34.0) return 'Medium';
    return 'Low';
  }

  static List<String> _derivePrecautions(Map<String, dynamic> predictions) {
    final soil = predictions['soilMoisture'] ?? {};
    final temp = predictions['temperature'] ?? {};
    final soil6h = (soil['6h'] ?? 50.0).toDouble();
    final soil24h = (soil['24h'] ?? 50.0).toDouble();
    final temp6h = (temp['6h'] ?? 25.0).toDouble();

    List<String> precautions = [];

    if (soil6h <= 25.0) {
      precautions.add('🚨 CRITICAL: Soil moisture expected to reach ${soil6h.toStringAsFixed(1)}% in 6h. Irrigate immediately!');
    } else if (soil24h <= 30.0) {
      precautions.add('⚠️ Irrigation needed: Soil moisture falling to ${soil24h.toStringAsFixed(1)}% within 24h.');
    } else {
      precautions.add('✅ Optimal soil moisture levels maintained for the next 24 hours.');
    }

    if (temp6h >= 34.0) {
      precautions.add('☀️ High heat warning: Temp reaching ${temp6h.toStringAsFixed(1)}°C in 6h. Provide shade or extra moisture.');
    } else {
      precautions.add('🌡️ Stable temperature conditions forecasted.');
    }

    return precautions;
  }

  static Future<void> _storeFallbackPrediction(Map<String, dynamic> telemetry) async {
    final fallback = {
      'severity': 'Low',
      'xgboost_forecast': {
        'temperature': {'6h': telemetry['temperature'], '10h': telemetry['temperature'], '24h': telemetry['temperature']},
        'humidity': {'6h': telemetry['humidity'], '10h': telemetry['humidity'], '24h': telemetry['humidity']},
        'soilMoisture': {'6h': telemetry['soil_moisture'], '10h': telemetry['soil_moisture'], '24h': telemetry['soil_moisture']},
      },
      'precautions': ['Monitor soil moisture levels', 'Check weather conditions regularly'],
      'generated_at': DateTime.now().toUtc().toIso8601String(),
    };
    await FirebaseService.storePrediction(fallback);
  }

  static Future<void> _storeErrorPrediction(String error) async {
    try {
      final errorDoc = {
        'severity': 'Medium',
        'precautions': ['System monitoring active', 'Follow standard farming schedule'],
        'error': error,
        'generated_at': DateTime.now().toUtc().toIso8601String(),
      };
      await FirebaseService.storePrediction(errorDoc);
    } catch (e) {
      print('Failed to store error prediction: $e');
    }
  }
}