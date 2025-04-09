import 'package:shared_preferences/shared_preferences.dart';
////////////////////////////////////////////////////////////////////////////
/// Save the username to local storage
Future<void> saveUsername(String username) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('username', username);
  print("✅ Username saved: $username");
}

/// Fetch the username from local storage
Future<String?> getUsername() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('username');
}

/// Clear the username from local storage
Future<void> clearUsername() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('username');
  print("✅ Username cleared");
}
////////////////////////////////////////////////////////////////////////////
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
//////////////////////////////////////////////////////////////////////////
Future<void> saveUserType(String userType) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('userType', userType);
  print('Saved user type: $userType');
}
/// Clear the user type from local storage
Future<void> clearUserType() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('userType');
  print("✅ User type cleared");
}
//////////////////////////////////////////////////////////////////////////
///Récupérer le token stocké dans SharedPreferences
Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('auth_token');
}
/// Method to store token in SharedPreferences
Future<void> storeToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('auth_token', token);  // Store the token
}
/// Clear the auth token from local storage
Future<void> clearToken() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('auth_token');
  print("✅ Auth token cleared");
}
////////////////////////////////////////////////////////////////////////////
