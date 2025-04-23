import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../auth_helper.dart';

class RegistrationCompanyService {
  static Future<void> registerCompany({
    required String username,
    required String email,
    required String password,
    required String jobtype,
    required String companyDescription,
    required List<File> photos,
  }) async {
    var uri = Uri.parse("http://10.0.2.2:8000/api/register_company/");
    var request = http.MultipartRequest('POST', uri);

    try {
      // Add text fields to the request
      request.fields['username'] = username;
      request.fields['email'] = email;
      request.fields['password'] = password;
      request.fields['jobtype'] = jobtype;
      request.fields['company_description'] = companyDescription;
      request.fields['user_type'] = 'JobProvider'; // Explicit user type

      // Add photos to the request
      for (var file in photos) {
        final fileStream = await http.MultipartFile.fromPath('photo', file.path);
        request.files.add(fileStream);
      }

      // Send the request to the server
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

      } else {
        print("Registration failed: ${data['message']}");
      }
    } catch (e) {
      print("Registration error: $e");
    }
  }
}


