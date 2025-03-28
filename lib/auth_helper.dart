import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
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
// Example of making an authenticated API call with the token
Future<void> makeAuthenticatedRequest() async {
  final token = await getToken();  // Fetch token from SharedPreferences
  if (token == null) {
    print('User is not authenticated');
    return;
  }
  final response = await http.get(
    Uri.parse('http://10.0.2.2:8000/api/secure-data/'),
    headers: {
      'Authorization': 'Bearer $token',  // Send token in Authorization header
    },
  );
  if (response.statusCode == 200) {
    print('Secure data: ${response.body}');
  } else {
    print('Failed to fetch secure data');
  }
}
////////////////////////////////////////////////////////////////////////////
