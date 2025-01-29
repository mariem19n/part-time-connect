import 'dart:io';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final List<String> _keySkills = ['Graphic Design', 'Marketing'];
  final List<String> _certifications = ['Graphic Design', 'Marketing'];
  final List<String> _languages = ['English', 'Arabic'];
  final List<Map<String, String>> _experiences = [
    {
      "company": "Marketing Masters",
      "rating": "★★★★★",
      "feedback": "Great job on the social media campaign. Could improve response time."
    }
  ];
  final List<Map<String, String>> _projects = [
    {"name": "E-commerce App Development"}
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page', style: TextStyle(color: Color(0xFF375534))),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: Color(0xFF375534)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileSection(),
            SizedBox(height: 20),
            _buildSkillsSection(),
            SizedBox(height: 20),
            _buildExperienceSection(),
            SizedBox(height: 20),
            _buildPortfolioSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPortfolioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Portfolio (Optional Section)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF375534))),
        ..._projects.asMap().entries.map((entry) {
          int index = entry.key;
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: Text("Project Name: ${entry.value['name']}", style: TextStyle(color: Color(0xFF375534))),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => setState(() => _projects.removeAt(index)),
              ),
            ),
          );
        }).toList(),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            side: BorderSide(color: Color(0xFF375534)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => setState(() => _projects.add({"name": "New Project"})),
          child: Text("Add Portfolio Item", style: TextStyle(color: Color(0xFF375534))),
        ),
      ],
    );
  }
}
