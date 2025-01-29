import 'package:flutter/material.dart';
import '../commun/password_field.dart';
import '../commun/Pdf_Upload.dart';
import 'package:file_picker/file_picker.dart';


class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  List<String> _uploadedPdfPaths = []; // Liste des fichiers PDF sélectionnés

  void _handlePdfUpload(List<String> filePaths) {
    setState(() {
      _uploadedPdfPaths = filePaths; // Mettre à jour les fichiers sélectionnés
    });
    print('Fichiers sélectionnés : $filePaths');
  }

  Future<void> _pickPdfFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'], // Restrict to PDF files
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _uploadedPdfPaths.add(result.files.single.path!); // Add selected file to the list
      });
      print('Uploaded file: ${result.files.single.path}');
    }
  }

  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isTermsAccepted = false;

  final List<String> _selectedSkills = ['Graphic Design', 'UI/UX'];

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        title: const Text(
          'Hi! Let\'s get you registered.',
          style: TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Please provide the following details.',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: 'Full Name', // Adding a label
                  floatingLabelStyle: const TextStyle( // Custom style for the label
                    color: Color(0xFF375534), // Label color
                    fontWeight: FontWeight.bold, // Optional: Bold text
                  ),
                  hintText: 'Enter your full name', // Optional hint
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
                      color: Colors.grey, // Border color when not focused
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color(0xFF375534), // Border color when focused
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                style: const TextStyle(
                  color: Color(0xFF375534), // Text color for the input
                  fontWeight: FontWeight.bold, // Applying bold styling
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
                  labelText: 'Email Address', // Adding a label
                  floatingLabelStyle: const TextStyle( // Custom style for the label
                    color: Color(0xFF375534), // Custom color
                    fontWeight: FontWeight.bold, // Optional: Bold text
                  ),
                  hintText: 'Enter your email address', // Optional hint
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
                  fontWeight: FontWeight.bold, // Applying bold styling
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
                            title: const Text('Add Skill'),
                            content: TextField(
                              controller: skillController,
                              decoration: const InputDecoration(
                                hintText: 'Enter a skill',
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  if (skillController.text.isNotEmpty &&
                                      !_selectedSkills
                                          .contains(skillController.text)) {
                                    setState(() {
                                      _selectedSkills.add(skillController.text);
                                    });
                                  }
                                  Navigator.pop(context);
                                },
                                child: const Text('Add'),
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
                  onPressed: () {
                    if (_formKey.currentState!.validate() && _isTermsAccepted && _uploadedPdfPaths.isNotEmpty) {
                      print('Full Name: ${_fullNameController.text}');
                      print('Email: ${_emailController.text}');
                      print('Password: ${_passwordController.text}');
                      print('Skills: ${_selectedSkills.join(', ')}');
                      print('Uploaded PDFs: $_uploadedPdfPaths');
                    } else if (_uploadedPdfPaths.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please upload at least one PDF before continuing.'),
                        ),
                      );
                    } else if (!_isTermsAccepted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'You must accept the terms and conditions'),
                        ),
                      );
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
