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
      // Process the response
      if (response.statusCode == 201) {
        print("Registration successful!");
        // Parse the response body to get the user ID
        final responseBody = await response.stream.bytesToString();
        final data = json.decode(responseBody);
        final userId = data['id']; // Assuming the backend returns the user ID as 'id'
        // Save the user ID to local storage
        await saveUserId(userId);
        print("User ID saved successfully.");
        return true;
      } else {
        print("Error: ${response.statusCode}");
        print("Server error: ${await response.stream.bytesToString()}");
        return false;
      }
    } catch (e) {
      print("Exception: $e");
      return false;
    }
  }
}