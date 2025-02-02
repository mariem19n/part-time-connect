import 'dart:io';
import 'package:http/http.dart' as http;

class RegistrationUserService {
  static Future<void> registerUser({
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
      } else {
        print("Error: ${response.statusCode}");
        print("Server error: ${await response.stream.bytesToString()}");
      }
    } catch (e) {
      print("Exception: $e");
    }
  }
}