import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../commun/Pdf_Upload.dart';

class ApplyToJobPage extends StatefulWidget {
  final int jobId;
  final int userId;

  const ApplyToJobPage({required this.jobId, required this.userId, Key? key}) : super(key: key);

  @override
  State<ApplyToJobPage> createState() => _ApplyToJobPageState();
}

class _ApplyToJobPageState extends State<ApplyToJobPage> {
  Map<String, dynamic>? jobDetails;
  Map<String, dynamic>? userProfile;
  bool isLoading = true;
  bool isAvailable = true;
  final TextEditingController salaryController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  bool hasTappedMessage = false; // Pour gérer le premier clic

  String? cvPath;
  String? coverLetterPath;

  @override
  void initState() {
    super.initState();
    messageController.text = "I am interested in this role and meet the requirements.";
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final jobResponse = await http.get(Uri.parse('http://10.0.2.2:8000/api/jobs/job-details/${widget.jobId}/'));
      final profileResponse = await http.get(Uri.parse('http://10.0.2.2:8000/api/get_profile/${widget.userId}/'));
      if (jobResponse.statusCode == 200 && profileResponse.statusCode == 200) {
        setState(() {
          jobDetails = jsonDecode(jobResponse.body);
          userProfile = jsonDecode(profileResponse.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load job or profile data');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  Future<void> submitApplication() async {
    try {
      final Map<String, dynamic> data = {
        "user_id": widget.userId,
        "job_id": widget.jobId,
        "message": messageController.text,
        "expected_salary": salaryController.text.isNotEmpty ? double.parse(salaryController.text) : null,
        "available_now": isAvailable,
      };

      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/apply_to_job/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Application submitted successfully!')),
        );
        Navigator.pop(context);
      } else {
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${errorData['error'] ?? 'Unknown error'}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Widget buildFileUpload(String label, Function(String) onSelected) {
    return Column(
      children: [
        Text(label),
        SizedBox(height: 8),
        PdfUpload(
          onFilesSelected: (List<String> files) {
            if (files.isNotEmpty) {
              onSelected(files[0]);
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Apply to Job Offer')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (jobDetails == null || userProfile == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Apply to Job Offer')),
        body: Center(child: Text("Failed to load job or user data.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Apply to Job Offer')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text("Job Title: ${jobDetails?['title'] ?? 'Unknown'} - ${jobDetails?['contract_type'] ?? ''}"),
            Text("Company: ${jobDetails?['company_name'] ?? 'Unknown'}"),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("• ${userProfile?['profile']?['full_name'] ?? 'Unknown'}"),
                  Text("• ${userProfile?['email'] ?? 'Unknown'}"),
                  Text("• ${userProfile?['profile']?['phone'] ?? 'Unknown'}"),
                ]),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("• Salary: \$${jobDetails?['salary'] ?? 'N/A'}/hour"),
                  Text("• Location: ${jobDetails?['location'] ?? 'N/A'}"),
                  Text("• Working Hours: ${jobDetails?['working_hours'] ?? 'N/A'}"),
                ]),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildFileUpload("Upload Your CV", (path) {
                  setState(() {
                    cvPath = path;
                  });
                }),
                buildFileUpload("Upload a Cover Letter", (path) {
                  setState(() {
                    coverLetterPath = path;
                  });
                }),
              ],
            ),
            SizedBox(height: 20),
            Text("Are you available to start immediately?"),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: Text("Yes"),
                    value: true,
                    groupValue: isAvailable,
                    onChanged: (value) => setState(() => isAvailable = value!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: Text("No"),
                    value: false,
                    groupValue: isAvailable,
                    onChanged: (value) => setState(() => isAvailable = value!),
                  ),
                ),
              ],
            ),
            if (jobDetails?['is_salary_negotiable'] == true)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Salary Negotiation", style: TextStyle(fontWeight: FontWeight.bold)),
                  TextField(
                    controller: salaryController,
                    decoration: InputDecoration(hintText: "Enter your expected salary..."),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            SizedBox(height: 20),
            Text("Message:"),
            TextField(
              controller: messageController,
              maxLines: 3,
              onTap: () {
                if (!hasTappedMessage) {
                  setState(() {
                    messageController.clear();
                    hasTappedMessage = true;
                  });
                }
              },
              decoration: InputDecoration(
                hintText: "I am interested in this role",
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: submitApplication,
              child: Text("Submit Application"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}
