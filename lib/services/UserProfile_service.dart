import 'dart:convert';
import 'package:http/http.dart' as http;
import '../auth_helper.dart';

class UserProfileService {
  static const String _baseUrl = 'http://10.0.2.2:8000/api';

  static Future<bool> updateUserLocations({
    required List<String> locations,
  }) async {
    try {
      // Get the stored token
      final token = await getToken();

      if (token == null) {
        print('No authentication token found');
        return false;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/update_user_location/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',  // Use the token
        },
        body: json.encode({
          'locations': locations,  // Send as array
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to update locations: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error updating locations: $e');
      return false;
    }
  }
}