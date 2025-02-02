import 'package:flutter/material.dart';
import '../commun/password_field.dart';
import '../commun/Image_Uploader.dart'; // Import the correct widget
import 'package:flutter_projects/services/RegistrationCompany_service.dart';
import 'dart:io';

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
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Please provide the following details.',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  floatingLabelStyle: const TextStyle(
                    color: Color(0xFF375534),
                    fontWeight: FontWeight.bold,
                  ),
                  hintText: 'Enter your full name',
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                  prefixIcon: const Icon(Icons.person, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.grey,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color(0xFF375534),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                style: const TextStyle(
                  color: Color(0xFF375534),
                  fontWeight: FontWeight.bold,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  if (value.length < 3) {
                    return 'Name must be at least 3 characters long';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  floatingLabelStyle: const TextStyle(
                    color: Color(0xFF375534),
                    fontWeight: FontWeight.bold,
                  ),
                  hintText: 'Enter your email address',
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                  prefixIcon: const Icon(Icons.email, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF375534), width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
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
                controller: _companyDescriptionController,
                decoration: InputDecoration(
                  labelText: 'Company Description',
                  floatingLabelStyle: const TextStyle(
                    color: Color(0xFF375534),
                    fontWeight: FontWeight.bold,
                  ),
                  hintText: 'Enter your company description',
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                  prefixIcon: const Icon(Icons.business, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF375534), width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
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
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedJobType.isNotEmpty ? _selectedJobType : null,
                decoration: InputDecoration(
                  hintText: 'Select job type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
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
                    onChanged: (value) {
                      setState(() {
                        _isTermsAccepted = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: RichText(
                      text: const TextSpan(
                        text: 'I agree to the ',
                        style: TextStyle(color: Colors.black),
                        children: [
                          TextSpan(
                            text: '[Terms and Conditions]',
                            style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Colors.blue),
                          ),
                          TextSpan(text: ' and '),
                          TextSpan(
                            text: '[Privacy Policy]',
                            style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF375534),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate() && _isTermsAccepted && _uploadedPhotos.isNotEmpty) {
                      await RegistrationCompanyService.registerCompany(
                        username: _usernameController.text,
                        email: _emailController.text,
                        password: _passwordController.text,
                        jobtype: _selectedJobType,
                        companyDescription: _companyDescriptionController.text,
                        photos: _uploadedPhotos,
                      );

                      print("Données envoyées !");
                    } else {
                      print("Veuillez remplir tous les champs obligatoires.");
                    }
                  },
                  child: const Text(
                    'Create Account',
                    style: TextStyle(
                      color: Colors.white,
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