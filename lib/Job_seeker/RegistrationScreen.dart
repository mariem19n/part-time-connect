import 'package:flutter/material.dart';
import '../commun/password_field.dart';
import '../commun/Pdf_Upload.dart';
import 'package:flutter_projects/services/RegistrationUser_service.dart';
import 'package:flutter_projects/commun/Privacy Policy.dart';
import 'package:flutter_projects/commun/Terms and Conditions.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:flutter/gestures.dart';


class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  List<String> _uploadedPdfPaths = [];
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isTermsAccepted = false;
  final List<String> _selectedSkills = [];

  void _handlePdfUpload(List<String> filePaths) {
    setState(() {
      _uploadedPdfPaths = filePaths;
    });
    print('Fichiers sélectionnés : $filePaths');
  }

  Future<void> _pickPdfFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        _uploadedPdfPaths = result.paths?.whereType<String>().toList() ?? [];
      });
      print('Uploaded files: $_uploadedPdfPaths');
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
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
                cursorColor: Color(0xFF375534),
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
                cursorColor: Color(0xFF375534),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Upload Resume',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),
                  PdfUpload(
                    onFilesSelected: (filePaths) {
                      setState(() {
                        _uploadedPdfPaths = filePaths;
                      });
                      print('Uploaded PDFs: $filePaths');
                    },
                  ),
                  const SizedBox(height: 8),
                ],

              ),
              const SizedBox(height: 16),
              const Text(
                'Key Skills',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: [
                  ..._selectedSkills.map((skill) => Chip(
                    label: Text(skill),
                    onDeleted: () {
                      setState(() {
                        _selectedSkills.remove(skill);
                      });
                    },
                  )),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          final skillController = TextEditingController();
                          return AlertDialog(
                            title: Text(
                              'Add Skill',
                              textAlign: TextAlign.center, // Centers the title
                              style: TextStyle(
                                fontSize: 20, // Reduces the font size
                              ),
                            ),content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: skillController,
                                decoration: InputDecoration(
                                  labelText: 'Enter a skill',
                                  labelStyle: TextStyle(color: Color(0xFF4B5320)),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Color(0xFF4B5320), width: 2),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Color(0xFF4B5320), width: 1),
                                  ),
                                ),
                                cursorColor: Color(0xFF4B5320),
                              ),
                              SizedBox(height: 20),
                            ],
                          ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  // Add your action here
                                  Navigator.pop(context);
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Color(0xFF4B5320), // Green background
                                ),
                                child: Text("Add"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Chip(
                      label: const Icon(Icons.add),
                      backgroundColor: Colors.grey[300],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _isTermsAccepted,
                    activeColor: Color(0xFF375534),
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
                        style: const TextStyle(color: Colors.black),
                        children: [
                          TextSpan(
                            text: 'Terms and Conditions',
                            style: const TextStyle(
                              decoration: TextDecoration.underline,
                              color: Color(0xFF375534),
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
                              color: Color(0xFF375534),
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
                    if (_formKey.currentState!.validate() && _isTermsAccepted && _uploadedPdfPaths.isNotEmpty) {
                      List<File> resumeFiles = _uploadedPdfPaths
                          .whereType<String>()
                          .map((path) => File(path))
                          .toList();

                      await RegistrationUserService.registerUser(
                        username: _usernameController.text,
                        email: _emailController.text,
                        password: _passwordController.text,
                        skills: _selectedSkills,
                        resumes: resumeFiles,
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