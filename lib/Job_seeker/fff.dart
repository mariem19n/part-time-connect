import 'dart:io';
import 'package:flutter/material.dart';
import '../commun/image_uploader.dart';
import '../commun/password_field.dart';

class RegistrationRecruiter extends StatefulWidget {
  @override
  _RegistrationRecruiterState createState() => _RegistrationRecruiterState();
}

class _RegistrationRecruiterState extends State<RegistrationRecruiter> {
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isTermsAccepted = false;
  List<File> _uploadedImages = [];
  final List<String> _jobTypes = [];

  @override
  void dispose() {
    _companyNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleImagesSelected(List<File> images) {
    setState(() {
      _uploadedImages = images;
    });
  }

  void _addJobType() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController controller = TextEditingController();
        return AlertDialog(
          title: Text('Add Job Type'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Enter job type'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  if (controller.text.isNotEmpty) {
                    _jobTypes.add(controller.text);
                  }
                });
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _removeJobType(int index) {
    setState(() {
      _jobTypes.removeAt(index);
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && _isTermsAccepted) {
      // Handle successful form submission
      print('Company Name: ${_companyNameController.text}');
      print('Email: ${_emailController.text}');
      print('Password: ${_passwordController.text}');
      print('Job Types: $_jobTypes');
      print('Images Uploaded: $_uploadedImages');

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Registration Successful'),
            content: Text('Your account has been created successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Navigate back
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      if (!_isTermsAccepted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You must accept the Terms and Conditions to proceed.'),

          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40), // Added spacing at the top
                Text(
                  'Hi! Let’s get you registered.', // Ajout du texte ici
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 20), // Espacement entre le texte et le formulaire
                TextFormField(
                  controller: _companyNameController,
                  decoration: InputDecoration(
                    labelText: 'Company or Organization Name',
                    floatingLabelStyle: const TextStyle( // Custom style for the label
                      color: Color(0xFF375534), // Label color
                      fontWeight: FontWeight.bold, // Optional: Bold text
                    ),
                    prefixIcon: const Icon(Icons.person, color: Colors.grey),
                    border: OutlineInputBorder( // Keep only one border definition
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
                      return 'Please enter a company name';
                    }
                    return null;
                  },
                ),




                SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Professional Email Address',
                    floatingLabelStyle: const TextStyle(
                      color: Color(0xFF375534), // Custom color
                      fontWeight: FontWeight.bold,
                    ),
                    hintText: 'Enter your professional email address',
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



                SizedBox(height: 16),
                PasswordField(controller: _passwordController),


                SizedBox(height: 20),
                Text(
                  'Upload Images of the Workplace',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF375534)
                  ),
                ),
                SizedBox(height: 10),
                ImageUploader(onImagesSelected: _handleImagesSelected),

                SizedBox(height: 20),
                Text(
                  'Type of Jobs Needed',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF375534)
                  ),
                ),

                SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8, // Space between wrapped rows
                  alignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ..._jobTypes.asMap().entries.map((entry) {
                      int index = entry.key;
                      String jobType = entry.value;
                      bool isSelected = true; // Modify this logic to track selection state

                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Color(0xFFE3EED4) : Colors.white, // Background color
                          border: Border.all(
                            color: Color(0xFF375534), // Border color
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(20), // Rounded corners
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              jobType,
                              style: TextStyle(
                                color: Color(0xFF375534), // Text color
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 4), // Spacing between text and button
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _jobTypes.removeAt(index);
                                });
                              },
                              child: Icon(Icons.close, size: 20, color: Color(0xFF375534)),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    GestureDetector(
                      onTap: _addJobType,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Color(0xFFE3EED4), // Updated background color
                          border: Border.all(
                            color: Color(0xFF375534), // Border color for add button
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add, size: 20, color: Color(0xFF375534)),
                            SizedBox(width: 4), // Spacing between icon and text
                            Text(
                              "Add a Job Type",
                              style: TextStyle(
                                color: Color(0xFF375534), // Text color
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),



                SizedBox(height: 20),
                Row(
                  children: [
                    Checkbox(
                      value: _isTermsAccepted,
                      onChanged: (bool? value) {
                        setState(() {
                          _isTermsAccepted = value ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          text: 'I agree to the ',
                          style: TextStyle(color: Colors.black),
                          children: [
                            TextSpan(
                              text: '[Terms and Conditions]',
                              style: TextStyle(color: Colors.blue),
                            ),
                            TextSpan(text: ' and '),
                            TextSpan(
                              text: '[Privacy Policy].',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF375534),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _submitForm,
                    child: const Text('Create Account',
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
      ),
    );
  }
}
