import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  final int userId; // Unique user ID to fetch profile

  ProfilePage({required this.userId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = true; // Loading state
  String fullName = "";
  String email = "";
  String location = "";
  List<String> keySkills = [];

  File? _profileImage;

  /// **Fetch user profile data from Django backend**
  Future<void> _fetchUserProfile() async {
    final String apiUrl = "http://your-backend.com/api/profile/${widget.userId}/";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          fullName = data["full_name"];
          email = data["email"];
          location = data["location"];
          keySkills = List<String>.from(data["key_skills"]); // Convert list
          _isLoading = false;
        });
      } else {
        throw Exception("Failed to load profile data");
      }
    } catch (error) {
      print("Error fetching profile: $error");
      setState(() => _isLoading = false);
    }
  }

  /// **Pick an image from the gallery**
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserProfile(); // Fetch user data when the page loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page', style: TextStyle(color: Color(0xFF375534))),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator()) // Show loader while fetching data
            : SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileSection(),
              SizedBox(height: 20),
              _buildSkillsSection(),
              SizedBox(height: 20),
              _buildEditButton(),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  /// **Profile Section with User Data**
  Widget _buildProfileSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey[300],
                backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                child: _profileImage == null
                    ? Icon(Icons.camera_alt, size: 30, color: Colors.white)
                    : null,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(fullName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(email, style: TextStyle(color: Colors.grey[700])),
                  Text(location, style: TextStyle(color: Colors.grey[700])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// **Styled Edit Button**
  Widget _buildEditButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Color(0xFF375534)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: () {
          // Add edit profile functionality
        },
        child: Text("Edit", style: TextStyle(color: Color(0xFF375534))),
      ),
    );
  }

  /// **Skills Section**
  Widget _buildSkillsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("My Skills", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF375534))),
        Wrap(
          spacing: 8.0,
          children: keySkills
              .map((skill) => Chip(
            label: Text(skill),
            backgroundColor: Colors.green[100],
          ))
              .toList(),
        ),
      ],
    );
  }
}
