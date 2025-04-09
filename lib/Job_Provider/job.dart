import 'dart:convert';

class Job {
  final int id;
  final String title;
  final String description;
  final String location;
  final double salary;
  final String workingHours;
  final String contractType;
  final int duration;
  final List<String> requirements;
  final List<String> benefits;
  final List<String> responsibilities;
  final String? contractPdf;

  Job({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.salary,
    required this.workingHours,
    required this.contractType,
    required this.duration,
    required this.requirements,
    required this.benefits,
    required this.responsibilities,
    this.contractPdf,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert to List<String>
    List<String> _convertList(dynamic list) {
      if (list == null) return [];
      if (list is List) return list.map((e) => e?.toString() ?? '').toList();
      return [list?.toString() ?? ''];
    }

    // Handle requirements - always convert to List<String>
    List<String> requirements = [];
    if (json['requirements'] != null) {
      if (json['requirements'] is String) {
        try {
          // If it's a JSON string, decode and extract skills
          final decoded = jsonDecode(json['requirements']);
          if (decoded is Map) {
            requirements = _convertList(decoded['skills'] ?? []);
          } else {
            requirements = _convertList(decoded);
          }
        } catch (e) {
          requirements = _convertList(json['requirements']);
        }
      } else if (json['requirements'] is Map) {
        // If it's already a map, extract skills
        requirements = _convertList(json['requirements']['skills'] ?? []);
      } else {
        requirements = _convertList(json['requirements']);
      }
    }

    return Job(
      id: json['id'] as int? ?? 0,
      title: json['title']?.toString() ?? 'No Title',
      description: json['description']?.toString() ?? '',
      location: json['location']?.toString() ?? 'Remote',
      salary: (json['salary'] as num?)?.toDouble() ?? 0.0,
      workingHours: json['working_hours']?.toString() ?? 'Flexible',
      contractType: json['contract_type']?.toString() ?? 'Unknown',
      duration: json['duration'] as int? ?? 0,
      requirements: requirements, // Now always List<String>
      benefits: _convertList(json['benefits']),
      responsibilities: _convertList(json['responsibilities']),
      contractPdf: json['contract_pdf']?.toString(),
    );
  }
}