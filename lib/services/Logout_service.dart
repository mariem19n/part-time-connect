import 'package:flutter/material.dart';
import 'package:flutter_projects/Log_In/Log_In_Screen.dart';
import 'package:http/http.dart' as http;
import 'package:cookie_jar/cookie_jar.dart';
import 'dart:convert';
import 'package:flutter_projects/commun/csrf_utils.dart';
import 'package:flutter_projects/AppColors.dart';
import '../auth_helper.dart'; // Import the auth_helper file
import 'package:provider/provider.dart';
import '../UserRole.dart';
class ApiService {
  final String apiUrl = 'http://10.0.2.2:8000/api/logout/';
  final CookieJar cookieJar = CookieJar(); // Using the same CookieJar

  Future<void> logout(BuildContext context) async {
    try {
      final csrfToken = await getCsrfToken(cookieJar); // Fetch CSRF token from cookies
      if (csrfToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('CSRF token not found.'),
          backgroundColor: AppColors.errorBackground,
        ));
        return;
      }

      print('CSRF Token: $csrfToken'); // Debug print

      // Attach cookies to the request
      var cookies = await cookieJar.loadForRequest(Uri.parse(apiUrl));
      var cookieHeader = cookies.map((cookie) => '${cookie.name}=${cookie.value}').join('; ');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'X-CSRFToken': csrfToken, // Correct CSRF token usage
          'Cookie': cookieHeader, // Attach cookies to the request
        },
        body: json.encode({}),  // Body is empty as per the logout action
      );

      print("Logout Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 302) {
        // Clear the user ID from local storage
        await clearUserId();
        await clearUsername();
        await clearUserType();
        await clearToken();
        // Clear stored cookies (CSRF token and session)
        await cookieJar.deleteAll();
        // Reset the provider state
        Provider.of<UserRole>(context, listen: false).clearUserRole();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Logout successful.'),
          backgroundColor: AppColors.background,
        ));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LogInPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Logout failed.'),
          backgroundColor: AppColors.errorBackground,
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Server connection error: $e'),
        backgroundColor: AppColors.errorBackground,
      ));
    }
  }
}