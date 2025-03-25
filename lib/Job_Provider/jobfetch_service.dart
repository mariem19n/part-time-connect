
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'job.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JobService {
  static const String baseUrl = "http://10.0.2.2:8000/api/jobs/";

  // Fetch jobs for the logged-in company (user)
  static Future<List<Job>> fetchJobs() async {
    final prefs = await SharedPreferences.getInstance();
    int? companyId = prefs.getInt('userId'); // Get user ID (company ID)

    if (companyId == null) {
      print("❌ Error: No company ID found in storage.");
      throw Exception("No company ID found. Please log in.");
    }

    //final String url = "$baseUrl?company_id=$companyId";
    final String url = "$baseUrl" + "job-list/?company_id=$companyId";
    print("Fetching jobs from: $url");

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((json) => Job.fromJson(json)).toList();
    } else {
      print("Error: ${response.body}");
      throw Exception("Failed to load jobs");
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
    final String url = "$baseUrl" + "job-details/$jobId/";
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
