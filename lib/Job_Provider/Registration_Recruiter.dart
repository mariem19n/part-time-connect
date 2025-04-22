import 'package:flutter/material.dart';
import '../commun/password_field.dart';
import '../commun/Image_Uploader.dart';
import 'package:flutter_projects/services/RegistrationCompany_service.dart';
import 'package:flutter_projects/commun/Privacy Policy.dart';
import 'package:flutter_projects/commun/Terms and Conditions.dart';
import 'dart:io';
import 'package:flutter/gestures.dart';
import '../AppColors.dart';
import 'package:flutter_projects/Job_seeker/HomePage.dart';


class RegistrationRecruiter extends StatefulWidget {
  const RegistrationRecruiter({super.key});

  @override
  State<RegistrationRecruiter> createState() => _RegistrationRecruiterState();
}

class _RegistrationRecruiterState extends State<RegistrationRecruiter> {
  List<File> _uploadedPhotos = []; // Change to List<File>
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _companyDescriptionController = TextEditingController();
  bool _isTermsAccepted = false;
  String _selectedJobType = '';

  void _handlePhotoUpload(List<File> files) {
    setState(() {
      _uploadedPhotos = files;
    });
    print('Fichiers sélectionnés : ${files.length}');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _companyDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Hi! Let\'s get you registered.',
                style: TextStyle(
                  color: AppColors.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Please provide the following details.',
                style: TextStyle(fontSize: 14, color: AppColors.textColor),
              ),
              const SizedBox(height: 20),
              TextFormField(
                cursorColor: AppColors.primary,
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Company or Organization Name',
                  floatingLabelStyle: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  hintText: 'Enter your Company or Organization name',
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: AppColors.borderColor,
                  ),
                  prefixIcon: const Icon(Icons.person, color: AppColors.borderColor),
                ),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a company name';
                  }
                  if (value.length < 3) {
                    return 'Name must be at least 3 characters long';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                cursorColor:AppColors.primary,
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Professional Email Address',
                  floatingLabelStyle: const TextStyle(
                    color:AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  hintText: 'Enter your professional email address',
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: AppColors.borderColor,
                  ),
                  prefixIcon: const Icon(Icons.email, color: AppColors.borderColor),
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email address';
                  }
                  if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              PasswordField(controller: _passwordController),
              const SizedBox(height: 16),
              TextFormField(
                cursorColor: AppColors.primary,
                controller: _companyDescriptionController,
                decoration: InputDecoration(
                  labelText: 'Company Description',
                  floatingLabelStyle: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  hintText: 'Enter your company description',
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: AppColors.borderColor,
                  ),
                  prefixIcon: const Icon(Icons.business, color: AppColors.borderColor),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your company description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Upload Photo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ImageUploader(
                onImagesSelected: _handlePhotoUpload, // Use ImageUploader here
              ),
              const SizedBox(height: 16),
              const Text(
                'Job Type',
                style: TextStyle(fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color:AppColors.primary),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedJobType.isNotEmpty ? _selectedJobType : null,
                decoration: InputDecoration(
                  hintText: 'Select job type',
                ),
                items: ['Full-Time', 'Part-Time', 'Freelance', 'Internship']
                    .map((jobType) => DropdownMenuItem(
                  value: jobType,
                  child: Text(jobType),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedJobType = value ?? '';
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a job type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _isTermsAccepted,
                    activeColor: AppColors.primary,
                    onChanged: (value) {
                      setState(() {
                        _isTermsAccepted = value ?? false;
                      });
                    },
                  ),
            Expanded(
              child: RichText(
                text: TextSpan(
                  text: 'I agree to the ',
                  style: const TextStyle(color: AppColors.textColor),
                  children: [
                    TextSpan(
                      text: 'Terms and Conditions',
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                        color: AppColors.primary,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TermsAndConditionsPage(),
                            ),
                          );
                        },
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                        color:AppColors.primary,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PrivacyPolicyPage(),
                            ),
                          );
                        },
                    ),
                  ],
                ),
              ),
            )
]
        ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate() && _isTermsAccepted && _uploadedPhotos.isNotEmpty) {
                      try {
                        await RegistrationCompanyService.registerCompany(
                          username: _usernameController.text,
                          email: _emailController.text,
                          password: _passwordController.text,
                          jobtype: _selectedJobType,
                          companyDescription: _companyDescriptionController.text,
                          photos: _uploadedPhotos,
                        );
                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registration successful!')));
                        // Navigate to the home page
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      } catch (e) {
                        // Show error message
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill in all required fields')));
                    }
                  },
                  child: const Text(
                    'Create Account',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}