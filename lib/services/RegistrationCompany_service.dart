import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../auth_helper.dart'; // Import the auth_helper file

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
      print("user_type: JobProvider");

      // Add photos to the request
      for (var file in photos) {
        final fileStream = await http.MultipartFile.fromPath('photo', file.path);
        request.files.add(fileStream);
      }

      // Send the request to the server
      var response = await request.send();

      // Process the server response
      if (response.statusCode == 201) {
        print("Registration successful! Response: ${await response.stream.bytesToString()}");

        // Parse the response body to get the user ID (assuming the backend returns the user ID as 'id')
        final responseBody = await response.stream.bytesToString();
        final data = json.decode(responseBody);

        if (data['status'] == 'success') {
          final userId = data['id']; // Adjust based on the actual response

          // Save the user ID to local storage
          await saveUserId(userId);
        } else {
          print("Error: ${data['message']}");
        }

      } else {
        print("Error: ${response.statusCode}. Response: ${await response.stream.bytesToString()}");
      }
    } catch (e) {
      print("Exception occurred: $e");
    }
  }
}



