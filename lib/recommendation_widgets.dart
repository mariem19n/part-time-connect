import 'package:flutter/material.dart';
import 'package:flutter_projects/AppColors.dart';

import 'Job_Provider/JobDetailsScreen.dart';
import 'Job_Provider/interaction_service.dart';
import 'Job_seeker/ProfilePage.dart';

class RecommendationPreview extends StatelessWidget {
  final List<dynamic> items;
  final String type; // 'jobs' or 'candidates'
  final VoidCallback? onRefresh; // Add refresh callback

  const RecommendationPreview({
    required this.items,
    required this.type,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with optional refresh button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                type == 'jobs' ? 'Recommended Jobs' : 'Top Candidates',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (onRefresh != null) ...[
                Spacer(),
                IconButton(
                  icon: Icon(Icons.refresh, size: 20),
                  onPressed: onRefresh,
                ),
              ],
            ],
          ),
        ),

        // Horizontal scroll cards
        SizedBox(
          height: 180, // Slightly increased height
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 8),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildPreviewCard(item, context);
            },
          ),
        ),

      ],
    );
  }

  Widget _buildPreviewCard(dynamic item, BuildContext context) {
    return Container(
      width: 160, // Slightly wider cards
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _navigateToDetails(context, item),
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title/Name
                Text(
                  item['title'] ?? item['name'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6),

                // Company/Skills
                Text(
                  type == 'jobs'
                      ? item['company'] ?? 'No company'
                      : (item['skills'] as List<dynamic>).join(', '),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.borderdarkColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Spacer(), // This pushes the button to the bottom
                // Save button
                Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                    icon: Icon(
                      Icons.bookmark_border,
                      size: 20,
                      color: AppColors.borderdarkColor,
                    ),
                    onPressed: () => _handleSaveItem(context, item),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  void _navigateToDetails(BuildContext context, dynamic item) {
    if (type == 'jobs') {
      // Navigate to job details page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JobDetailsScreen(jobId: item['id']),
        ),
      );
    } else {
      // Navigate to candidate profile page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(userId: item['id']),
        ),
      );
    }
  }
  Future<void> _handleSaveItem(BuildContext context, dynamic item) async {
    try {
      bool success;

      if (type == 'jobs') {
        // Call job save service (you'll need to implement this)
        print('Saving job: ${item['title']}');
        // Example: success = await JobService.saveJob(item['id']);
        // For now we'll use a placeholder:
        success = true;
      } else {
        // Call candidate shortlist service
        success = await InteractionService.recordShortlist(item['id']);

        if (success) {
          print('Successfully shortlisted candidate: ${item['name']}');
        } else {
          print('Failed to shortlist candidate');
        }
      }

      // Show feedback to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            type == 'jobs'
                ? 'Job saved successfully'
                : 'Candidate added to shortlist',
          ),
          duration: Duration(seconds: 2),
        ),
      );

    } catch (e) {
      print('Error saving item: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save: ${e.toString()}'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

}