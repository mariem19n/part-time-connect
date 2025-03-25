import 'package:flutter/material.dart';
import 'package:flutter_projects/Job_seeker/HomePage.dart';
import 'package:flutter_projects/Sign_Up/JobCategoryPage.dart';
import 'Forgot Password Dialog (Email Input).dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_projects/commun/csrf_utils.dart';
import 'package:cookie_jar/cookie_jar.dart';
import '../AppColors.dart';
import 'package:flutter_projects/custom_clippers.dart';
import '../auth_helper.dart';
import '../UserRole.dart';
import 'package:provider/provider.dart';


class LogInPage extends StatefulWidget {
  @override
  _LogInPageState createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  bool _obscureText = true;
  bool _showForgotPassword = false;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final cookieJar = CookieJar();

  void validateLogin() async {
    String username = usernameController.text;
    String password = passwordController.text;

    try {
      final csrfToken = await getCsrfToken(cookieJar);
      if (csrfToken == null) {
        print(" CSRF Token is null.");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to retrieve CSRF token. Please try again.'),
          backgroundColor: AppColors.errorBackground,
        ));
        return;
      }

      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/login/'), // Check if this endpoint is correct
        headers: {'Content-Type': 'application/json', 'X-CSRFToken': csrfToken},
        body: json.encode({'username': username, 'password': password}),
      );

      print("📡 Status Code: ${response.statusCode}");
      print("📡 Response Body: ${response.body}");

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        // Extract user data from response
        final int id = responseBody['id']!;
        final String userTypeString = responseBody['user_type']!;

        // Validate backend response
        if (id == null || userTypeString == null) {
          throw Exception('Invalid user data received from server');
        }

        // Persist user data
        await saveUserId(id);
        await saveUserType(userTypeString);

        // Convert to enum and update provider
        final UserType userType = userTypeString == "JobProvider"
            ? UserType.JobProvider
            : UserType.JobSeeker;

        Provider.of<UserRole>(context, listen: false).setRole(userType);

        Navigator.pushReplacement(
          context,
          //MaterialPageRoute(builder: (context) => ProfilePage(userId: id)),
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        final responseBody = json.decode(response.body);
        print(" Error Response: ${responseBody['error'] ?? 'Unknown error'}");

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(responseBody['error'] ?? 'An error occurred. Please try again later.'),
          backgroundColor: AppColors.errorBackground,
        ));
      }
    } catch (e) {
      print(" Exception: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to connect to the server. Please try again later.'),
        backgroundColor: AppColors.errorBackground,
      ));
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
                color: AppColors.background,
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
                      color: AppColors.textColor,
                    ),
                  ),
                  SizedBox(height: 20),
                  // Email input
                  TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'Professional Email Address',
                      labelStyle: TextStyle(color: AppColors.primary),
                      prefixIcon: Icon(
                        Icons.email,
                        color: AppColors.primary,
                      ),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primary, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primary, width: 1),
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
                      labelStyle: TextStyle(color: AppColors.primary),
                      prefixIcon: Icon(
                        Icons.lock,
                        color: AppColors.primary,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.primary,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primary, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primary, width: 1),
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
                                builder: (context) => JobCategoryPage()),
                          );
                        },
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            color: AppColors.primary,
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
                          backgroundColor: AppColors.secondary,
                          foregroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          side: BorderSide(
                            color: AppColors.primary,
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
                              color: AppColors.secondary,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: AppColors.primary, // Button background color
                            foregroundColor: AppColors.secondary,
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15), // Padding
                            side: BorderSide(
                              color: AppColors.primary, // Border color
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



