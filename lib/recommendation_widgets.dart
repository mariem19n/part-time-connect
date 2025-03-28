import 'package:flutter/material.dart';

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

        // View All button
        Padding(
          padding: EdgeInsets.only(right: 16, top: 4),
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
              ),
              onPressed: () => _navigateToFullList(context),
              child: Text(
                'View All →',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
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
          onTap: () => _showItemDetails(context, item),
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
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Spacer(),

                // Score chip
                Align(
                  alignment: Alignment.bottomRight,
                  child: Chip(
                    label: Text(
                      item['score']?.toStringAsFixed(1) ?? '0.0',
                      style: TextStyle(fontSize: 12),
                    ),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToFullList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullRecommendationsPage(
          items: items,
          type: type,
        ),
      ),
    );
  }

  void _showItemDetails(BuildContext context, dynamic item) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item['title'] ?? item['name'],
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              type == 'jobs'
                  ? 'Company: ${item['company']}'
                  : 'Skills: ${item['skills'].join(', ')}',
            ),
            SizedBox(height: 8),
            Text('Score: ${item['score']?.toStringAsFixed(1) ?? 'N/A'}'),
          ],
        ),
      ),
    );
  }
}

class FullRecommendationsPage extends StatelessWidget {
  final List<dynamic> items;
  final String type;

  const FullRecommendationsPage({
    required this.items,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(type == 'jobs' ? 'All Job Listings' : 'All Candidates'),
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(12),
        itemCount: items.length,
        separatorBuilder: (_, __) => SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              title: Text(
                item['title'] ?? item['name'],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4),
                  Text(
                    type == 'jobs'
                        ? 'Company: ${item['company']}'
                        : 'Skills: ${item['skills'].join(', ')}',
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Text('Score: '),
                      Chip(
                        label: Text(
                          item['score']?.toStringAsFixed(1) ?? '0.0',
                          style: TextStyle(fontSize: 12),
                        ),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ],
              ),
              onTap: () {}, // Add detailed view if needed
            ),
          );
        },
      ),
    );
  }
}