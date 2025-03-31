
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
          // Floating label style
          floatingLabelStyle: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
          // Border styles
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: AppColors.primary, width: 2), // Green border when focused
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: AppColors.borderdarkColor, width: 1), // Default border
          ),
        ),
        // Elevated button theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.secondary,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Text button theme
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),/*

        // Outlined button theme (if you use them)
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),*/
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), // Start with the splash screen

    );
  }
}