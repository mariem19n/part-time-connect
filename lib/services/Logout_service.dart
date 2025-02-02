import 'package:flutter/material.dart';
import 'package:flutter_projects/Log_In/Log_In_Screen.dart';
import 'package:http/http.dart' as http;
import 'package:cookie_jar/cookie_jar.dart';
import 'dart:convert';
import 'package:flutter_projects/commun/csrf_utils.dart';

class ApiService {
  final String apiUrl = 'http://10.0.2.2:8000/api/logout/';
  final CookieJar cookieJar = CookieJar(); // Using the same CookieJar

  Future<void> logout(BuildContext context) async {
    try {
      final csrfToken = await getCsrfToken(cookieJar); // Fetch CSRF token from cookies
      if (csrfToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('CSRF token not found.'),
          backgroundColor: Colors.red,
        ));
        return;
      }

      print('CSRF Token: $csrfToken'); // Debug print

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'X-CSRFToken': csrfToken, // Correct CSRF token usage
        },
        body: json.encode({}),  // Body is empty as per the logout action
      );

      print("Logout Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Logout successful.'),
          backgroundColor: Colors.green,
        ));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LogInPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Logout failed.'),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Server connection error: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

}