import 'package:flutter/material.dart';
//import 'package:flutter_projects/custom_clippers.dart';

// Custom clipper for the half-circle
class HalfCircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.75);
    path.quadraticBezierTo(
      size.width / 2, // Control point x
      size.height, // Control point y
      size.width, // End point x
      size.height * 0.75, // End point y
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Custom clipper for a quarter-circle
class QuarterCircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(size.width, size.height); // Start at bottom-right corner
    path.lineTo(size.width, 0); // Go to the top-right corner
    path.arcToPoint(
      Offset(0, size.height), // Bottom-left corner
      radius: Radius.circular(size.width), // Radius for quarter-circle
      clockwise: false, // Draw counterclockwise
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

