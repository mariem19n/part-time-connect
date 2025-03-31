import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../AppColors.dart';
import '../auth_helper.dart';
import '../commun/Pdf_Upload.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  List<String> _uploadedPdfPaths = [];
  final _formKey = GlobalKey<FormState>();
  final _jobTitleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _responsibilitiesController = TextEditingController();
  final _skillsController = TextEditingController();
  final _experienceController = TextEditingController();
  final _benefitsController = TextEditingController();

  String _location = 'remote';
  String _duration = 'duration';
  String _fromTime = '18h';
  String _toTime = '23h';
  String _salaryUnit = 'per hour';
  String _contractType = 'Part-Time';
  double _salary = 40.0;

  @override
  void dispose() {
    _jobTitleController.dispose();
    _descriptionController.dispose();
    _responsibilitiesController.dispose();
    _skillsController.dispose();
    _experienceController.dispose();
    _benefitsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post a New Job Offer'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fill out the details below to create a job offer that attracts the right candidates.',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.borderdarkColor,
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
                    'Job title',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _jobTitleController,
                    cursorColor: AppColors.primary,
                    decoration: InputDecoration(
                      hintText: 'Enter the job title (e.g., Graphic Designer)',
                    ),
                    style: const TextStyle(color: AppColors.borderdarkColor),
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
                    'Job description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    cursorColor: AppColors.primary,
                    decoration: InputDecoration(
                      hintText: 'Provide a detailed job description',
                    ),
                    style: const TextStyle(color: AppColors.borderdarkColor),
                    maxLines: 5,
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
                    'Responsibilities:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _responsibilitiesController,
                    cursorColor: AppColors.primary,
                    decoration: InputDecoration(
                      hintText: 'List key responsibilities of the role',
                    ),
                    style: const TextStyle(color: AppColors.borderdarkColor),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter responsibilities';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Location Section
                  const Text(
                    'Location',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _location,
                    items: ['remote', 'on-site', 'hybrid'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _location = newValue!;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Working Period Section
                  const Text(
                    'Working period',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        flex: 2, // Give more space to duration dropdown
                        child: DropdownButtonFormField<String>(
                          value: _duration,
                          items: ['duration', '1 month', '3 months', '6 months', '1 year']
                              .map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _duration = newValue!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _fromTime,
                          items: List.generate(24, (index) => '${index}h').map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _fromTime = newValue!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text('To'),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _toTime,
                          items: List.generate(24, (index) => '${index}h').map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _toTime = newValue!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Salary Section
                  const Text(
                    'Salary/Wage',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        flex: 3, // Give more space to salary input
                        child: TextFormField(
                          controller: TextEditingController(text: _salary.toString()),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              _salary = double.tryParse(value) ?? 0.0;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2, // Less space for unit dropdown
                        child: DropdownButtonFormField<String>(
                          value: _salaryUnit,
                          items: ['per hour', 'per day', 'per month', 'per project'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _salaryUnit = newValue!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Contract Type Section
                  const Text(
                    'Contract Type:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _contractType,
                    items: ['Part-Time', 'Full-Time', 'Freelance', 'Internship'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _contractType = newValue!;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Requirements Section
                  const Text(
                    'Requirements:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'skills:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextFormField(
                    controller: _skillsController,
                    cursorColor: AppColors.primary,
                    decoration: InputDecoration(
                      hintText: 'List required skills',
                    ),
                    style: const TextStyle(color: AppColors.borderdarkColor),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'experience:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextFormField(
                    controller: _experienceController,
                    cursorColor: AppColors.primary,
                    decoration: InputDecoration(
                      hintText: 'List required experience',
                    ),
                    style: const TextStyle(color: AppColors.borderdarkColor),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 20),

                  // Additional Details Section
                  const Text(
                    'Additional Details (Optional):',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _benefitsController,
                    cursorColor: AppColors.primary,
                    decoration: InputDecoration(
                      hintText: 'Any perks, benefits, or specific terms...',
                    ),
                    style: const TextStyle(color: AppColors.borderdarkColor),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),

                  // Upload Contract Section
                  const Text(
                    'Upload Contract',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  PdfUpload(
                    onFilesSelected: (filePaths) {
                      setState(() {
                        _uploadedPdfPaths = filePaths;
                      });
                      print('Uploaded PDFs: $filePaths');
                    },
                  ),
                  const SizedBox(height: 30),

                  // Submit and Cancel Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _resetForm,
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            // Get the authentication token
                            final token = await getToken();
                            final username = await getUsername();
                            print('Stored token: $token, username: $username');
                            if (token == null || username == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please login first')),
                              );
                              return;
                            }

                            // Prepare job details
                            final jobDetails = {
                              'company_username': username,
                              'title': _jobTitleController.text,
                              'description': _descriptionController.text,
                              'responsibilities': jsonEncode(_responsibilitiesController.text.split('\n')),
                              'location': _location,
                              'duration': _duration == 'duration' ? 0 : int.parse(_duration.split(' ')[0]),
                              'working_hours': '$_fromTime to $_toTime',
                              'salary': _salary,
                              'is_salary_negotiable': false,
                              'contract_type': _contractType,
                              'requirements': jsonEncode({
                                'skills': _skillsController.text.split('\n'),
                                'experience': _experienceController.text.split('\n')
                              }),
                              'benefits': jsonEncode(_benefitsController.text.split('\n')),
                            };

                            // Create multipart request
                            var request = http.MultipartRequest(
                                'POST',
                                Uri.parse('http://10.0.2.2:8000/api/jobs/offer/')
                            );

                            // Add headers with the token
                            request.headers['Authorization'] = 'Bearer $token';
                            request.headers['Content-Type'] = 'multipart/form-data';

                            // Add fields
                            jobDetails.forEach((key, value) {
                              request.fields[key] = value.toString();
                            });

                            // Add file if exists
                            if (_uploadedPdfPaths.isNotEmpty) {
                              var file = await http.MultipartFile.fromPath(
                                  'contract_pdf',
                                  _uploadedPdfPaths[0]
                              );
                              request.files.add(file);
                            }

                            // Send request
                            try {
                              var response = await request.send();
                              var responseData = await response.stream.bytesToString();

                              if (response.statusCode == 201) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Job posted successfully!')),
                                );
                                Navigator.of(context).pop();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: ${jsonDecode(responseData)['message']}')),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          }
                        },
                        child: const Text('Submit Job Offer'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      /*bottomNavigationBar: const CustomBottomNavBar(
        isJobSeeker: false,
        currentIndex: 2, // Assuming "add offer" is at index 2
        onTap: null, // You'll need to implement navigation
      ),*/
    );
  }
  void _resetForm() {
    setState(() {
      // Clear all text controllers
      _jobTitleController.clear();
      _descriptionController.clear();
      _responsibilitiesController.clear();
      _skillsController.clear();
      _experienceController.clear();
      _benefitsController.clear();

      // Reset dropdown values
      _location = 'remote';
      _duration = 'duration';
      _fromTime = '18h';
      _toTime = '23h';
      _salaryUnit = 'per hour';
      _contractType = 'Part-Time';
      _salary = 40.0;

      // Clear uploaded PDFs
      _uploadedPdfPaths.clear();

      // Optional: Reset form validation state
      _formKey.currentState?.reset();
    });
  }
}
