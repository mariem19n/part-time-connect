import 'package:flutter/material.dart';
import '../Job_seeker/WorkLocationPage.dart'; // Replace with your actual file name
import '../recruiter_interface.dart'; // Replace with your actual file name

class JobCategoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Quarter-circle green background in the bottom-right corner
          Align(
            alignment: Alignment.bottomRight,
            child: ClipPath(
              clipper: QuarterCircleClipper(),
              child: Container(
                color: Color(0xFFB7C9A3), // Match the light green shade
                width: 420, // Adjust size for the quarter-circle
                height: 400,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 100,
                    left: 50,
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/images/part_time_connect_logo.png', // Replace with your logo path
                      height: 300, // Adjust logo size
                      width: 300,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: 150),
                // Move text and buttons to the top
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        'Select a Job Category',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Select whether you’re seeking employment opportunities\nor your organization requires talented individuals.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Worklocationpage()),
                              );
                            },
                            child: Text('Job Seeker'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Color(0xFF4B5320),
                              padding: EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 15,
                              ),
                              side: BorderSide(
                                color: Color(0xFF4B5320),
                                width: 2,
                              ),
                            ),
                          ),
                          SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RecruiterInterface()), // Navigate to Recruiter
                              );
                            },
                            child: Text('Recruiter'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Color(0xFF4B5320),
                              padding: EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 15,
                              ),
                              side: BorderSide(
                                color: Color(0xFF4B5320),
                                width: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Spacer(), // Push the content to the top
              ],
            ),
          ),
        ],
      ),
    );
  }
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
