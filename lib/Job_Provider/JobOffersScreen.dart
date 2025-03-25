import 'package:flutter/material.dart';
import 'JobDetailsScreen.dart'; // Screen for second image
import 'job.dart';
import 'jobfetch_service.dart';

class JobOffersScreen extends StatefulWidget {
  @override
  _JobOffersScreenState createState() => _JobOffersScreenState();
}

class _JobOffersScreenState extends State<JobOffersScreen> {
  late Future<List<Job>> jobs;

  @override
  void initState() {
    super.initState();
    jobs = JobService.fetchJobs();
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
                  trailing: Text(job.salary != null ? "\$${job.salary}/hour" : "Negotiable"),
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
