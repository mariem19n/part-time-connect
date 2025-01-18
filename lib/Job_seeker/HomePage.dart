import 'package:flutter/material.dart';
import 'package:flutter_projects/services/api_service.dart';// Import your API service file

class HomePage extends StatelessWidget {
  final ApiService apiService = ApiService(); // Create an instance of ApiService

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        centerTitle: true,
        backgroundColor: Color(0xFFB7C9A3), // Match the light green shade
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Home Page',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20), // Add spacing between the text and button
            ElevatedButton(
              onPressed: () {
                apiService.testConnection(); // Call the API service
              },
              child: Text('Test API Connection'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFB7C9A3), // Button color to match theme
              ),
            ),
          ],
        ),
      ),
    );
  }
}

