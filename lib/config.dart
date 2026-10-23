import 'package:shared_preferences/shared_preferences.dart';

class Config {
  // Legacy / Local backend endpoint
  static String baseUrl = 'http://192.168.43.86:8000';

  // Default Gemini API key configured (configured via App Settings or --dart-define)
  static const String defaultGeminiApiKey = '';

  static Future<String> getGeminiApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final userKey = prefs.getString('gemini_api_key');
    if (userKey != null && userKey.trim().isNotEmpty) {
      return userKey.trim();
    }
    // Check const environment if passed with --dart-define=GEMINI_API_KEY=xxx
    const envKey = String.fromEnvironment('GEMINI_API_KEY');
    if (envKey.isNotEmpty) {
      return envKey;
    }
    return defaultGeminiApiKey;
  }

  static Future<void> setGeminiApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gemini_api_key', key.trim());
  }
}
