import 'package:flutter/material.dart';
import 'package:flutter_projects/Log_In/Log_In_Screen.dart';
import 'package:flutter_projects/services/Logout_service.dart';

class HomePage extends StatelessWidget {
  final ApiService apiService = ApiService(); // Create an instance of ApiService

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        centerTitle: true,
        backgroundColor: Color(0xFFB7C9A3), // Match the light green shade
        actions: [
          IconButton(
            icon: Icon(Icons.logout), // Logout icon
            onPressed: () async {
              await apiService.logout(context); // Pass context to logout function
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LogInPage()),
              );
            },
          ),
        ],
      ),
      body: Center(child: Text('Welcome to the Home Page')),
    );
  }
}