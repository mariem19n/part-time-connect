import 'package:flutter/material.dart';
import '../models/job_application_model.dart';
class JobApplicationCard extends StatelessWidget {
  final JobApplication application;

  const JobApplicationCard({Key? key, required this.application}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(application.jobTitle),
        subtitle: Text('Company: ${application.companyName}'),
      ),
    );
  }
}
