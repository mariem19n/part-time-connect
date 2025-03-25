
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider package
import 'splash_screen.dart'; // Import the splash screen
import 'UserRole.dart'; // Import your UserRole class

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserRole(), // Provide the UserRole instance
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Part_Time_Connect App',
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), // Start with the splash screen

    );
  }
}