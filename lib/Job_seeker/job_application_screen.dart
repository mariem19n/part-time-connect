import 'package:flutter/material.dart';
import '../services/job_application_service.dart';
import '../models/job_application_model.dart';
import '../auth_helper.dart';
import '../widgets/job_application_card.dart';
import '../auth_helper.dart';



class JobApplicationScreen extends StatefulWidget {
  const JobApplicationScreen({Key? key}) : super(key: key);

  @override
  _JobApplicationScreenState createState() => _JobApplicationScreenState();
}

class _JobApplicationScreenState extends State<JobApplicationScreen> {
  late Future<Map<String, List<JobApplication>>> _futureApplications;

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  void _loadApplications() async {
    final token = await getToken();
    setState(() {
      _futureApplications = _fetchApplications(token ?? '');
    });
  }

  Future<Map<String, List<JobApplication>>> _fetchApplications(String token) async {
    final service = JobApplicationService();
    final Map<String, List<dynamic>> rawApplications = await service.fetchJobApplications(token);

    final Map<String, List<JobApplication>> applications = {};
    rawApplications.forEach((status, items) {
      applications[status] = items.map((item) => JobApplication.fromJson(item)).toList();
    });

    return applications;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Job Applications'),
      ),
      body: FutureBuilder<Map<String, List<JobApplication>>>(
        future: _futureApplications,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No job applications found.'));
          }

          final applicationsByStatus = snapshot.data!;

          return ListView(
            children: applicationsByStatus.entries.map<Widget>((entry) {
              final status = entry.key;
              final applications = entry.value;

              return ExpansionTile(
                title: Text(status, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                children: applications.map<Widget>((application) {
                  return JobApplicationCard(application: application); // If you made JobApplicationCard
                  // OR if you didn't make JobApplicationCard yet, you can replace with ListTile like this:
                  // return ListTile(
                  //   title: Text(application.jobTitle),
                  //   subtitle: Text('Company: ${application.companyName}'),
                  // );
                }).toList(),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
