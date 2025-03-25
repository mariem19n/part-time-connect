import 'package:shared_preferences/shared_preferences.dart';

/// Save the user ID to local storage
Future<void> saveUserId(int userId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('userId', userId); // Save userId to local storage
  print("✅ User ID saved: $userId");
}

/// Clear the user ID from local storage
Future<void> clearUserId() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('userId'); // Clear userId from local storage
  print("✅ User ID cleared");
}

/// Fetch the user ID from local storage
Future<int?> getUserId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('userId'); // Fetch userId from local storage
}

Future<void> saveUserType(String userType) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('userType', userType);
  print('Saved user type: $userType');
}