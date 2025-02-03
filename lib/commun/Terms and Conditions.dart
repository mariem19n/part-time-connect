import 'package:flutter/material.dart';
class TermsAndConditionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Terms and Conditions for Part-Time Connect',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              _buildSectionTitle('1. Introduction'),
              _buildSectionContent(
                'These terms and conditions govern the use of the Part-Time Connect application. '
                    'By accessing or using this app, you agree to comply with these terms. '
                    'If you do not agree, please do not use the app.',
              ),

              _buildSectionTitle('2. User Accounts'),
              _buildSectionContent(
                'To access certain features of the app, you may be required to create an account. '
                    'You agree to provide accurate, current, and complete information during the registration process '
                    'and to update such information to keep it accurate.',
              ),

              _buildSectionTitle('3. Use of the Platform'),
              _buildSectionContent(
                'Part-Time Connect connects users with part-time, freelance, and gig opportunities. '
                    'The app facilitates job discovery and application processes but does not act as an employer or mediator.',
              ),

              _buildSectionTitle('4. Payment and Transactions'),
              _buildSectionContent(
                'Payments for jobs, gigs, and services are handled directly through third-party payment services '
                    'integrated into the app. We are not responsible for any issues arising from transactions.',
              ),

              _buildSectionTitle('5. User Responsibility'),
              _buildSectionContent(
                'Users must ensure their interactions with other users comply with the laws and regulations of their jurisdiction. '
                    'You are responsible for the accuracy of your information and any interactions that occur through the platform.',
              ),

              _buildSectionTitle('6. Limitation of Liability'),
              _buildSectionContent(
                'We are not responsible for any damages resulting from the use of Part-Time Connect. '
                    'This includes, but is not limited to, financial losses, personal injury, or damage to property '
                    'caused by interactions with other users.',
              ),

              _buildSectionTitle('7. Privacy and Data Collection'),
              _buildSectionContent(
                'Please review our Privacy Policy for details about how we collect, use, and protect your personal data.',
              ),

              _buildSectionTitle('8. Modifications to Terms'),
              _buildSectionContent(
                'We reserve the right to modify or update these terms at any time. Any changes will be reflected in the updated '
                    'terms and conditions. It is your responsibility to review these terms periodically.',
              ),

              _buildSectionTitle('9. Governing Law'),
              _buildSectionContent(
                'These terms are governed by the laws of Tunisia. Any disputes arising from these terms shall be resolved '
                    'in accordance with Tunisian law.',
              ),

              _buildSectionTitle('10. Contact Information'),
              _buildSectionContent(
                'If you have any questions or concerns about these terms and conditions, please contact us at:\n'
                    '📧 support@parttimeconnect.com',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method for section titles
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 4.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Helper method for section content
  Widget _buildSectionContent(String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        content,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}