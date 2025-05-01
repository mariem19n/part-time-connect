import 'dart:convert';
import 'package:http/http.dart' as http;
import '../auth_helper.dart';


class LLMRecommendationService {
  static const String _baseUrl = 'http://10.0.2.2:8000';  // Correct host for Android emulator

  Future<List<dynamic>> getRecommendations() async {
    try {
      final token = await getToken();

      if (token == null) {
        throw Exception("User is not authenticated.");
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/api/recommendations/'), // ✅ KEEP /api/ based on your Django URL
        headers: {
          'Authorization': 'Token $token', // ✅ Use Token, not Bearer
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      } else {
        print('❌ Failed to load recommendations: ${response.statusCode}');
        print('Response body: ${response.body}');
        return [];
      }
    } catch (e) {
      print("❌ Recommendation fetch error: $e");
      return [];
    }
  }
}
