import 'package:flutter/material.dart';

enum UserType { JobSeeker, JobProvider }

class UserRole extends ChangeNotifier {
  UserType _userType = UserType.JobSeeker; // Default value

  UserType get userType => _userType;

  void setRole(UserType userType) {
    _userType = userType;
    notifyListeners(); // Notify listeners when the role changes
    print('Role set to: $_userType');
  }
  // Method to clear the user data (e.g., reset the role)
  void clearUserRole() {
    _userType = UserType.JobSeeker; // Reset to default role
    notifyListeners(); // Notify listeners of the reset
    print('After clearing: $_userType');
  }
}
