import 'package:flutter/material.dart';
import 'package:flutter_projects/Log_In/Log_In_Screen.dart';
import 'package:flutter_projects/services/Logout_service.dart';
import '../AppColors.dart';
import 'package:flutter_projects/Navigation_Bottom_Bar/custom_bottom_nav_bar.dart'; // Import the custom bottom navigation bar
import 'package:flutter_projects/Navigation_Bottom_Bar/navigation_helper.dart';
import 'package:provider/provider.dart';
import '../UserRole.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  final ApiService apiService = ApiService(); // Create an instance of ApiService
  int _currentIndex = 0; // Track the selected index for the bottom navigation bar

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    print("Current Index: $_currentIndex");
    // Use the centralized navigation logic (if you created NavigationHelper)
    bool isJobSeeker = Provider.of<UserRole>(context, listen: false).userType == UserType.JobSeeker;
    print("User Role: ${isJobSeeker ? "Job Seeker" : "Recruiter"}");
    NavigationHelper.onItemTapped(context, index, isJobSeeker); // true for Job Seeker (or false for Recruiter)
  }
  @override
  Widget build(BuildContext context) {
    bool isJobSeeker = Provider.of<UserRole>(context).userType == UserType.JobSeeker;
    print("UserType from Provider: ${Provider.of<UserRole>(context, listen: false).userType}"); // Debugging print
    print("Building HomePage with Bottom Navigation Bar for: ${isJobSeeker ? "Job Seeker" : "Recruiter"}");
    //bool isJobSeeker = false;
    print("UserType from Provider: ${Provider.of<UserRole>(context, listen: false).userType}"); // Debugging print
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        centerTitle: true,
        backgroundColor: AppColors.background,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await apiService.logout(context); // Pass context to logout function
              Navigator.pushReplacement(
               context,
               MaterialPageRoute(builder: (context) => LogInPage()),
              );
            },
          ),
        ],
      ),
      body: Center(child: Text('Welcome to the Home Page')), // Ensure body is present
      bottomNavigationBar: CustomBottomNavBar(
        isJobSeeker: isJobSeeker,
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}