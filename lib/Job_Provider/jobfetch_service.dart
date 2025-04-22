
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'job.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JobService {
  static const String baseUrl = "http://10.0.2.2:8000/api/jobs";
  Future<List<Job>> getJobs() async {
    try {
      final response = await http.get(Uri.parse('${baseUrl}/get_jobs/'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final jobs = data['jobs'] as List;
        return jobs.map((job) => Job.fromJson(job)).toList();
      } else {
        throw Exception('Failed to load jobs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load jobs: $e');
    }
  }
  static Future<bool> deleteJob(int jobId, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/offer/$jobId/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );
      print('Sending delete request with token: $token');
      print('Delete response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to delete job: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete job: $e');
    }
  }

  static Future<List<Job>> fetchJobs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getInt('userId');

      if (companyId == null) {
        throw Exception("No company ID found. Please log in.");
      }

      final url = Uri.parse("$baseUrl/job-list/?company_id=$companyId");
      print("➡️ Fetching jobs from: $url");

      final response = await http.get(url);
      print("🔄 Status: ${response.statusCode}");
      print("📦 Raw response length: ${response.body.length} chars");

      if (response.statusCode == 200) {
        // Add strict parsing with validation
        final parsed = _parseJobListResponse(response.body);
        return parsed;
      } else {
        throw Exception("API request failed with status ${response.statusCode}");
      }
    } catch (e, stack) {
      print("❌ Error in fetchJobs: $e");
      print("Stack trace: $stack");
      rethrow;
    }
  }

  static List<Job> _parseJobListResponse(String responseBody) {
    try {
      // 1. Verify JSON is valid
      final dynamic decoded = jsonDecode(responseBody);
      print("🔍 Decoded type: ${decoded.runtimeType}");

      // 2. Handle case where response is unexpectedly a single job
      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('id')) { // Check if it's a single job
          return [Job.fromJson(decoded)];
        }
        throw FormatException("Expected List but got single Map without job ID");
      }

      // 3. Normal case - list of jobs
      if (decoded is List) {
        return decoded.map<Job>((item) {
          if (item is! Map<String, dynamic>) {
            throw FormatException("Expected Map but got ${item.runtimeType}");
          }
          return Job.fromJson(item);
        }).toList();
      }

      throw FormatException("Unexpected response type: ${decoded.runtimeType}");
    } catch (e, stack) {
      print("❌ JSON parsing error: $e");
      print("Stack trace: $stack");
      rethrow;
    }
  }
  // Fetch job details by job ID
  static Future<Job> fetchJobDetails(int jobId) async {
    final prefs = await SharedPreferences.getInstance();
    int? companyId = prefs.getInt('userId'); // Get user ID (company ID)

    if (companyId == null) {
      print("❌ Error: No company ID found in storage.");
      throw Exception("No company ID found. Please log in.");
    }
    final String url = "$baseUrl" + "/job-details/$jobId/";
    print("Fetching job details from: $url");

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return Job.fromJson(jsonDecode(response.body));
    } else {
      print("Error: ${response.body}");
      throw Exception("Failed to load job details");
    }
  }
}
