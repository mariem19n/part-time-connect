class JobApplication {
  final int id;
  final String jobTitle;
  final String status;
  final String companyName;

  JobApplication({
    required this.id,
    required this.jobTitle,
    required this.status,
    required this.companyName,
  });

  factory JobApplication.fromJson(Map<String, dynamic> json) {
    return JobApplication(
      id: json['id'],
      jobTitle: json['job_title'],
      status: json['status'],
      companyName: json['company_name'],
    );
  }
}
