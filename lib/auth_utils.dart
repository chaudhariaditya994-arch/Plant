import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:plant/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('user_token', token);
}

Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('user_token');
}

Future<String?> getUserFullName() async {
  final prefs = await SharedPreferences.getInstance();
  final token = await getToken();

  if (token != null && Config.baseUrl.isNotEmpty) {
    try {
      final response = await http
          .get(
            Uri.parse('${Config.baseUrl}/api/profile/'),
            headers: {
              'Authorization': 'Token $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['first_name'] ?? data['full_name'] ?? 'Farmer';
      }
    } catch (_) {}
  }

  // Fallback to local profile
  final localDataStr = prefs.getString('user_profile_data');
  if (localDataStr != null) {
    try {
      final localData = jsonDecode(localDataStr);
      return localData['first_name'] ?? localData['full_name'] ?? 'Farmer';
    } catch (_) {}
  }

  return prefs.getString('user_name') ?? 'Farmer';
}
