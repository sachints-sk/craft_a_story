import 'package:flutter/material.dart';

class TermsOfUsePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Use'),

        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Header


              // Effective Date Section
              Text(
                'Effective Date: November 30, 2024',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
              ),
              const Divider(height: 30),
              // Content Section
              _buildSection(
                context,
                title: '1. Acceptance of Terms',
                content:
                'By using the Craft-a-Story app, you agree to abide by these terms and all applicable laws. If you do not agree, please discontinue using the app immediately.',
              ),
              _buildSection(
                context,
                title: '2. Intended Use',
                content:
                'The app is designed for parents to create engaging, imaginative, and child-friendly stories using AI tools. Ensure all generated content is appropriate for the intended audience.',
              ),
              _buildSection(
                context,
                title: '3. Restrictions on Use',
                content: '''
- Do not create or share inappropriate, offensive, or explicit stories.
- Avoid generating content unsuitable for children or promoting discrimination.
- Misuse of AI tools will lead to account suspension or termination.''',
              ),
              _buildSection(
                context,
                title: '4. Account Responsibilities',
                content:
                'Users must be at least 18 years old to create an account. Parents or guardians must supervise app usage by children.',
              ),
              _buildSection(
                context,
                title: '5. AI Limitations',
                content:
                'While we strive to ensure appropriate AI content, it is your responsibility to review the generated stories.',
              ),
              _buildSection(
                context,
                title: '6. Paid Features and Subscriptions',
                content:
                'We offer paid features via Google Play Billing. All purchases are governed by Google Play Billing policies.',
              ),
              _buildSection(
                context,
                title: '7. Ownership of Content',
                content:
                'Stories generated through the app are for personal and non-commercial use.',
              ),
              _buildSection(
                context,
                title: '8. Liability and Disclaimers',
                content: '''
- We are not liable for inappropriate or harmful content generated by users.
- The app provides AI tools "as is" without any warranty.''',
              ),
              _buildSection(
                context,
                title: '9. User-Generated Content',
                content:
                'Violations of these terms through user-generated content may result in its removal and account termination.',
              ),
              _buildSection(
                context,
                title: '10. Compliance with COPPA',
                content:
                'We comply with COPPA. Parents are responsible for supervising app usage and ensuring content suitability for children.',
              ),
              _buildSection(
                context,
                title: '11. Modifications to the Terms',
                content:
                'We may revise these Terms of Use from time to time. Continued use of the app after modifications constitutes acceptance of the revised terms.',
              ),
              _buildSection(
                context,
                title: '12. Contact Us',
                content:
                'If you have questions or concerns about these terms, please contact us via the support email provided in the Help Center.',
              ),
              // Padding Bottom
              const SizedBox(height: 20),
              Text(
                'Craft-a-Story © 2024',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context,
      {required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          content,
          style:  const TextStyle(fontSize: 14, height: 1.5),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
