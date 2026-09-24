import 'package:flutter/foundation.dart';

class EnvConfig {
  static const String backendUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: kIsWeb ? 'http://localhost:5000' : 'http://10.0.2.2:5000',
  );

  static const String openWeatherApiKey = String.fromEnvironment(
    'OPENWEATHER_API_KEY',
    defaultValue: 'MY_OPENWEATHERMAP_API_KEY',
  );

  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'MY_GEMINI_API_KEY',
  );
}
