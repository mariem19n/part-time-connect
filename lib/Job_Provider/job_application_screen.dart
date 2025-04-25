import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../AppColors.dart';
import '../Job_seeker/ProfilePage.dart';

class JobApplication {
  final int userId;
  final String userName;
  final String status;
  final String applicationDate;
  final List<String> skills;

  JobApplication({
    required this.userId,
    required this.userName,
    required this.status,
    required this.applicationDate,
    required this.skills,
  });

  factory JobApplication.fromJson(Map<String, dynamic> json) {
    return JobApplication(
      userId: json['user_id'],
      userName: json['user_name'],
      status: json['status'],
      applicationDate: json['application_date'],
      skills: List<String>.from(json['skills'] ?? []),
    );
  }
}

class JobApplicationsScreen extends StatefulWidget {
  final int jobId;

  const JobApplicationsScreen({required this.jobId});

  @override
  _JobApplicationsScreenState createState() => _JobApplicationsScreenState();
}

class _JobApplicationsScreenState extends State<JobApplicationsScreen> {
  late Future<List<JobApplication>> _applications;
  final Map<String, int> _statusCounts = {
    'Applied': 0,
    'Interviewing': 0,
    'Offered': 0,
    'Rejected': 0,
    'Completed': 0,
  };

  @override
  void initState() {
    super.initState();
    _applications = _fetchApplications();
  }

  Future<List<JobApplication>> _fetchApplications() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/jobs/${widget.jobId}/applications/'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      _calculateStatusCounts(data);
      return data.map((json) => JobApplication.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load applications');
    }
  }

  void _calculateStatusCounts(List<dynamic> applications) {
    _statusCounts.updateAll((key, value) => 0); // Reset counts
    for (var app in applications) {
      final status = app['status'];
      if (_statusCounts.containsKey(status)) {
        _statusCounts[status] = _statusCounts[status]! + 1;
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Applied':
        return AppColors.primary;
      case 'Interviewing':
        return AppColors.background;
      case 'Offered':
        return AppColors.green;
      case 'Rejected':
        return AppColors.errorBackground;
      case 'Completed':
        return AppColors.borderdarkColor;
      default:
        return AppColors.borderColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Job Applications")),
      body: FutureBuilder<List<JobApplication>>(
        future: _applications,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Failed to load applications"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No applications for this job"));
          } else {
            return Column(
              children: [
                // Status Legend
                _buildStatusLegend(),
                Divider(height: 1),
                // Applications List
                Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final application = snapshot.data![index];
                      return _buildApplicationCard(application);
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildStatusLegend() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Application Status',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: _statusCounts.entries.map((entry) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: _getStatusColor(entry.key),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text('${entry.key}: ${entry.value}'),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationCard(JobApplication application) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // Status Circle
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _getStatusColor(application.status),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 16),
            // Application Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    application.userName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Applied on: ${application.applicationDate}",
                    style: TextStyle(color: AppColors.borderdarkColor, fontSize: 12),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min, // Takes minimum space needed
              children: [
                IconButton(
                  icon: Icon(Icons.remove_red_eye, color: AppColors.primary),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(userId: application.userId),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: AppColors.primary),
                  onPressed: () {
                    _showStatusDialog(context, application);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  void _showStatusDialog(BuildContext context, JobApplication application) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Change Status"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var status in _statusCounts.keys)
                ListTile(
                  title: Text(status),
                  leading: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: _getStatusColor(status),
                      shape: BoxShape.circle,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _updateApplicationStatus(application.userId, status);
                  },
                ),
            ],
          ),
        );
      },
    );
  }
  Future<void> _updateApplicationStatus(int userId, String newStatus) async {
    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:8000/api/jobs/${widget.jobId}/applications/$userId/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': newStatus}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _applications = _fetchApplications(); // Refresh the list
        });
      } else {
        throw Exception('Failed to update status');
      }
    } catch (e) {
      print('Error updating status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status')),
      );
    }
  }

}