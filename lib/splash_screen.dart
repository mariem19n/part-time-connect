import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Sign_Up//welcome_screen.dart'; // Import the HomePage widget
import 'Job_seeker/HomePage.dart';
import 'AppColors.dart';
import 'auth_helper.dart';
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserAndNavigate();
  }

  Future<void> _checkUserAndNavigate() async {
    // Fetch userId from local storage
    final userId = await getUserId();

    // Add a delay to simulate a splash screen (optional)
    await Future.delayed(Duration(seconds: 3));

    // Navigate based on userId
    if (userId != null) {
      // User is logged in, navigate to HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      // User is not logged in, navigate to WelcomeScreen
      // Timer to navigate to WelcomeScreen after 3 seconds
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WelcomeScreen()),

      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Your green background color
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



