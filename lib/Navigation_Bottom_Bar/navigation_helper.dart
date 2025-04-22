import 'package:flutter/material.dart';
import '../auth_helper.dart'; // Import your auth_helper.dart
import '../Job_seeker/ProfilePage.dart'; // Import the ProfilePage
import '../Job_seeker/HomePage.dart';
import '../Job_Provider/PostJobScreen.dart';
import '../Job_Provider/JobOffersScreen.dart';
import 'package:flutter_projects/chat/MessagerieScreen.dart';

class NavigationHelper {
  // Navigate based on the index and user role
  static void onItemTapped(BuildContext context, int index, bool isJobSeeker) async {
    try {
      if (!isJobSeeker) {
        // Handle recruiter's different item order
        switch (index) {
          case 0: // Home
            print('• Handling Job Seeker Navigation');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
            print('  ✅ Successfully navigated to HomePage');
            break;
          case 1: // Search Jobs
            print('  → Navigating to Search Jobs');
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>  JobOffersScreen()),
            );
            print('  ✅ Successfully navigated to Search Jobs');
            break;
          case 2: // Post Jobs
            print('  → Navigating to PostJobScreen');
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PostJobScreen()),
            );
            print('  ✅ Successfully navigated to PostJobScreen');
            break;
          case 3: // Messagerie
            print('  → Navigating to Messagerie');
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MessagerieScreen()),
            );
            print('  ✅ Successfully navigated to Messagerie');
            break;
          case 4: // Profile
            print('  → Attempting Profile navigation');
            int? userId = await getUserId();
            if (userId != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage(userId: userId)),
              );
            }
            break;
        }
      } else {
        // Original job seeker logic
        switch (index) {
          case 0: // Home
            print('• Handling Job Seeker Navigation');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
            print('  ✅ Successfully navigated to HomePage');
            break;
          case 1: // Search Jobs
            print('  → Navigating to Search Jobs');
            Navigator.pushNamed(context, '/search-jobs');
            print('  ✅ Successfully navigated to Search Jobs');
            break;
          case 2: // Messagerie
            print('  → Navigating to Messagerie');
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MessagerieScreen()),
            );
            print('  ✅ Successfully navigated to Messagerie');
            break;
          case 3: // Profile
            print('  → Attempting Profile navigation');
            int? userId = await getUserId();
            if (userId != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage(userId: userId)),
              );
              print('  ✅ Successfully navigated to Profile');
            } else {
              print('  ❌ Failed: User ID not found');
            }
            break;
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Navigation failed: $e')),
      );
    }
  }
}