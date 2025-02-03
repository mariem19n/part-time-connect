import 'package:flutter/material.dart';


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
          cursorColor: Color(0xFF375534),
          controller: widget.controller,
          decoration: InputDecoration(
            labelText: 'Password', // Floating label
            floatingLabelStyle: const TextStyle(
              color: Color(0xFF375534), // Label color when focused
              fontWeight: FontWeight.bold,
            ),
            hintText: 'Enter your password', // Optional hint
            hintStyle: const TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
            prefixIcon: const Icon(Icons.lock, color: Colors.grey), // Lock icon
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey,
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
                color: Colors.grey, // Default border color
                width: 2,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Color(0xFF375534), // Focused state color
                width: 2,
              ),
              borderRadius: BorderRadius.circular(16),
            ),

          ),
          obscureText: !_isPasswordVisible,
          style: const TextStyle(
            color: Color(0xFF375534), // Input text color
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
