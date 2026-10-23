// lib/services/profile_service.dart
import 'package:http/http.dart' as http;
import 'package:plant/config.dart';
import 'package:plant/profile_model.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_token');
  }

  static Future<ProfileData?> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = await _getToken();

    if (token != null && Config.baseUrl.isNotEmpty) {
      try {
        final response = await http
            .get(
              Uri.parse('${Config.baseUrl}/api/profile/'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Token $token',
              },
            )
            .timeout(const Duration(seconds: 3));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          await prefs.setString('user_profile_data', json.encode(data));
          return ProfileData.fromJson(data);
        }
      } catch (_) {
        // Backend offline or timed out; fallback to local storage
      }
    }

    // Retrieve from local offline storage
    final localDataStr = prefs.getString('user_profile_data');
    if (localDataStr != null) {
      try {
        final localData = json.decode(localDataStr);
        return ProfileData.fromJson(localData);
      } catch (_) {}
    }

    final localName = prefs.getString('user_name') ?? 'Farmer';
    return ProfileData(
      firstName: localName,
      phoneNumber: 'N/A',
      speciality: 'Agriculture',
      birthDate: 'N/A',
      birthPlace: 'India',
      email: 'farmer@plantify.ai',
    );
  }

  static Future<bool> updateProfile(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = await _getToken();

    // Always update local cache first
    try {
      final existingStr = prefs.getString('user_profile_data');
      Map<String, dynamic> merged = {};
      if (existingStr != null) {
        merged = json.decode(existingStr);
      }
      merged.addAll(data);
      await prefs.setString('user_profile_data', json.encode(merged));
      if (data.containsKey('first_name')) {
        await prefs.setString('user_name', data['first_name']);
      }
    } catch (_) {}

    if (token != null && Config.baseUrl.isNotEmpty) {
      try {
        final response = await http
            .patch(
              Uri.parse('${Config.baseUrl}/api/update-profile/'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Token $token',
              },
              body: json.encode(data),
            )
            .timeout(const Duration(seconds: 3));

        return response.statusCode == 200;
      } catch (_) {
        // Network timeout; local update succeeded
        return true;
      }
    }

    return true;
  }
}
