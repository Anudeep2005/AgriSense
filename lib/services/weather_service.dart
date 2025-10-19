import 'dart:convert';
import 'package:http/http.dart' as http;
import 'location_service.dart';

class WeatherService {
  static const String _apiKey = 'MY_OPENWEATHERMAP_API_KEY'; 


  static Future<Map<String, dynamic>?> fetchWeatherByCoordinates(
    double latitude, 
    double longitude
  ) async {
    try {
      final uri = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$_apiKey&units=metric',
      );

      print('Fetching weather for coordinates: $latitude, $longitude');
      
      final response = await http.get(uri).timeout(const Duration(seconds: 15));
      
      if (response.statusCode != 200) {
        print('OpenWeather API error: ${response.statusCode}');
        return {
          'error': true,
          'statusCode': response.statusCode,
          'message': 'Failed to fetch weather data',
        };
      }

      final Map<String, dynamic> json = jsonDecode(response.body);
      print('Weather API response received');

      return _extractWeatherData(json);

    } catch (e) {
      print(' WeatherService error: $e');
      return {
        'error': true,
        'message': 'Network or parsing error',
        'details': e.toString(),
      };
    }
  }

  
  static Future<List<Map<String, dynamic>>?> fetchWeatherForecast(
    double latitude, 
    double longitude
  ) async {
    try {
      final uri = Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?lat=$latitude&lon=$longitude&appid=$_apiKey&units=metric',
      );

      print('Fetching 5-day forecast...');
      final response = await http.get(uri).timeout(const Duration(seconds: 15));
      
      if (response.statusCode != 200) {
        print(' Forecast API error: ${response.statusCode}');
        return null;
      }

      final json = jsonDecode(response.body);
      final List forecastList = json['list'] ?? [];
      
      List<Map<String, dynamic>> dailyForecasts = [];
      String? lastDate;
      
      for (var item in forecastList) {
        final dt = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
        final dateKey = '${dt.day}/${dt.month}';
        
        if (lastDate != dateKey && dailyForecasts.length < 5) {
          dailyForecasts.add({
            'date': dateKey,
            'day': _getDayName(dt.weekday),
            'temp': item['main']['temp'].round(),
            'temp_min': item['main']['temp_min'].round(),
            'temp_max': item['main']['temp_max'].round(),
            'description': item['weather'][0]['description'],
            'rain_chance': ((item['pop'] ?? 0) * 100).round(),
            'icon': _getWeatherIconName(item['weather'][0]['description']),
          });
          lastDate = dateKey;
        }
      }
      
      print('Forecast fetched: ${dailyForecasts.length} days');
      return dailyForecasts;
    } catch (e) {
      print('Forecast error: $e');
      return null;
    }
  }

  static String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  static String _getWeatherIconName(String description) {
    final desc = description.toLowerCase();
    if (desc.contains('rain')) return 'rain';
    if (desc.contains('cloud')) return 'cloud';
    if (desc.contains('clear')) return 'sunny';
    if (desc.contains('storm')) return 'storm';
    return 'cloud';
  }

  static Map<String, dynamic> _extractWeatherData(Map<String, dynamic> json) {
    int? sunriseEpoch = json['sys']?['sunrise'];
    int? sunsetEpoch = json['sys']?['sunset'];
    
    String? sunrise, sunset;
    if (sunriseEpoch != null) {
      sunrise = DateTime.fromMillisecondsSinceEpoch(sunriseEpoch * 1000, isUtc: true)
          .toLocal().toString().substring(11, 16);
    }
    if (sunsetEpoch != null) {
      sunset = DateTime.fromMillisecondsSinceEpoch(sunsetEpoch * 1000, isUtc: true)
          .toLocal().toString().substring(11, 16);
    }

    String? description;
    if (json['weather'] != null && (json['weather'] as List).isNotEmpty) {
      description = json['weather'][0]['description'] as String?;
    }

    return {
      'city_name': json['name'] ?? 'Unknown',
      'coordinates': {
        'latitude': json['coord']?['lat'],
        'longitude': json['coord']?['lon'],
      },
      'description': description,
      'temperature': json['main']?['temp'],
      'feels_like': json['main']?['feels_like'],
      'temp_min': json['main']?['temp_min'],
      'temp_max': json['main']?['temp_max'],
      'pressure': json['main']?['pressure'],
      'sea_level': json['main']?['sea_level'],
      'ground_level': json['main']?['grnd_level'],
      'humidity': json['main']?['humidity'],
      'visibility': json['visibility'],
      'wind_speed': json['wind']?['speed'],
      'wind_direction': json['wind']?['deg'],
      'wind_gust': json['wind']?['gust'],
      'cloudiness': json['clouds']?['all'],
      'sunrise': sunrise,
      'sunset': sunset,
      'data_timestamp': json['dt'],
      'fetched_at': DateTime.now().toUtc().toIso8601String(),
    };
  }

  static Future<Map<String, dynamic>?> fetchCurrentLocationWeather() async {
    try {
      final locationData = await LocationService.getLocationData();
      if (locationData == null) return {'error': true, 'message': 'Unable to get location'};

      final weatherData = await fetchWeatherByCoordinates(
        locationData.latitude, 
        locationData.longitude
      );

      if (weatherData != null && !weatherData.containsKey('error')) {
        weatherData['location_info'] = locationData.toMap();
      }

      return weatherData;
    } catch (e) {
      print('fetchCurrentLocationWeather error: $e');
      return {'error': true, 'message': 'Failed to fetch location weather'};
    }
  }
}