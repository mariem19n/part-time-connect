import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'job.dart';
import '../AppColors.dart';
import '../auth_helper.dart';
import '../commun/Pdf_Upload.dart';

class PostJobScreen extends StatefulWidget {
  final Job? existingJob;
  const PostJobScreen({super.key, this.existingJob});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  String _workingHours = 'Flexible';
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
  void initState() {
    super.initState();
    // Initialize form fields with existing job data if provided
    if (widget.existingJob != null) {
      _initializeFormWithJob(widget.existingJob!);
    }
  }

  void _initializeFormWithJob(Job job) {
    // Parse working hours
    String fromTime = '18h';
    String toTime = '23h';
    String workingHoursDisplay = 'Flexible';

    if (job.workingHours != null && job.workingHours!.contains('to')) {
      final parts = job.workingHours!.split(' to ');
      if (parts.length == 2) {
        fromTime = parts[0].trim();
        toTime = parts[1].trim();
        workingHoursDisplay = '$fromTime to $toTime';
      }
    }

    // Parse duration
    String durationDisplay = 'duration';
    if (job.duration > 0) {
      durationDisplay = job.duration == 1
          ? '1 month'
          : '${job.duration} months';
    }
    setState(() {
      _jobTitleController.text = job.title;
      _descriptionController.text = job.description;
      _responsibilitiesController.text = job.responsibilities.join('\n');
      _skillsController.text = job.requirements.join('\n');
      _benefitsController.text = job.benefits.join('\n');
      _location = job.location.toLowerCase();
      _duration = durationDisplay;
      _fromTime = fromTime;
      _toTime = toTime;
      _workingHours = workingHoursDisplay;
      _contractType = job.contractType;
      _salary = job.salary;
      _salaryUnit = 'per hour'; // Default or parse from existing data
      // PDF contract
      if (job.contractPdf != null && job.contractPdf!.isNotEmpty) {
        _uploadedPdfPaths = [job.contractPdf!];
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingJob == null
            ? 'Post a New Job Offer'
            : 'Edit Job Offer'),
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
                              final token = await getToken();
                              final username = await getUsername();
                              print('DEBUG: Username is $username');

                              if (token == null || username == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please login first')),
                                );
                                return;
                              }
                              final requirements = {
                                'skills': _skillsController.text.split('\n')
                                    .where((s) => s.trim().isNotEmpty)
                                    .toList(),
                                'experience': _experienceController.text.split('\n')
                                    .where((s) => s.trim().isNotEmpty)
                                    .toList()
                              };

                              // Prepare the job data as flat fields
                              final jobData = {
                                'company_username': username,
                                'title': _jobTitleController.text,
                                'description': _descriptionController.text,
                                'location': _location,
                                'salary': _salary.toString(),
                                'is_salary_negotiable': 'false',
                                'working_hours': '$_fromTime to $_toTime',
                                'duration': (_duration == 'duration' ? 0 : int.parse(_duration.split(' ')[0])).toString(),
                                'contract_type': _contractType,
                                'requirements': jsonEncode(requirements),
                                'benefits': jsonEncode(_benefitsController.text.split('\n')),
                                'responsibilities': jsonEncode(_responsibilitiesController.text.split('\n')),
                                if (widget.existingJob != null) 'job_id': widget.existingJob!.id.toString(),
                              };

                              // Create request
                              var request = http.MultipartRequest(
                                widget.existingJob == null ? 'POST' : 'PUT',
                                Uri.parse('http://10.0.2.2:8000/api/jobs/offer/'),
                              );

                              // Add authorization header
                              request.headers['Authorization'] = 'Bearer $token';

                              // Flatten jobData into individual request fields
                              jobData.forEach((key, value) {
                                request.fields[key] = value.toString();
                              });

                              // Attach PDF if provided
                              if (_uploadedPdfPaths.isNotEmpty) {
                                var file = await http.MultipartFile.fromPath(
                                  'contract_pdf',
                                  _uploadedPdfPaths[0],
                                );
                                request.files.add(file);
                              }

                              // Debug print
                              print('Sending job data: $jobData');
                              if (_uploadedPdfPaths.isNotEmpty) {
                                print('Attaching PDF: ${_uploadedPdfPaths[0]}');
                              }

                              try {
                                var response = await request.send();
                                var responseData = await response.stream.bytesToString();

                                print('Response status: ${response.statusCode}');
                                print('Response body: $responseData');

                                if (response.statusCode == 200 || response.statusCode == 201) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(
                                        widget.existingJob == null
                                            ? 'Job posted successfully!'
                                            : 'Job updated successfully!'
                                    )),
                                  );
                                  Navigator.of(context).pop();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: ${jsonDecode(responseData)['message']}')),
                                  );
                                }
                              } catch (e) {
                                print('Error sending request: $e');
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
