import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'Password Reset Screen.dart';
import '../AppColors.dart';

class ResetCodeDialog extends StatefulWidget {
  final String email;

  ResetCodeDialog({required this.email});

  @override
  _ResetCodeDialogState createState() => _ResetCodeDialogState();
}

class _ResetCodeDialogState extends State<ResetCodeDialog> {
  final TextEditingController codeController = TextEditingController();

  void verifyCode() async {
    String email = widget.email;
    String code = codeController.text;

    // Make the API call to verify the reset code
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/verify-reset-code/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'code': code}),
    );

    final responseBody = json.decode(response.body);

    if (response.statusCode == 200) {
      // Display success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Code verified successfully'),
        backgroundColor: AppColors.primary,
      ));

      // Close the ResetCodeDialog
      Navigator.pop(context); // Close the dialog

      // Show the ResetPasswordDialog as a pop-up
      showDialog(
        context: context,
        builder: (context) => ResetPasswordDialog(email: email, code: code),
      );
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
        'Enter Verification Code',
        textAlign: TextAlign.center, // Centers the title
        style: TextStyle(
          fontSize: 20, // Reduces the font size
        ),
      ),
      content: TextField(
        controller: codeController,
        decoration: InputDecoration(
          labelText: 'Enter the 6-digit code',
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
      actions: [
        TextButton(
          onPressed: verifyCode,
          style: TextButton.styleFrom(
            backgroundColor: AppColors.primary, // Button background color
            foregroundColor: AppColors.secondary, // Text color
          ),
          child: Text('Verify'),
        ),
      ],
    );
  }
}
