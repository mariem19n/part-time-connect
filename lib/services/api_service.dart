import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://10.0.2.2:8000/api/simple-api/'; // Replace with your API URL

  Future<void> testConnection() async {
    var url = Uri.parse(baseUrl);
    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        print('Connection successful!');
        print('Response: ${response.body}');
      } else {
        print('Error: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('Failed to connect: $e');
    }
  }
}
