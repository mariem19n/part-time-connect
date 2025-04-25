import 'package:flutter/material.dart';
import '../AppColors.dart';
import 'JobDetailsScreen.dart';
import 'job.dart';
import 'jobfetch_service.dart';
import 'job_application_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class JobOffersScreen extends StatefulWidget {
  @override
  _JobOffersScreenState createState() => _JobOffersScreenState();
}

class _JobOffersScreenState extends State<JobOffersScreen> {
  late Future<List<Job>> jobs;
  final Map<int, int> _applicationCounts = {};

  @override
  void initState() {
    super.initState();
    jobs = JobService.fetchJobs();
  }

  Future<int> _getApplicationCount(int jobId) async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/jobs/$jobId/applications/count/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['count'] ?? 0;
      }
      return 0;
    } catch (e) {
      print('Error fetching application count: $e');
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Job Offers")),
      body: FutureBuilder<List<Job>>(
        future: jobs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print("Error: ${snapshot.error}");
            return Center(child: Text("Failed to load jobs"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No job offers available."));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Job job = snapshot.data![index];

                return ListTile(
                  title: Text(job.title),
                  subtitle: Text(job.location),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(job.salary != 0 ? "\$${job.salary}/hour" : "Negotiable"),
                      SizedBox(width: 8),
                      FutureBuilder<int>(
                        future: _getApplicationCount(job.id),
                        builder: (context, countSnapshot) {
                          final count = countSnapshot.data ?? 0;
                          return IconButton(
                            icon: Stack(
                              children: [
                                Icon(Icons.people, color: AppColors.primary),
                                Positioned(
                                  right: 0,
                                  child: CircleAvatar(
                                    radius: 8,
                                    backgroundColor: count > 0 ? AppColors.primary : AppColors.background,
                                    child: Text(
                                      count.toString(),
                                      style: TextStyle(
                                        color: AppColors.secondary,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => JobApplicationsScreen(jobId: job.id),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JobDetailsScreen(jobId: job.id),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}