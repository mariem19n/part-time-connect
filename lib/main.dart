import 'package:flutter/material.dart';
import 'package:flutter_projects/Job_seeker/RegistrationScreen.dart';
import 'splash_screen.dart'; // Import the splash screen
import 'Job_seeker/RegistrationScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //home: SplashScreen(), // Start with the splash screen
      //home: RegistrationScreen(),
      home: SplashScreen(), // Start with the splash screen
    // home: RegistrationScreen(),
    );
  }
}
