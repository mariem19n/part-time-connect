import 'package:flutter/material.dart';
import '../AppColors.dart';


// PasswordField Widget
class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  const PasswordField({Key? key, required this.controller}) : super(key: key);


  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}


class _PasswordFieldState extends State<PasswordField> {
  bool _isPasswordVisible = false;


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          cursorColor: AppColors.primary,
          controller: widget.controller,
          decoration: InputDecoration(
            labelText: 'Password', // Floating label
            floatingLabelStyle: const TextStyle(
              color: AppColors.primary, // Label color when focused
              fontWeight: FontWeight.bold,
            ),
            hintText: 'Enter your password', // Optional hint
            hintStyle: const TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: AppColors.borderColor,
            ),
            prefixIcon: const Icon(Icons.lock, color: AppColors.borderColor), // Lock icon
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: AppColors.borderColor,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16), // Default border radius
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: AppColors.borderColor, // Default border color
                width: 2,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: AppColors.primary, // Focused state color
                width: 2,
              ),
              borderRadius: BorderRadius.circular(16),
            ),

          ),
          obscureText: !_isPasswordVisible,
          style: const TextStyle(
            color: AppColors.primary, // Input text color
            fontWeight: FontWeight.bold, // Bold text style
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            if (value.length < 8) {
              return 'Password must be at least 8 characters long';
            }
            return null;
          },
        ),
      ],
    );
  }
}
