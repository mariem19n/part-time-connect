import 'package:flutter/material.dart';
import 'second_welcome_screen.dart'; // Import the second screen
import 'package:flutter_projects/Log_In/Log_In_Screen.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Half-circle green background
          ClipPath(
            clipper: HalfCircleClipper(),
            child: Container(
              color: Color(0xFFB7C9A3), // Dark green color
              height: MediaQuery.of(context).size.height * 0.4, // Adjust height as needed
              width: double.infinity,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/part_time_connect_logo.png', // Replace with your logo path
                      height: 300,
                      width: 300,
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
          // Rest of the content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome to Part Time Connect!',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Connect securely with potential employers through our app.',
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  Spacer(),
                  // Buttons
                  Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Continue Button
                        Container(
                          height: 50.0,  // Set a fixed height for both buttons
                          margin: EdgeInsets.symmetric(vertical: 6.0),
                          child: TextButton(
                            onPressed: () {
                              // Navigate to the second-welcome-screen page
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => SecondWelcomeScreen()),
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
                              'Continue',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        // Skip Button
                        Container(
                          height: 50.0,  // Same height as Continue button
                          margin: EdgeInsets.symmetric(vertical: 6.0),
                          child: TextButton(
                            onPressed: () {
                              // Navigate to the sign-up page
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => LogInPage()),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom clipper for the half-circle
class HalfCircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.75);
    path.quadraticBezierTo(
      size.width / 2, // Control point x
      size.height, // Control point y
      size.width, // End point x
      size.height * 0.75, // End point y
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
