// lib/Job_Provider/candidate_card.dart
import 'package:flutter/material.dart';
import '../AppColors.dart';
import '../Job_seeker/ProfilePage.dart';
import '../chat/ChatScreen.dart';
import 'interaction_service.dart';


class CandidateCard extends StatelessWidget {
  final dynamic candidate; // Using dynamic since we don't have a Candidate model
  final VoidCallback? onTap;

  const CandidateCard({
    Key? key,
    required this.candidate,
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
        //onTap: onTap,
        onTap: () {
          // Record view when card is tapped
          InteractionService.recordView(candidate['id']);
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
                  // Candidate Avatar
                  CircleAvatar(
                    backgroundColor: AppColors.background,
                    child: Text(
                      candidate['username'][0].toUpperCase(),
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name and username
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          candidate['full_name'] ?? 'No name provided',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '@${candidate['username']}',
                          style: TextStyle(
                            color: AppColors.textColor.withOpacity(0.6),
                            fontSize: 14,
                          ),
                        ),
                      ],
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
                            final success = await InteractionService.recordShortlist(candidate['id']);
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Candidate saved to shortlist')),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Tooltip(
                        message: 'View Profile',
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          icon: Icon(Icons.remove_red_eye,
                              color: AppColors.primary,
                              size: 20),
                          /*onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfilePage(userId: candidate['id']),
                              ),
                            );
                          },*/
                          onPressed: () {
                            InteractionService.recordView(candidate['id']);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfilePage(userId: candidate['id']),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Tooltip(
                        message: 'Message',
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          icon: Icon(Icons.message,
                              color: AppColors.primary,
                              size: 20),
                          /*onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  receiverId: candidate['id'].toString(),
                                  receiverType: 'user',
                                  receiverName: candidate['username'],
                                ),
                              ),
                            );
                          },*/
                          onPressed: () async {
                            final success = await InteractionService.recordContact(candidate['id']);
                            if (success) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    receiverId: candidate['id'].toString(),
                                    receiverType: 'user',
                                    receiverName: candidate['username'],
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // About section
              if (candidate['about_me'] != null && candidate['about_me'].isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      candidate['about_me'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                  ],
                ),

              // Skills section
              if (candidate['skills'] != null && candidate['skills'].isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Skills',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: (candidate['skills'] as List)
                          .take(3) // Show only first 3 skills
                          .map((skill) => Chip(
                        label: Text(skill),
                        backgroundColor: AppColors.background,
                        labelStyle: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                        ),
                        visualDensity: VisualDensity.compact,
                      ))
                          .toList(),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}