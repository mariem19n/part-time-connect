import 'package:flutter/material.dart';
import 'package:flutter_projects/AppColors.dart';

import 'Job_Provider/JobDetailsScreen.dart';
import 'Job_Provider/interaction_service.dart';
import 'Job_Provider/job_interaction_service.dart';
import 'Job_seeker/ProfilePage.dart';

class LLMRecommendationPreview extends StatelessWidget {
  final List<dynamic> items;
  final String type; // 'jobs' or 'candidates'
  final VoidCallback onRefresh;

  const LLMRecommendationPreview({
    required this.items,
    required this.type,
    required this.onRefresh,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                'CV Powered Recommendations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              IconButton(
                icon: Icon(Icons.refresh, size: 20),
                onPressed: onRefresh,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 220,
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
      width: 180,
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
                Text(
                  item['title'] ?? item['name'] ?? 'Untitled',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6),
                Text(
                  type == 'jobs'
                      ? item['company'] ?? 'No company'
                      : (item['skills'] as List<dynamic>?)?.join(', ') ?? 'No skills',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.borderdarkColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item['score'] != null) ...[
                  SizedBox(height: 6),
                  Text(
                    'Match: ${(item['score'] * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                if (item['summary'] != null) ...[
                  SizedBox(height: 6),
                  Text(
                    item['summary']!,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.borderdarkColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                Spacer(),
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
      final jobId = item['job_id']; // ✅ Correction ici
      if (jobId != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JobDetailsScreen(jobId: jobId),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ID manquant pour ce job')),
        );
      }
    } else {
      final userId = item['id']; // Pour les candidats
      if (userId != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(userId: userId),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ID manquant pour ce candidat')),
        );
      }
    }
  }

  Future<void> _handleSaveItem(BuildContext context, dynamic item) async {
    try {
      bool success;

      if (type == 'jobs') {
        final result = await JobInteractionService.recordSave(item['job_id']);
        success = result['success'] ?? false;

        if (!success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Échec de l\'enregistrement: ${result['message']}'),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }
      } else {
        final result = await InteractionService.recordShortlist(item['id']);
        success = result['success'] ?? false;

        if (!success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Échec de la sélection du candidat'),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            type == 'jobs'
                ? 'Job enregistré avec succès'
                : 'Candidat ajouté à la liste',
          ),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Erreur: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
