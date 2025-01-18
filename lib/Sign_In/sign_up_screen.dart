import 'package:flutter/material.dart';
import 'package:flutter_projects/Job_seeker/HomePage.dart';
import 'package:flutter_projects/Log_In/welcome_screen.dart';
import 'package:flutter_projects/Log_In/RegistrationScreen.dart';


class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool _obscureText = true; // Declare the obscureText variable to control the visibility of the password

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Prevent screen resizing when keyboard appears
      body: Stack(
        children: [
          // Quarter-circle green background in the bottom-right corner
          Align(
            alignment: Alignment.bottomRight,
            child: ClipPath(
              clipper: QuarterCircleClipper(),
              child: Container(
                color: Color(0xFFB7C9A3), // Light green shade
                width: 420,
                height: 400,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 100,
                    left: 50,
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/images/part_time_connect_logo.png', // Replace with your logo path
                      height: 300, // Adjusted size
                      width: 300,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Form inputs and buttons
          SafeArea(
            child: SingleChildScrollView( // Make the content scrollable
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, // Left align the content
                children: [
                  SizedBox(height: 50), // Adjust spacing from the top
                  Text(
                    'Sign Up',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 20),
                  // Email input
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Professional Email Address',
                      labelStyle: TextStyle(color: Color(0xFF4B5320)), // Set label color to green
                      prefixIcon: Icon(
                        Icons.email,
                        color: Color(0xFF4B5320), // Email icon color
                      ),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF4B5320), width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF4B5320), width: 1),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Password input
                  TextField(
                    controller: passwordController,
                    obscureText: _obscureText, // Use the state variable to control visibility
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Color(0xFF4B5320)), // Set label color to green
                      prefixIcon: Icon(
                        Icons.lock,
                        color: Color(0xFF4B5320), // Lock icon color
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText ? Icons.visibility_off : Icons.visibility,
                          color: Color(0xFF4B5320), // Eye icon color
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText; // Toggle the visibility
                          });
                        },
                      ),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF4B5320), width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF4B5320), width: 1),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  // Log in link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RegistrationScreen()),
                          );
                        },
                        child: Text(
                          "Log in",
                          style: TextStyle(
                            color: Color(0xFF4B5320),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  // Continue button aligned to the right
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        String email = emailController.text;
                        String password = passwordController.text;

                        // Mock database validation (replace with real validation)
                        if (email == 'contact@techsolutions.com' && password == 'password123') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomePage()),
                          );
                        } else {
                          // Show error message at the top with green color
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Invalid email or password.'),
                              backgroundColor: Color(0xFF4B5320), // Green color
                              behavior: SnackBarBehavior.floating, // To make it float above content
                              margin: EdgeInsets.only(top: 50),
                            ),
                          );
                        }
                      },
                      child: Text('Continue'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Color(0xFF4B5320),
                        padding: EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        side: BorderSide(
                          color: Color(0xFF4B5320),
                          width: 2,
                        ),
                      ),
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

// Custom clipper for a quarter-circle
class QuarterCircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(size.width, size.height); // Bottom-right corner
    path.lineTo(size.width, 0); // Top-right corner
    path.arcToPoint(
      Offset(0, size.height), // Bottom-left corner
      radius: Radius.circular(size.width), // Quarter-circle radius
      clockwise: false,
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
