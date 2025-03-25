import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../AppColors.dart';

class ProfilePage extends StatefulWidget {
  final int userId; // Unique user ID to fetch profile
  ProfilePage({required this.userId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = true; // Loading state
  String username = "Loading...";
  String email = "Loading...";
  String aboutMe = "No description available";
  List<String> keySkills = [];
  List<String> certifications = [];
  List<String> languages = [];

  File? _profileImage;

  /// **Fetch user profile data from Django backend**
  Future<void> _fetchUserProfile() async {
    final String apiUrl = "http://10.0.2.2:8000/api/profile/${widget
        .userId}/"; // ✅ API URL

    try {
      print("📡 Fetching profile from: $apiUrl");
      final response = await http.get(Uri.parse(apiUrl));

      print("📡 Response Status: ${response.statusCode}");
      print("📡 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          username = data["username"] ?? "No Username";
          email = data["email"] ?? "No Email";
          aboutMe = data["about_me"] ??
              "No description available"; // ✅ Fetch About Me
          keySkills =
          data["key_skills"] != null ? List<String>.from(data["key_skills"]) : [
          ];
          _isLoading = false;
        });
      } else {
        throw Exception("Failed to load profile data");
      }
    } catch (error) {
      print("❌ Error fetching profile: $error");
      setState(() => _isLoading = false);
    }
  }
  void _updateAboutMe(String newText) {
    setState(() {
      aboutMe = newText.isEmpty
          ? "No description available"
          : newText; // ✅ Update the UI only
    });
  }

  /// **Pick an image from the gallery**
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      // ✅ Upload the image to the server
      await _uploadProfileImage(_profileImage!);
    }
  }

  /// **Upload profile image to the Django backend**
  Future<void> _uploadProfileImage(File imageFile) async {
    final String uploadUrl = "http://10.0.2.2:8000/api/profile/${widget
        .userId}/upload/";

    try {
      var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      request.files.add(
          await http.MultipartFile.fromPath('profile_picture', imageFile.path));

      var response = await request.send();
      if (response.statusCode == 200) {
        print("✅ Profile picture uploaded successfully!");
      } else {
        print("❌ Failed to upload profile picture.");
      }
    } catch (error) {
      print("❌ Error uploading profile picture: $error");
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
        title: Text('Profile Page', style: TextStyle(color: AppColors.primary)),
        backgroundColor: AppColors.secondary,
        elevation: 0,
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(
            child: CircularProgressIndicator()) // Show loader while fetching data
            : SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileSection(),
              SizedBox(height: 20),
              _buildAboutMeSection(), // ✅ Added About Me Section
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
                backgroundColor: AppColors.borderlightColor,
                backgroundImage: _profileImage != null ? FileImage(
                    _profileImage!) : null,
                child: _profileImage == null
                    ? Icon(Icons.camera_alt, size: 30, color: AppColors.secondary)
                    : null,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(username, style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(email, style: TextStyle(color: AppColors.borderdarkColor)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// **About Me Section with Full Width and Bigger Edit Button**
  Widget _buildAboutMeSection() {
    return Container(
      width: double.infinity, // ✅ Ensure full width
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("About Me", style: TextStyle(fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.primary)),
              SizedBox(height: 8),
              Text(aboutMe,
                  style: TextStyle(fontSize: 14, color: AppColors.borderdarkColor)),
              SizedBox(height: 10),
              SizedBox(
                width: double.infinity, // ✅ Make the Edit button full width
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    // ✅ Bigger button padding
                    side: BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _editAboutMe(),
                  child: Text("Edit", style: TextStyle(
                      color: AppColors.primary, fontSize: 16)), // ✅ Bigger text
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  /// **Edit About Me Dialog - Fix for UI Refresh**
  void _editAboutMe() {
    TextEditingController _controller = TextEditingController(
      text: aboutMe == "No description available" ? "" : aboutMe,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)), // ✅ Rounded Corners
          title: Center(
            child: Text(
              "Edit About Me",
              style: TextStyle(fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.primary),
            ),
          ),
          content: SizedBox(
            width: MediaQuery
                .of(context)
                .size
                .width * 0.8, // ✅ Wider Dialog
            child: TextField(
              controller: _controller,
              maxLines: 5,
              style: TextStyle(fontSize: 14, color:AppColors.textColor),
              // ✅ Normal Text Input
              decoration: InputDecoration(
                hintText: "No description available",
                hintStyle: TextStyle(
                    color: AppColors.borderColor, fontStyle: FontStyle.italic),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onTap: () {
                if (_controller.text.isEmpty) {
                  _controller.clear(); // ✅ Clears Placeholder on Tap
                }
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(
                  color: AppColors.primary, fontSize: 16)), // ✅ Green Button
            ),
            TextButton(
              onPressed: () {
                String newText = _controller.text.trim(); // ✅ Trim input
                _updateAboutMe(newText); // ✅ Call update function
                Navigator.pop(context);
                setState(() {}); // ✅ Force UI refresh
              },
              child: Text("Save", style: TextStyle(
                  color: AppColors.primary, fontSize: 16)), // ✅ Green Button
            ),
          ],
        );
      },
    );
  }


  /// **Edit Profile Button (Placeholder for Future Implementation)**
  Widget _buildEditButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          padding: EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: () {
          // TODO: Implement profile editing functionality
          print("Edit Profile button clicked");
        },
        child: Text("Edit Profile", style: TextStyle(color: AppColors.primary)),
      ),
    );
  }


  /// **Skills, Education, and Languages with Add Button**
  Widget _buildSkillsSection() {
    return Container(
      width: double.infinity, // ✅ Make the section take full width
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSkillsCategory("Key Skills", keySkills, _addNewSkill),
              SizedBox(height: 12),
              _buildSkillsCategory("Education/Certifications", certifications, _addNewCertification),
              SizedBox(height: 12),
              _buildSkillsCategory("Languages Spoken", languages, _addNewLanguage),
            ],
          ),
        ),
      ),
    );
  }


  /// **Reusable Function to Build Each Category**
  Widget _buildSkillsCategory(String title, List<String> items,
      Function(String) onAdd) {
    TextEditingController _controller = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.primary)),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: [
            ...items.map((item) =>
                Chip(label: Text(item), backgroundColor: AppColors.borderlightColor))
                .toList(),
            GestureDetector(
              onTap: () => _showAddDialog(title, _controller, onAdd),
              child: Chip(
                label: Icon(Icons.add, color: AppColors.textColor),
                backgroundColor: AppColors.borderlightColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// **Show Dialog to Add New Skill, Certification, or Language**
  void _showAddDialog(String title, TextEditingController controller,
      Function(String) onAdd) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: Center(child: Text("Add $title",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: "Enter $title",
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context),
                child: Text("Cancel", style: TextStyle(color: AppColors.primary))),
            TextButton(
              onPressed: () {
                if (controller.text
                    .trim()
                    .isNotEmpty) {
                  onAdd(controller.text.trim());
                  Navigator.pop(context);
                }
              },
              child: Text("Add", style: TextStyle(color: AppColors.primary)),
            ),
          ],
        );
      },
    );
  }

  /// **Functions to Add New Skills, Certifications, and Languages**
  void _addNewSkill(String skill) {
    setState(() {
      keySkills.add(skill);
    });
  }

  void _addNewCertification(String certification) {
    setState(() {
      certifications.add(certification);
    });
  }

  void _addNewLanguage(String language) {
    setState(() {
      languages.add(language);
    });
  }
}

