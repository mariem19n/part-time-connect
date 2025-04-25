// lib/services/job_interaction_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class JobInteractionService {
  static const String _baseUrl = 'http://10.0.2.2:8000/api/jobs/';

  static Future<Map<String, dynamic>> _makeJobInteractionRequest(
      String endpoint, int jobId) async {
    try {
      // Get the token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Token $token',
      };

      final response = await http.post(
        Uri.parse('$_baseUrl$jobId/$endpoint'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Unknown error',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> recordView(int jobId) async {
    return _makeJobInteractionRequest('view/', jobId);
  }

  static Future<Map<String, dynamic>> recordSave(int jobId) async {
    return _makeJobInteractionRequest('save/', jobId);
  }

  static Future<Map<String, dynamic>> recordApply(int jobId) async {
    return _makeJobInteractionRequest('apply/', jobId);
  }
}