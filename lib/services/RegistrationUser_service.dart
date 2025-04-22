import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../auth_helper.dart';

class RegistrationUserService {
  static Future<bool> registerUser({
    required String username,
    required String email,
    required String password,
    required List<String> skills,
    required List<File> resumes,
  }) async {
    var uri = Uri.parse("http://10.0.2.2:8000/api/register/");
    var request = http.MultipartRequest('POST', uri);
    try {
      // Add text fields to the request
      request.fields['username'] = username;
      request.fields['email'] = email;
      request.fields['password'] = password;
      request.fields['skills'] = skills.join(',');
      request.fields['user_type'] = 'JobSeeker';
      print("user_type: JobSeeker");
      // Add files to the request
      for (var file in resumes) {
        final fileStream = await http.MultipartFile.fromPath('resume', file.path);
        request.files.add(fileStream);
      }
      // Send the request
      var response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final data = json.decode(responseBody);
      if (response.statusCode == 201) {
        print("Registration successful!");
        final userId = data['id'];
        if (data['id'] != null) {
          await saveUserId(userId);
          print("User ID saved successfully.");
          //return true;
          // Now fetch token after successful registration
          final token = await _fetchToken(username, password);
          if (token != null) {
            await storeToken(token);  // Save token securely
            print("Token saved successfully.");
            return true;
          } else {
            print("Error: Failed to get token");
            return false;}
        } else {
          print("Error: No user ID in response");
          return false;
        }

      } else {
        print("Error: ${response.statusCode}");
        print("Server error: $data");
        // You might want to show the actual error message to the user
        throw Exception(data['message'] ?? 'Registration failed');
      }
    } catch (e) {
      print("Exception: $e");
      return false;
    }
  }
  static Future<String?> _fetchToken(String username, String password) async {
    final uri = Uri.parse("http://10.0.2.2:8000/api/get-token/");
    try {
      final response = await http.post(
        uri,
        body: json.encode({
          'username': username,
          'password': password  // Same password used in registration
        }),
        headers: {'Content-Type': 'application/json'},
      );

      print("Token response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200) {
        return json.decode(response.body)['token'];
      } else {
        print("Token error: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Token exception: $e");
      return null;
    }
  }
}