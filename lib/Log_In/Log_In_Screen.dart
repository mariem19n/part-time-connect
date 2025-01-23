import 'package:flutter/material.dart';
import 'package:flutter_projects/Job_seeker/HomePage.dart';
import 'package:flutter_projects/Sign_Up/RegistrationScreen.dart';
import 'Forgot Password Dialog (Email Input).dart';

class LogInPage extends StatefulWidget {
  @override
  _LogInPageState createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  bool _obscureText = true;
  bool _showForgotPassword = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void validateLogin() {
    String email = emailController.text;
    String password = passwordController.text;

    if (email == 'contact@techsolutions.com' && password == 'password123') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      setState(() {
        _showForgotPassword = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid email or password.'),
          backgroundColor: Color(0xFF4B5320),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(top: 50),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomRight,
            child: ClipPath(
              clipper: QuarterCircleClipper(),
              child: Container(
                color: Color(0xFFB7C9A3),
                width: 420,
                height: 400,
                child: Padding(
                  padding: const EdgeInsets.only(top: 100, left: 50),
                  child: Center(
                    child: Image.asset(
                      'assets/images/part_time_connect_logo.png',
                      height: 300,
                      width: 300,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 50),
                  Text(
                    'Log In',
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
                      labelStyle: TextStyle(color: Color(0xFF4B5320)),
                      prefixIcon: Icon(
                        Icons.email,
                        color: Color(0xFF4B5320),
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
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Color(0xFF4B5320)),
                      prefixIcon: Icon(
                        Icons.lock,
                        color: Color(0xFF4B5320),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText ? Icons.visibility_off : Icons.visibility,
                          color: Color(0xFF4B5320),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text("Don't have an account? "),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RegistrationScreen()),
                          );
                        },
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            color: Color(0xFF4B5320),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute buttons to opposite sides
                    children: [
                      ElevatedButton(
                        onPressed: validateLogin, // Use validateLogin function
                        child: Text('Continue'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Color(0xFF4B5320),
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          side: BorderSide(
                            color: Color(0xFF4B5320),
                            width: 2,
                          ),
                        ),
                      ),
                      if (_showForgotPassword)
                        TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => ForgotPasswordDialog(),
                            );
                          },
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Colors.white, // Text color
                            ),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: Color(0xFF4B5320), // Button background color
                            foregroundColor: Colors.white, // Text color
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15), // Padding
                            side: BorderSide(
                              color: Color(0xFF4B5320), // Border color
                              width: 2, // Border width
                            ),

                          ),
                        ),
                    ],
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

