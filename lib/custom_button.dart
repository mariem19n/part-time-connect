import 'package:flutter/material.dart';
import 'package:flutter_projects/AppColors.dart';
//import 'package:flutter_projects/custom_button.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.0,
      margin: EdgeInsets.symmetric(vertical: 6.0),
      child: TextButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith(
                (states) => states.contains(MaterialState.pressed)
                ? AppColors.primary
                : AppColors.secondary,
          ),
          foregroundColor: MaterialStateProperty.resolveWith(
                (states) => states.contains(MaterialState.pressed)
                ? AppColors.secondary
                : AppColors.primary,
          ),
          side: MaterialStateProperty.all(
            BorderSide(color: AppColors.primary),
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
