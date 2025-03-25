import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../AppColors.dart';

class ResetPasswordDialog extends StatefulWidget {
  final String email;
  final String code;

  ResetPasswordDialog({required this.email, required this.code});

  @override
  _ResetPasswordDialogState createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<ResetPasswordDialog> {
  final TextEditingController passwordController = TextEditingController();

  void resetPassword() async {
    String email = widget.email;
    String code = widget.code;
    String newPassword = passwordController.text;

    // Make the API call to reset the password
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/reset-password/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'code': code,
        'new_password': newPassword,
      }),
    );

    final responseBody = json.decode(response.body);

    if (response.statusCode == 200) {
      // Display success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Password reset successful'),
        backgroundColor: AppColors.primary,
      ));
      Navigator.pop(context); // Close the dialog
    } else {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(responseBody['error']),
        backgroundColor: AppColors.errorBackground,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          'Reset Password',
        textAlign: TextAlign.center, // Centers the title
        style: TextStyle(
          fontSize: 20, // Reduces the font size
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: passwordController,
            decoration: InputDecoration(
              labelText: 'Enter new password',
              labelStyle: TextStyle(color: AppColors.primary),
              prefixIcon: Icon(Icons.lock, color: AppColors.primary),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary, width: 2), // Green underline when focused
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary, width: 1), // Lighter green when not focused
              ),
            ),
            obscureText: true,
            cursorColor: AppColors.primary,
          ),
          SizedBox(height: 20),
        ],
      ),
      actions: [
        TextButton(
          onPressed: resetPassword,
          style: TextButton.styleFrom(
            backgroundColor: AppColors.primary, // Button background color
            foregroundColor: AppColors.secondary, // Text color
          ),
          child: Text('Reset Password'),
        ),
      ],
    );
  }
}
