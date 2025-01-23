import 'package:flutter/material.dart';
import 'JobCategoryPage.dart';
import 'package:flutter_projects/Log_In/Log_In_Screen.dart';
class SecondWelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre principal
              Center(
                child: Text(
                  'Part-Time Connect',
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Quicksand-Bold',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 16.0),
              // Sous-titre descriptif
              Center(
                child: Text(
                  'Easily find part-time jobs, freelance opportunities, and gigs near you.',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.black,
                    fontFamily: 'Quicksand-Regular',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 24.0),
              // Liste des bénéfices
              Text(
                'Benefits:',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'Quicksand-SemiBold',
                ),
              ),
              SizedBox(height: 8.0),
              _buildBenefitItem(
                'Personalized opportunities: Discover offers tailored to your skills and availability.',
              ),
              _buildBenefitItem(
                'Simplified access: Quickly find jobs through a simple and intuitive interface.',
              ),
              _buildBenefitItem(
                'Secure and fast: Enjoy secure payments and a streamlined application process.',
              ),
              _buildBenefitItem(
                'No intermediaries: Fully automated management, without administrators or agencies.',
              ),
              _buildBenefitItem(
                'Flexible: Work at your own pace and according to your preferences.',
              ),
              Spacer(),
              // Boutons Continue et Skip
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Bouton Continue
                    Container(
                      height: 50.0,  // Set a fixed height for both buttons
                      margin: EdgeInsets.symmetric(vertical: 6.0),
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => JobCategoryPage()),
                          );
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith(
                                (states) {
                              if (states.contains(MaterialState.pressed)) {
                                return Color(0xFF4B5320); // Green fill when pressed
                              }
                              return Colors.white; // White fill by default
                            },
                          ),
                          foregroundColor: MaterialStateProperty.resolveWith(
                                (states) {
                              if (states.contains(MaterialState.pressed)) {
                                return Colors.white; // White text when pressed
                              }
                              return Color(0xFF4B5320); // Green text by default
                            },
                          ),
                          side: MaterialStateProperty.all(
                            BorderSide(color: Color(0xFF4B5320)), // Green border
                          ),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                        child: Text(
                          'Continue',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    // Bouton Skip
                    Container(
                      height: 50.0,  // Same height as Continue button
                      margin: EdgeInsets.symmetric(vertical: 6.0),
                      child: TextButton(
                        onPressed: () {
                          // Navigate to the sign-up page
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LogInPage()),
                          );
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith(
                                (states) {
                              if (states.contains(MaterialState.pressed)) {
                                return Color(0xFF4B5320); // Green fill when pressed
                              }
                              return Colors.white; // White fill by default
                            },
                          ),
                          foregroundColor: MaterialStateProperty.resolveWith(
                                (states) {
                              if (states.contains(MaterialState.pressed)) {
                                return Colors.white; // White text when pressed
                              }
                              return Color(0xFF4B5320); // Green text by default
                            },
                          ),
                          side: MaterialStateProperty.all(
                            BorderSide(color: Color(0xFF4B5320)), // Green border
                          ),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                        child: Text(
                          'Skip',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget helper pour un item de bénéfice
  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.circle,
            size: 8.0,
            color: Colors.black,
          ),
          SizedBox(width: 8.0),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.black,
                fontFamily: 'Quicksand-Regular',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
