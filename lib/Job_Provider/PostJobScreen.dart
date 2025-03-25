import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../AppColors.dart';
import '../auth_helper.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _jobTitleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _salaryController = TextEditingController();
  final _workingHoursController = TextEditingController();
  final _durationController = TextEditingController();
  final _contractTypeController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _benefitsController = TextEditingController();
  final _responsibilitiesController = TextEditingController();
  bool _isSalaryNegotiable = false;

  @override
  void dispose() {
    _jobTitleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _salaryController.dispose();
    _workingHoursController.dispose();
    _durationController.dispose();
    _contractTypeController.dispose();
    _requirementsController.dispose();
    _benefitsController.dispose();
    _responsibilitiesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add a text widget for "Post Job Offer"
            const Text(
              'Post Job Offer',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,  // Title in black
              ),
            ),
            const SizedBox(height: 20),

            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Job Title Section
                  const Text(
                    'Job Title',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor, // Title in black
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _jobTitleController,
                    cursorColor: AppColors.primary, // Green cursor
                    decoration: InputDecoration(
                      hintText: 'Enter job title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                    style: const TextStyle(color: AppColors.borderdarkColor), // Dark gray text
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a job title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Job Description Section
                  const Text(
                    'Job Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor, // Title in black
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    cursorColor: AppColors.primary, // Green cursor
                    decoration: InputDecoration(
                      hintText: 'Enter job description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                    style: const TextStyle(color: AppColors.borderdarkColor), // Dark gray text
                    maxLines: null,  // Box will expand with content
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a job description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Responsibilities Section
                  const Text(
                    'Responsibilities',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor, // Title in black
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _responsibilitiesController,
                    cursorColor: AppColors.primary, // Green cursor
                    decoration: InputDecoration(
                      hintText: 'Enter responsibilities (one per line)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                    style: const TextStyle(color: AppColors.borderdarkColor), // Dark gray text
                    maxLines: null,  // Box will expand with content
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter responsibilities';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Add other sections similarly

                  // Submit Button
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          // Prepare job details
                          final jobDetails = {
                            'title': _jobTitleController.text,
                            'description': _descriptionController.text,
                            'location': _locationController.text,
                            'salary': double.tryParse(_salaryController.text),
                            'is_salary_negotiable': _isSalaryNegotiable,
                            'working_hours': _workingHoursController.text,
                            'duration': int.tryParse(_durationController.text),
                            'contract_type': _contractTypeController.text,
                            'requirements': _requirementsController.text.split('\n'),
                            'benefits': _benefitsController.text.split('\n'),
                            'responsibilities': _responsibilitiesController.text.split('\n'),
                          };

                          // Send job details to the backend
                          final response = await http.post(
                            Uri.parse('http://10.0.2.2:8000/jobs/create/'), // Replace with your API endpoint
                            body: json.encode(jobDetails),
                          );
                        }
                      },
                      child: const Text('Post Job Offer'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
