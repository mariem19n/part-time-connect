/*import 'dart:convert';
import 'package:http/http.dart' as http;

class RecommendationService {
  static const String _baseUrl = 'http://10.0.2.2:8000';
  static Future<Map<String, dynamic>> fetchRecommendations(
      String userType, String? token, {int? jobId}) async {
    try {
      final endpoint = userType == 'JobSeeker'
          ? '/rec/jobs/'
          : jobId != null
          ? '/rec/candidates/$jobId/'
          : '/rec/candidates/';

      // Debug: Print the token being used
      print('🔑 Using token: ${token?.substring(0, 5)}...');

      final response = await http.get(
        Uri.parse('$_baseUrl$endpoint'),
        headers: {
          'Authorization': 'Bearer $token',
          'X-CSRFToken': 'YOUR_CSRF_TOKEN', // Add this line
          'Content-Type': 'application/json',
        },
      );

      print('📡 Recommendation Status: ${response.statusCode}');
      print('📡 Response Headers: ${response.headers}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load recommendations. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Recommendation Error: $e');
      rethrow;
import 'package:cookie_jar/cookie_jar.dart';
    }
  }
}*/
import 'dart:convert';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../auth_helper.dart'; // Your existing auth helper
import 'package:flutter_projects/commun/csrf_utils.dart';

class RecommendationService {
  static const String _baseUrl = 'http://10.0.2.2:8000';

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('No authentication token found. Please log in again.');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Token $token',
    };
  }

  Future<Map<String, dynamic>> fetchRecommendations(
      String userType, {
        int? jobId,
      }) async {
    try {
      final headers = await _getAuthHeaders();
      final endpoint = userType == 'JobSeeker'
          ? '/rec/jobs/'
          : jobId != null
          ? '/rec/candidates/$jobId/'
          : '/rec/candidates/';

      print('🌐 Request URL: $_baseUrl$endpoint');
      print('🔑 Using auth token: ${headers['Authorization']?.substring(0, 15)}...');

      final response = await http.get(
        Uri.parse('$_baseUrl$endpoint'),
        headers: headers,
      );

      print('📡 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Decoded Data: $data'); // Add this to see the exact structure
        return data;
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please log in again.');
      } else {
        throw Exception('Failed to load recommendations (${response.statusCode})');
      }
    } catch (e) {
      print('❌ Recommendation Error: $e');
      rethrow;
    }
  }
}