// lib/services/interaction_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_projects/auth_helper.dart';

class InteractionService {
  static const String _baseUrl = 'http://10.0.2.2:8000/api/';

  static Future<Map<String, dynamic>> _makeInteractionRequest(
      String endpoint,
      int candidateUserId,
      String? message,
      ) async {
    try {
      final recruiterId = await getUserId();
      if (recruiterId == null) {
        return {'success': false, 'message': 'No recruiter ID found'};
      }

      final body = {
        'recruiter_id': recruiterId,
        'candidate_id': candidateUserId,
        if (message != null) 'message': message,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
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

  static Future<Map<String, dynamic>> recordView(int candidateUserId) async {
    return _makeInteractionRequest('recruiter/view/', candidateUserId, null);
  }

  static Future<Map<String, dynamic>> recordShortlist(int candidateUserId) async {
    return _makeInteractionRequest('recruiter/shortlist/', candidateUserId, null);
  }

  static Future<Map<String, dynamic>> recordContact(
      int candidateUserId, {
        String message = '',
      }) async {
    return _makeInteractionRequest('recruiter/contact/', candidateUserId, message);
  }
}