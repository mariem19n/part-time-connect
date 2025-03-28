
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider package
import 'splash_screen.dart'; // Import the splash screen
import 'UserRole.dart'; // Import your UserRole class
import '../AppColors.dart';

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
      theme: ThemeData(
        // Set Quicksand as the default font
        fontFamily: 'Quicksand',
        // Set cursor color to green
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: AppColors.primary, // Custom cursor color
          selectionColor: AppColors.primary, // Optional: Selection highlight
        ),
        // Apply Quicksand to all text styles
        textTheme: TextTheme(
          displayLarge: TextStyle(fontFamily: 'Quicksand'), // Previously headline1
          bodyLarge: TextStyle(fontFamily: 'Quicksand'),    // Previously bodyText1
          bodyMedium: TextStyle(fontFamily: 'Quicksand'),   // Previously bodyText2
        ),
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: AppColors.primary), // Green border when focused
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: AppColors.borderdarkColor), // Default border
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), // Start with the splash screen

    );
  }
}