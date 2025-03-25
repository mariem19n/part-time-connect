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

  // Factory constructor to create Job from JSON
  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'],
      title: json['title'] ?? 'No Title Provided',
      description: json['description'] ?? '',
      location: json['location'] ?? 'Remote',
      salary: (json['salary'] ?? 0.0).toDouble(),
      workingHours: json['working_hours'] ?? 'Flexible',
      contractType: json['contract_type'] ?? 'Unknown',
      duration: json['duration'] ?? 0,
      requirements: List<String>.from(json['requirements'] ?? []),
      benefits: List<String>.from(json['benefits'] ?? []),
      responsibilities: List<String>.from(json['responsibilities'] ?? []),
      contractPdf: json['contract_pdf'],
    );
  }
}
