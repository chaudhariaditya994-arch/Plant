import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plant/config.dart';
import 'package:plant/services/gemini_service.dart';

class ApiService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_token');
  }

  static Future<Map<String, dynamic>> predictDisease(File imageFile) async {
    // Attempt local/Django backend first if available
    try {
      final token = await _getToken();
      if (token != null && Config.baseUrl.isNotEmpty) {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('${Config.baseUrl}/api/predict-disease/'),
        );
        request.headers['Authorization'] = 'Token $token';
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            imageFile.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );

        var response = await request.send().timeout(const Duration(seconds: 4));
        var responseData = await response.stream.bytesToString();

        if (response.statusCode == 200 || response.statusCode == 201) {
          var responseJson = json.decode(responseData);
          if (!responseJson.containsKey('confidence')) {
            responseJson['confidence'] = 1.0;
          }
          responseJson['is_reliable'] = responseJson['confidence'] >= 0.5;
          return responseJson;
        }
      }
    } catch (_) {
      // Backend unavailable or timed out; proceed to Gemini AI analysis
    }

    // Direct Gemini-powered multimodal plant leaf diagnosis
    final diagnosis = await GeminiService.diagnoseImage(imageFile);

    return {
      'is_plant': diagnosis.isPlant,
      'plant_disease': 1,
      'predicted_class': '${diagnosis.plantName} - ${diagnosis.diseaseName}',
      'confidence': diagnosis.confidence,
      'is_reliable': diagnosis.isReliable,
      'disease_details': {
        'id': 1,
        'is_default': true,
        'plant_name': diagnosis.plantName,
        'disease_name': diagnosis.diseaseName,
        'confidence': diagnosis.confidence,
        'is_reliable': diagnosis.isReliable,
        'symptoms': diagnosis.symptoms,
        'management': diagnosis.management,
        'organic_control': diagnosis.organicControl,
        'chemical_control': diagnosis.chemicalControl,
        'sources': diagnosis.sources,
      }
    };
  }

  static Future<Map<String, dynamic>> getDiseaseDetails(int diseaseId) async {
    try {
      final token = await _getToken();
      if (token != null) {
        final response = await http.get(
          Uri.parse('${Config.baseUrl}/api/get-disease/$diseaseId/'),
          headers: {
            'Authorization': 'Token $token',
            'Content-Type': 'application/json',
          },
        ).timeout(const Duration(seconds: 4));

        if (response.statusCode == 200) {
          return json.decode(response.body);
        }
      }
    } catch (_) {}

    return {
      'id': diseaseId,
      'is_default': true,
      'plant_name': 'Agricultural Advisory',
      'disease_name': 'Plant Disease Details',
      'symptoms': 'Consult the AI Krishi Chatbot for personalized symptom analysis.',
      'management': 'Practice crop rotation, sanitize tools, and maintain drainage.',
    };
  }
}
