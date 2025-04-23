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

        // Save all user data from response
        await saveUserId(data['id']);
        await storeToken(data['token']);
        await saveUserType(data['user_type']);
        await saveUsername(data['username']);

        return true;
      } else {
        print("Registration failed: ${data['message']}");
        return false;
      }
    } catch (e) {
      print("Registration error: $e");
      return false;
    }
  }
}