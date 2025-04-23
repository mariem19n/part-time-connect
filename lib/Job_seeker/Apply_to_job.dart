import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
  final TextEditingController messageController = TextEditingController(text: "I am interested in this role and meet the requirements.");

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final jobResponse = await http.get(Uri.parse('http://yourbackend.com/job_details/${widget.jobId}'));
    final profileResponse = await http.get(Uri.parse('http://yourbackend.com/get_profile/${widget.userId}'));

    if (jobResponse.statusCode == 200 && profileResponse.statusCode == 200) {
      setState(() {
        jobDetails = jsonDecode(jobResponse.body);
        userProfile = jsonDecode(profileResponse.body);
        isLoading = false;
      });
    }
  }

  Widget buildFileUpload(String label) {
    return Column(
      children: [
        Text(label),
        SizedBox(height: 8),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(8)),
          child: Icon(Icons.add),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text('Apply to Job Offer')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text("Job Title: ${jobDetails!['title']} - ${jobDetails!['contract_type']}"),
            Text("Company: ${jobDetails!['company_name']}"),
            SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("• ${userProfile!['profile']['full_name']}"),
                  Text("• ${userProfile!['email']}"),
                  Text("• ${userProfile!['profile']['phone']}"),
                ]),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("• Salary: \$${jobDetails!['salary']}/hour"),
                  Text("• Location: ${jobDetails!['location']}"),
                  Text("• Working Hours: ${jobDetails!['working_hours']}"),
                ]),
              ],
            ),

            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildFileUpload("Upload Your CV"),
                buildFileUpload("Upload a Cover Letter"),
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

            if (jobDetails!['is_salary_negotiable'] == true)
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
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),

            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Send application to backend (to be implemented)
              },
              child: Text("Submit Application"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}
