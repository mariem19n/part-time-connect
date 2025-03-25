import 'package:flutter/material.dart';
import '../AppColors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final bool isJobSeeker;
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.isJobSeeker,
    required this.currentIndex,
    required this.onTap,
  });

  // Common navigation items for both Job Seeker and Recruiter
  final List<BottomNavigationBarItem> _commonItems = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.search),
      label: 'Search Jobs',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.message),
      label: 'Messagerie',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  // Additional navigation item for Recruiter
  final BottomNavigationBarItem _recruiterItem = const BottomNavigationBarItem(
    icon: Icon(Icons.work),
    label: 'Post Jobs',
  );
  @override
  Widget build(BuildContext context) {
    // For Job Seeker: [Home, Search Jobs, Messagerie, Profile] (4 items)
    // For Recruiter: [Home, Search Jobs, Post Jobs, Messagerie, Profile] (5 items)
    final items = isJobSeeker
        ? _commonItems
        : [
      _commonItems[0], // Home
      _commonItems[1], // Search Jobs
      _recruiterItem,     // Post Jobs
      _commonItems[2], // Messagerie
      _commonItems[3], // Profile
    ];

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: items,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.borderdarkColor,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    );
  }
}

  /*@override
  Widget build(BuildContext context) {
    print("Building BottomNavBar with ${isJobSeeker ? "Job Seeker" : "Recruiter"} items");

    // Generate the items list dynamically
    final items = isJobSeeker
        ? _commonItems // Use common items for Job Seeker
        : [
      ..._commonItems.take(2), // Use first 2 common items
      _recruiterItem, // Add Recruiter-specific item
      ..._commonItems.skip(2), // Use remaining common items
    ];

    // Debug prints to verify the items list
    print("Generated Items: $items");
    print("First Item: ${items[0].label}");
    print("Second Item: ${items[1].label}");
    print("Third Item: ${items[2].label}");
    if (items.length > 3) {
      print("Fourth Item: ${items[3].label}");
    }

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: items,
      selectedItemColor: AppColors.primary, // Green color for selected item
      unselectedItemColor: AppColors.borderdarkColor, // Grey color for unselected items
      showUnselectedLabels: true, // Show labels for unselected items
      type: BottomNavigationBarType.fixed, // Ensure all items are visible
    );


  }
}*/