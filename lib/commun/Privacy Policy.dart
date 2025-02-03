import 'package:flutter/material.dart';
class PrivacyPolicyPage extends StatelessWidget {
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
                'Privacy Policy for Part-Time Connect',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              _buildSectionTitle('1. Introduction'),
              _buildSectionContent(
                'This Privacy Policy explains how we collect, use, disclose, '
                    'and safeguard your information when you use the Part-Time Connect application. '
                    'By using our app, you agree to the collection and use of information as described in this policy.',
              ),

              _buildSectionTitle('2. Information We Collect'),
              _buildSectionContent(
                'We collect both personal and non-personal information to provide better services. '
                    'The personal information may include:',
              ),
              _buildBulletPoint('Name'),
              _buildBulletPoint('Email address'),
              _buildBulletPoint('Job preferences'),
              _buildBulletPoint('Company or organization information'),
              _buildBulletPoint('Photos and documents uploaded by users'),

              _buildSectionTitle('3. How We Use Your Information'),
              _buildSectionContent(
                'The information we collect is used to:\n'
                    '- Facilitate job matching\n'
                    '- Improve user experience\n'
                    '- Communicate with users about relevant opportunities\n'
                    '- Ensure the security and integrity of our platform',
              ),

              _buildSectionTitle('4. Data Storage and Security'),
              _buildSectionContent(
                'We take the security of your personal data seriously. All collected information '
                    'is stored securely and is only accessible to authorized personnel. '
                    'We use encryption technologies to protect sensitive data.',
              ),

              _buildSectionTitle('5. Sharing Your Information'),
              _buildSectionContent(
                'We do not sell or share your personal information with third parties, '
                    'except for trusted service providers who assist us in operating the app or providing services. '
                    'These providers are obligated to keep your information confidential.',
              ),

              _buildSectionTitle('6. Your Rights'),
              _buildSectionContent(
                'You have the right to:\n'
                    '- Access, correct, or delete your personal information\n'
                    '- Opt-out of certain marketing communications\n'
                    '- Request information on how your data is being used',
              ),

              _buildSectionTitle('7. Cookies and Tracking Technologies'),
              _buildSectionContent(
                'Part-Time Connect uses cookies to enhance user experience and collect analytics. '
                    'You can manage your cookie preferences in your browser settings.',
              ),

              _buildSectionTitle('8. Changes to This Privacy Policy'),
              _buildSectionContent(
                'We may update our Privacy Policy from time to time. Any changes will be posted '
                    'on this page with an updated "Last Revised" date. We encourage you to review this policy periodically.',
              ),

              _buildSectionTitle('9. Contact Us'),
              _buildSectionContent(
                'If you have any questions or concerns about this Privacy Policy, please contact us at:\n'
                    '📧 support@parttimeconnect.com',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
Widget _buildSectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.only(top: 12.0, bottom: 4.0),
    child: Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
  );
}

Widget _buildSectionContent(String content) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(
      content,
      style: const TextStyle(fontSize: 14),
    ),
  );
}

Widget _buildBulletPoint(String text) {
  return Padding(
    padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('• ', style: TextStyle(fontSize: 14)),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
      ],
    ),
  );
}

