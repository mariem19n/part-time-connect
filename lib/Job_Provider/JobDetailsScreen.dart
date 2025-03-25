import 'package:flutter/material.dart';
import 'job.dart';
import 'jobfetch_service.dart';
import '../AppColors.dart';

class JobDetailsScreen extends StatefulWidget {
  final int jobId;

  JobDetailsScreen({required this.jobId});

  @override
  _JobDetailsScreenState createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  late Future<Job> jobDetails;

  @override
  void initState() {
    super.initState();
    jobDetails = JobService.fetchJobDetails(widget.jobId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Job>(
        future: jobDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return Center(child: Text("No job details found."));
          } else {
            Job job = snapshot.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 24),
                  // Job Title with Edit Icon and Company
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              job.title,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Company: Creative Solutions Inc.",
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.borderdarkColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, color: AppColors.primary),
                        onPressed: () {
                          // Edit job offer functionality
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Job Description Section
                  Text(
                    "Job Description",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                      job.description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.borderdarkColor,
                      ),
                  ),
                  SizedBox(height: 20),
                  // Key Details Section
                  Text(
                    "Key Details",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildBulletList([
                    "Location: Remote",
                    "Salary: \$${job.salary}/hour (Negotiable for premium users)",
                    "Working Hours: ${job.workingHours}",
                    "Period of Time Required: ${job.duration} months",
                    "Contract Type: ${job.contractType}",
                  ]),
                  SizedBox(height: 20),
                  // Requirements Section
                  Text(
                    "Requirements",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildBulletList(job.requirements),
                  SizedBox(height: 20),

                  // Benefits Section
                  Text(
                    "Benefits",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildBulletList(job.benefits),
                  SizedBox(height: 20),

                  // Contract Section
                  Text(
                    "Contract",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildBulletList([
                    "Position: ${job.title}",
                    "Duration: ${job.duration} months",
                    "Responsibilities: ${job.responsibilities.join(", ")}",
                  ]),
                  SizedBox(height: 16),
                  if (job.contractPdf != null && job.contractPdf!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: TextButton.icon(
                        icon: Icon(Icons.picture_as_pdf, color: AppColors.primary),
                        label: Text(
                          "View Full Contract (PDF Format)",
                          style: TextStyle(color: AppColors.primary),
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: AppColors.borderColor),
                          ),
                        ),
                        onPressed: () {
                          // Add your PDF viewing logic here
                          print('Opening PDF: ${job.contractPdf}');
                          // Example: launchUrl(Uri.parse(job.contractPdf!));
                        },
                      ),
                    ),
                  SizedBox(height: 24),
                  SizedBox(height: 20),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildBulletList(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map<Widget>((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("• "),
              Expanded(
                child: Text(item),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

}