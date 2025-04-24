import 'dart:convert';
import 'package:http/http.dart' as http;
import '../auth_helper.dart';

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