import 'package:flutter/material.dart';
import 'JobCategoryPage.dart';
import 'package:flutter_projects/Log_In/Log_In_Screen.dart';
import 'package:flutter_projects/AppColors.dart';
import 'package:flutter_projects/custom_button.dart'; // Import the CustomButton

class SecondWelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
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
                    color: AppColors.textColor,
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
                    color: AppColors.textColor,
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
                  color: AppColors.textColor,
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
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Bouton Continue using CustomButton
                    CustomButton(
                      text: 'Continue',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => JobCategoryPage()),
                        );
                      },
                    ),
                    // Bouton Skip using CustomButton
                    CustomButton(
                      text: 'Skip',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LogInPage()),
                        );
                      },
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
            color: AppColors.textColor,
          ),
          SizedBox(width: 8.0),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 18.0,
                color: AppColors.textColor,
                fontFamily: 'Quicksand-Regular',
              ),
            ),
          ),
        ],
      ),
    );
  }
}