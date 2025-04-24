// lib/services/interaction_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_projects/auth_helper.dart';

class InteractionService {
  static const String _baseUrl = 'http://10.0.2.2:8000/api/';

  static Future<bool> recordView(int candidateUserId) async {
    try {
      final recruiterId = await getUserId();
      final response = await http.post(
        Uri.parse('${_baseUrl}recruiter/view/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'recruiter_id': recruiterId,
          'candidate_id': candidateUserId,  // This should be UserRegistration ID
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('View Error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('View Exception: $e');
      return false;
    }
  }

  static Future<bool> recordShortlist(int candidateUserId) async {
    try {
      final recruiterId = await getUserId();
      final response = await http.post(
        Uri.parse('${_baseUrl}recruiter/shortlist/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'recruiter_id': recruiterId,
          'candidate_id': candidateUserId,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Shortlist Error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Shortlist Exception: $e');
      return false;
    }
  }

  static Future<bool> recordContact(int candidateUserId, {String message = ''}) async {
    try {
      final recruiterId = await getUserId();
      final response = await http.post(
        Uri.parse('${_baseUrl}recruiter/contact/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'recruiter_id': recruiterId,
          'candidate_id': candidateUserId,
          'message': message,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Contact Error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Contact Exception: $e');
      return false;
    }
  }
}