import 'package:flutter/material.dart';

class SignUpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sign Up Text
            Center(
              child: Text(
                'Sign Up Page',
                style: TextStyle(fontSize: 24),
              ),
            ),
            SizedBox(height: 20), // Add spacing between the text and buttons
            // Continue Button
            Container(
              height: 50.0, // Set a fixed height for both buttons
              margin: EdgeInsets.symmetric(vertical: 6.0),
              child: TextButton(
                onPressed: () {
                  print('Navigate to the next screen');
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith(
                        (states) {
                      if (states.contains(MaterialState.pressed)) {
                        return Color(0xFF4B5320); // Green fill when pressed
                      }
                      return Colors.white; // White fill by default
                    },
                  ),
                  foregroundColor: MaterialStateProperty.resolveWith(
                        (states) {
                      if (states.contains(MaterialState.pressed)) {
                        return Colors.white; // White text when pressed
                      }
                      return Color(0xFF4B5320); // Green text by default
                    },
                  ),
                  side: MaterialStateProperty.all(
                    BorderSide(color: Color(0xFF4B5320)), // Green border
                  ),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                child: Text(
                  'Continue',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            // Skip Button
            Container(
              height: 50.0, // Same height as Continue button
              margin: EdgeInsets.symmetric(vertical: 6.0),
              child: TextButton(
                onPressed: () {
                  // Navigate to the sign-up page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUpPage()),
                  );
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith(
                        (states) {
                      if (states.contains(MaterialState.pressed)) {
                        return Color(0xFF4B5320); // Green fill when pressed
                      }
                      return Colors.white; // White fill by default
                    },
                  ),
                  foregroundColor: MaterialStateProperty.resolveWith(
                        (states) {
                      if (states.contains(MaterialState.pressed)) {
                        return Colors.white; // White text when pressed
                      }
                      return Color(0xFF4B5320); // Green text by default
                    },
                  ),
                  side: MaterialStateProperty.all(
                    BorderSide(color: Color(0xFF4B5320)), // Green border
                  ),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                child: Text(
                  'Skip',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
