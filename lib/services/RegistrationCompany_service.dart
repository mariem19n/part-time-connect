import 'dart:io';
import 'package:http/http.dart' as http;

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

      // Add files to the request
      for (var file in photos) {
        final fileStream = await http.MultipartFile.fromPath('photo', file.path);
        request.files.add(fileStream);
      }

      // Send the request to the server
      var response = await request.send();

      // Process the server response
      if (response.statusCode == 201) {
        print("Registration successful! Response: ${await response.stream.bytesToString()}");
      } else {
        print("Error: ${response.statusCode}. Response: ${await response.stream.bytesToString()}");
      }
    } catch (e) {
      print("Exception occurred: $e");
    }
  }
}