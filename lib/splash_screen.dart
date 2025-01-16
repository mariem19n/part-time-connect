import 'dart:async';
import 'package:flutter/material.dart';
import 'Log_In/welcome_screen.dart'; // Import the HomePage widget

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Timer to navigate to WelcomeScreen after 3 seconds
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WelcomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFB7C9A3), // Your green background color
      body: Center(
        child: Image.asset(
          'assets/images/part_time_connect_logo.png', // Path to your logo
          height: 300,
          width: 300,
        ),
      ),
    );
  }
}
