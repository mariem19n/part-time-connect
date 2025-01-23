import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'Verify Code Dialog (Enter Code).dart';

class ForgotPasswordDialog extends StatefulWidget {
  @override
  _ForgotPasswordDialogState createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  final TextEditingController emailController = TextEditingController();

  void requestPasswordReset() async {
    String email = emailController.text;

    // Make the API call to request password reset
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/request-password-reset/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email}),
    );
    // Print the raw response to check its format
    print('Response body: ${response.body}');

    final responseBody = json.decode(response.body);

    if (response.statusCode == 200) {
      // Handle success
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(responseBody['message']),
        backgroundColor: Colors.green,
      ));

      // Close the ForgotPasswordDialog
      Navigator.pop(context); // This will close the current dialog

      // Show the ResetCodeDialog if the widget is still mounted
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => ResetCodeDialog(email: email),
        );
      }
    } else if (responseBody['error'] == 'Email not found') {
      // Email not found case
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Email not found. Please check and try again.'),
        backgroundColor: Colors.red,
      ));
    } else {
      // Handle other errors
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('An error occurred. Please try again later.'),
        backgroundColor: Colors.red,
      ));
    }
  } // This is where you were missing the closing brace

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Forgot Password',
        textAlign: TextAlign.center, // Centers the title
        style: TextStyle(
          fontSize: 20, // Reduces the font size
        ),
      ),
      content: TextField(
        controller: emailController,
        decoration: InputDecoration(
          labelText: 'Enter your email',
          labelStyle: TextStyle(color: Color(0xFF4B5320)),
          prefixIcon: Icon(Icons.email, color: Color(0xFF4B5320)),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF4B5320), width: 2), // Green underline when focused
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF4B5320), width: 1), // Lighter green when not focused
          ),
        ),
        obscureText: true,
      ),
      actions: [
        TextButton(
          onPressed: requestPasswordReset,
          style: TextButton.styleFrom(
            backgroundColor: Color(0xFF4B5320), // Button background color
            foregroundColor: Colors.white, // Text color
          ),
          child: Text('Submit'),
        ),
      ],
    );
  }
}
