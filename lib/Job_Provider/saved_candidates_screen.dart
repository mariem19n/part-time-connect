import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../AppColors.dart';
import '../Job_seeker/ProfilePage.dart';
import '../auth_helper.dart';

class ShortlistedCandidate {
  final int userId;
  final String userName;
  final String shortlistedDate;
  final List<String> skills;

  ShortlistedCandidate({
    required this.userId,
    required this.userName,
    required this.shortlistedDate,
    required this.skills,
  });

  factory ShortlistedCandidate.fromJson(Map<String, dynamic> json) {
    return ShortlistedCandidate(
      userId: json['user_id'],
      userName: json['user_name'],
      shortlistedDate: json['shortlisted_at'],
      skills: List<String>.from(json['skills'] ?? []),
    );
  }
}

class ShortlistedCandidatesScreen extends StatefulWidget {
  const ShortlistedCandidatesScreen();

  @override
  _ShortlistedCandidatesScreenState createState() => _ShortlistedCandidatesScreenState();
}

class _ShortlistedCandidatesScreenState extends State<ShortlistedCandidatesScreen> {
  late Future<List<ShortlistedCandidate>> _candidates;

  @override
  void initState() {
    super.initState();
    _candidates = _fetchShortlistedCandidates();
  }

  Future<List<ShortlistedCandidate>> _fetchShortlistedCandidates() async {
    final token = await getToken();
    print('Sending request with token: $token');
    print('Full headers: ${{
      'Content-Type': 'application/json',
      'Authorization': 'Token $token',
    }}');

    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/jobs/shortlists/'),
      headers: {'Content-Type': 'application/json',
        'Authorization': 'Token $token',},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => ShortlistedCandidate.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('Please login again');
    } else {
      throw Exception('Failed to load candidates: ${response.statusCode}');
    }
  }

  Future<void> _removeFromShortlist(int candidateId) async {
    final token = await getToken();
    try {
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:8000/api/jobs/shortlists/$candidateId/'),
        headers: {'Content-Type': 'application/json','Authorization': 'Token $token',},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Candidate removed successfully')),
        );
        setState(() {
          _candidates = _fetchShortlistedCandidates();
        });
      } else {
        throw Exception('Failed to remove: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Shortlisted Candidates")),
      body: FutureBuilder<List<ShortlistedCandidate>>(
        future: _candidates,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Failed to load shortlisted candidates"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No candidates have been shortlisted yet"));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final candidate = snapshot.data![index];
                return _buildCandidateCard(candidate);
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildCandidateCard(ShortlistedCandidate candidate) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // Candidate Avatar (you can replace this with a real image)
            CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Text(
                candidate.userName[0],
                style: TextStyle(color: AppColors.secondary),
              ),
            ),
            SizedBox(width: 16),
            // Candidate Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    candidate.userName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  if (candidate.skills.isNotEmpty)
                    Text(
                      "Skills: ${candidate.skills.join(', ')}",
                      style: TextStyle(color: AppColors.borderdarkColor, fontSize: 12),
                    ),
                  SizedBox(height: 4),
                  Text(
                    "Shortlisted on: ${candidate.shortlistedDate}",
                    style: TextStyle(color: AppColors.borderdarkColor, fontSize: 12),
                  ),
                ],
              ),
            ),
            // Action Buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.remove_red_eye, color: AppColors.primary),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(userId: candidate.userId),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: AppColors.errorBackground),
                  onPressed: () {
                    _showRemoveConfirmationDialog(context, candidate);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRemoveConfirmationDialog(BuildContext context, ShortlistedCandidate candidate) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Remove from Shortlist"),
          content: Text("Are you sure you want to remove ${candidate.userName} from your shortlist?"),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("Remove", style: TextStyle(color: AppColors.errorBackground)),
              onPressed: () {
                Navigator.of(context).pop();
                _removeFromShortlist(candidate.userId);
              },
            ),
          ],
        );
      },
    );
  }
}