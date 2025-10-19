import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  static final DatabaseReference _db = FirebaseDatabase.instance.ref();

  
  static Stream<Map<String, dynamic>?> farmDataStream() {
    return _db.child('farmData').onValue.map((event) {
      if (!event.snapshot.exists) return null;
      return Map<String, dynamic>.from(event.snapshot.value as Map);
    });
  }

 
  static Stream<Map<String, dynamic>?> openWeatherStream() {
    return _db.child('openweatherdata/latest').onValue.map((event) {
      if (!event.snapshot.exists) return null;
      return Map<String, dynamic>.from(event.snapshot.value as Map);
    });
  }

  
  static Future<void> storeOpenWeatherData(Map<String, dynamic> weatherData) async {
    try {
      final dataToStore = {
        'weather_data': weatherData,
        'timestamp': DateTime.now().toUtc().toIso8601String(),
        'data_source': 'openweathermap_coordinates',
      };

      await _db.child('openweatherdata/latest').set(dataToStore);
      print('Weather data stored successfully in Firebase');
      
    } catch (e) {
      print('Error storing weather data: $e');
      rethrow;
    }
  }

  
  static Future<void> storeWeatherForecast(List<Map<String, dynamic>> forecast) async {
    try {
      await _db.child('openweatherdata/forecast').set({
        'forecasts': forecast,
        'timestamp': DateTime.now().toUtc().toIso8601String(),
      });
      print('Forecast stored successfully');
    } catch (e) {
      print('Error storing forecast: $e');
      rethrow;
    }
  }

 
  static Future<List<Map<String, dynamic>>?> getWeatherForecast() async {
    try {
      final snap = await _db.child('openweatherdata/forecast').get();
      if (!snap.exists) return null;
      
      final data = Map<String, dynamic>.from(snap.value as Map);
      final forecasts = data['forecasts'] as List?;
      if (forecasts == null) return null;
      
      return forecasts.map((f) => Map<String, dynamic>.from(f)).toList();
    } catch (e) {
      print('Error getting forecast: $e');
      return null;
    }
  }

  
  static Stream<List<Map<String, dynamic>>?> forecastStream() {
    return _db.child('openweatherdata/forecast').onValue.map((event) {
      if (!event.snapshot.exists) return null;
      
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      final forecasts = data['forecasts'] as List?;
      if (forecasts == null) return null;
      
      return forecasts.map((f) => Map<String, dynamic>.from(f)).toList();
    });
  }

  
  static Future<Map<String, dynamic>?> getLatestFarmData() async {
    try {
      final snapshot = await _db.child('farmData').get();
      if (!snapshot.exists) return null;
      
      return Map<String, dynamic>.from(snapshot.value as Map);
    } catch (e) {
      print('Error getting farm data: $e');
      return null;
    }
  }

  
  static Future<Map<String, dynamic>?> getLatestWeatherData() async {
    try {
      final snapshot = await _db.child('openweatherdata/latest').get();
      if (!snapshot.exists) return null;
      
      return Map<String, dynamic>.from(snapshot.value as Map);
    } catch (e) {
      print('Error getting weather data: $e');
      return null;
    }
  }

  
  static Future<Map<String, dynamic>> preparePredictionPayload() async {
    try {
      final farmData = await getLatestFarmData();
      final weatherDoc = await getLatestWeatherData();
      final weatherData = weatherDoc?['weather_data'];
      final forecast = await getWeatherForecast();

      final payload = {
        'farm_sensors': farmData,
        'weather_data': weatherData,
        'forecast_data': forecast,
        'analysis_timestamp': DateTime.now().toUtc().toIso8601String(),
        'data_sources': {
          'farm_sensors': farmData != null ? 'esp32_sensors' : 'unavailable',
          'weather': weatherData != null ? 'openweathermap' : 'unavailable',
          'forecast': forecast != null ? 'openweathermap_5day' : 'unavailable',
        },
      };

      print('Prediction payload prepared with forecast');
      return payload;
      
    } catch (e) {
      print('Error preparing prediction payload: $e');
      return {
        'error': 'Failed to prepare data',
        'details': e.toString(),
        'timestamp': DateTime.now().toUtc().toIso8601String(),
      };
    }
  }

 
  static Future<void> storePrediction(Map<String, dynamic> prediction) async {
    try {
      final predictionDoc = {
        'prediction': prediction,
        'timestamp': DateTime.now().toUtc().toIso8601String(),
        'source': 'gemini_ai',
      };

      await _db.child('predictions/current').set(predictionDoc);
      
      final historyKey = DateTime.now().millisecondsSinceEpoch.toString();
      await _db.child('predictions/history/$historyKey').set(predictionDoc);
      
      print('Prediction stored successfully');
      
    } catch (e) {
      print('Error storing prediction: $e');
      rethrow;
    }
  }

  
  static Stream<Map<String, dynamic>?> predictionStream() {
    return _db.child('predictions/current').onValue.map((event) {
      if (!event.snapshot.exists) return null;
      return Map<String, dynamic>.from(event.snapshot.value as Map);
    });
  }

  
  static Future<List<Map<String, dynamic>>> getPredictionHistory({int limit = 10}) async {
    try {
      final snapshot = await _db
          .child('predictions/history')
          .orderByChild('timestamp')
          .limitToLast(limit)
          .get();
          
      if (!snapshot.exists) return [];
      
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      return data.values
          .map((item) => Map<String, dynamic>.from(item))
          .toList()
          .reversed
          .toList();
          
    } catch (e) {
      print('Error getting prediction history: $e');
      return [];
    }
  }

  
  static Future<bool> hasRequiredDataForPrediction() async {
    final farmData = await getLatestFarmData();
    final weatherData = await getLatestWeatherData();
    
    return farmData != null && weatherData != null;
  }

  
  static Future<Map<String, dynamic>> getDataFreshness() async {
    try {
      final now = DateTime.now().toUtc();
      final result = <String, dynamic>{};
      
      final farmData = await getLatestFarmData();
      if (farmData != null && farmData.containsKey('timestamp')) {
        final farmTimestamp = DateTime.tryParse(farmData['timestamp'].toString());
        if (farmTimestamp != null) {
          result['farm_data_age_minutes'] = now.difference(farmTimestamp).inMinutes;
        }
      }
      
      final weatherDoc = await getLatestWeatherData();
      if (weatherDoc != null && weatherDoc.containsKey('timestamp')) {
        final weatherTimestamp = DateTime.tryParse(weatherDoc['timestamp'].toString());
        if (weatherTimestamp != null) {
          result['weather_data_age_minutes'] = now.difference(weatherTimestamp).inMinutes;
        }
      }
      
      return result;
      
    } catch (e) {
      print('Error checking data freshness: $e');
      return {};
    }
  }
}