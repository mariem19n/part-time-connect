import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../auth_helper.dart';

class JobApplicationService {
  static const String _baseUrl = 'http://10.0.2.2:8000/api/jobs';
  static const Duration _timeout = Duration(seconds: 10);

  Future<Map<String, List<dynamic>>> fetchJobApplications(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/my-applications/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final Map<String, List<dynamic>> groupedApplications = {};

        for (final item in data) {
          final status = item['status'] as String? ?? 'Unknown';
          groupedApplications.putIfAbsent(status, () => []).add(item);
        }

        return groupedApplications;
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed - please login again');
      } else {
        throw Exception('Failed to load applications: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
}