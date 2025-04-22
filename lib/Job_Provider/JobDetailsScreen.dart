import 'package:flutter/material.dart';
import 'PostJobScreen.dart';
import 'job.dart';
import 'jobfetch_service.dart';
import '../AppColors.dart';
import '../auth_helper.dart';
class JobDetailsScreen extends StatefulWidget {
  final int jobId;

  JobDetailsScreen({required this.jobId});

  @override
  _JobDetailsScreenState createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  late Future<Job> jobDetails;
  late Future<String?> companyUsername;
  late Future<String?> userType;

  @override
  void initState() {
    super.initState();
    jobDetails = JobService.fetchJobDetails(widget.jobId);
    companyUsername = getUsername();
    userType = getUserType();
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 14),
                            FutureBuilder<String?>(
                              future: companyUsername,
                              builder: (context, usernameSnapshot) {
                                return RichText(
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  text: TextSpan(
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: AppColors.textColor,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: job.title,
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(text: " | "),
                                      TextSpan(
                                        text: usernameSnapshot.data ?? 'Unknown Company',
                                        style: TextStyle(fontWeight: FontWeight.normal),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 4),
                          ],
                        ),
                      ),
                      FutureBuilder<String?>(
                        future: getUserType(),
                        builder: (context, userTypeSnapshot) {
                          if (userTypeSnapshot.data == 'JobProvider') {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Tooltip(
                                  message: 'Edit',
                                  child: IconButton(
                                    icon: Icon(Icons.edit, color: AppColors.borderdarkColor),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PostJobScreen(existingJob: job),
                                        ),
                                      ).then((_) {
                                        setState(() {
                                          jobDetails = JobService.fetchJobDetails(widget.jobId);
                                        });
                                      });
                                    },
                                  ),
                                ),
                                Tooltip(
                                  message: 'Delete',
                                  child: IconButton(
                                    icon: Icon(Icons.delete, color: AppColors.errorBackground),
                                    onPressed: () => _confirmDelete(context, job.id),
                                  ),
                                ),
                              ],
                            );
                          } else if (userTypeSnapshot.data == 'JobSeeker') {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Tooltip(
                                  message: 'Save',
                                  child: IconButton(
                                    icon: Icon(Icons.bookmark_border, color: AppColors.borderdarkColor),
                                    onPressed: () => _confirmDelete(context, job.id),
                                    ),
                                ),
                                Tooltip(
                                  message: 'Apply',
                                  child: IconButton(
                                    icon: Icon(Icons.assignment_turned_in, color: AppColors.primary),
                                    onPressed: () => _confirmDelete(context, job.id),
                                ),
                                ),
                              ],
                            );
                          }
                          return SizedBox();
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Job Description",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
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
                      color: AppColors.textColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildBulletList([
                    "Location: ${job.location}",
                    "Salary: \$${job.salary}/hour" /*(Negotiable for premium users)*/,
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
                      color: AppColors.textColor,
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
                      color: AppColors.textColor,
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
                      color: AppColors.textColor,
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
  Widget _buildBulletList(dynamic items) {
    if (items == null) return SizedBox();

    // Handle Map case (for requirements)
    if (items is Map) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (items['skills'] != null && (items['skills'] as List).isNotEmpty) ...[
            Text('Skills:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...(items['skills'] as List).where((e) => e != null && e.toString().isNotEmpty).map<Widget>((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("• "),
                    Expanded(child: Text(item.toString())),
                  ],
                ),
              );
            }).toList(),
          ],
          if (items['experience'] != null && (items['experience'] as List).isNotEmpty) ...[
            SizedBox(height: 8),
            Text('Experience:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...(items['experience'] as List).where((e) => e != null && e.toString().isNotEmpty).map<Widget>((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("• "),
                    Expanded(child: Text(item.toString())),
                  ],
                ),
              );
            }).toList(),
          ],
        ],
      );
    }

    // Handle List case (for benefits)
    if (items is List) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.where((e) => e != null && e.toString().isNotEmpty).map<Widget>((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("• "),
                Expanded(child: Text(item.toString())),
              ],
            ),
          );
        }).toList(),
      );
    }

    return SizedBox();
  }
  Future<void> _confirmDelete(BuildContext context, int jobId) async {
    final token = await getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication required')),
      );
      return;
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this job posting?'),
                Text('This action cannot be undone.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text(
                'Delete',
                style: TextStyle(color: AppColors.errorBackground),
              ),
              onPressed: () async {
                try {
                  await JobService.deleteJob(jobId, token);
                  if (mounted) {
                    Navigator.of(context).pop(); // Close dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Job deleted successfully')),
                    );
                    Navigator.of(context).pop(); // Go back to previous screen
                  }
                } catch (e) {
                  if (mounted) {
                    Navigator.of(context).pop(); // Close dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to delete job: $e')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }


}