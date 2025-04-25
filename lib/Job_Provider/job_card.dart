// lib/Job_Provider/job_card.dart
import 'package:flutter/material.dart';
import '../Job_Provider/job.dart';
import '../AppColors.dart';
import 'JobDetailsScreen.dart';
import 'job_interaction_service.dart';
class JobCard extends StatelessWidget {
  final Job job;
  final VoidCallback? onTap;

  const JobCard({
    Key? key,
    required this.job,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          JobInteractionService.recordView(job.id);
          if (onTap != null) onTap!();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      job.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Action buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Tooltip(
                        message: 'Save',
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          icon: Icon(Icons.bookmark_border,
                              color: AppColors.borderdarkColor,
                              size: 20),
                          onPressed: () async {
                            final result = await JobInteractionService.recordSave(job.id);
                            if (result['success'] == true) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Job saved successfully')),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to save job: ${result['message']}')),
                              );
                            }
                          },
                        ),
                  ),
                      const SizedBox(width: 8),
                      Tooltip(
                        message: 'Detail',
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          icon: Icon(Icons.remove_red_eye,
                              color: AppColors.primary,
                              size: 20),
                          onPressed: () async {
                            final result = await JobInteractionService.recordView(job.id);
                            if (result['success'] == true) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => JobDetailsScreen(jobId: job.id),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),

              const SizedBox(height: 8),
                ],
              ),

              const SizedBox(height: 8),

              // Description
              Text(
                job.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const SizedBox(height: 12),

              // Meta info
              Wrap(
                spacing: 12,
                children: [
                  _buildMetaInfo(Icons.location_on, job.location),
                  _buildMetaInfo(Icons.attach_money, job.salary.toString()),
                  _buildMetaInfo(Icons.work, job.contractType),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: AppColors.textColor)),
      ],
    );
  }
}