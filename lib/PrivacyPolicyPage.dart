import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),

      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Title

              const SizedBox(height: 8),
              Text(
                'Effective Date: 30 NOV 2024',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),

              // Introduction Section
              _buildSectionTitle(context, 'Introduction'),
              const SizedBox(height: 5),
              const Text(
                'At Craft-a-Story, we respect your privacy and are committed to protecting the personal information you share with us. This Privacy Policy outlines how we collect, use, and protect your data when you use our app.',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 12),

              // Data We Collect
              _buildSectionTitle(context, '1. Data We Collect'),
              const SizedBox(height: 5),
              const ListTile(
                leading: Icon(Icons.person, color: Colors.black87),
                title: Text('User Data'),
                subtitle: Text(
                  'Name, email address, and profile image from Google when signing in via Firebase Authentication.',
                ),
              ),
              const ListTile(
                leading: Icon(Icons.phone_android, color: Colors.black87),
                title: Text('Device Data'),
                subtitle: Text(
                  'Collected via Firebase SDK for analytics and app performance improvement.',
                ),
              ),
              const ListTile(
                leading: Icon(Icons.text_fields, color: Colors.black87),
                title: Text('Text Data'),
                subtitle: Text(
                  'Fictional story-related input used solely for story creation (e.g., story title, character name, age).',
                ),
              ),
              const SizedBox(height: 14),

              // Third-Party Services
              _buildSectionTitle(context, '2. Third-Party Services We Use'),
              const SizedBox(height: 5),
              _buildBulletPoint(
                  'Firebase: Authentication, Firestore storage, and Analytics.'),
              _buildBulletPoint(
                  'Google Analytics: App usage analysis and improvement.'),
              _buildBulletPoint(
                  'GCP Cloud Functions: Cloud-based operations.'),
              _buildBulletPoint(
                  'Google Gemini API: Supports premium app features.'),
              const SizedBox(height: 14),

              // Paid Features and Subscriptions
              _buildSectionTitle(context, '3. Paid Features and Subscriptions'),
              const SizedBox(height: 5),
              const Text(
                'We offer credits and premium subscriptions via Google Play Billing. Payment and subscription details are securely stored in Firestore.',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 14),

              // Cookies and Tracking
              _buildSectionTitle(context, '4. Cookies and Tracking Technologies'),
              const SizedBox(height: 5),
              const Text(
                'Our app does not use cookies or similar tracking technologies. However, Google Analytics SDK may collect analytics data.',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 14),

              // Target Audience
              _buildSectionTitle(context, '5. Target Audience'),
              const SizedBox(height: 5),
              const Text(
                'Our app is intended for children and parents. We comply with COPPA by not collecting personal data from children except fictional story inputs (e.g., story title, character details).',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 14),

              // Data Retention
              _buildSectionTitle(context, '6. Data Retention'),
              const SizedBox(height: 5),
              const Text(
                'User data is retained until the user decides to delete their account.',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 14),

              // Third-Party Links
              _buildSectionTitle(context, '7. Third-Party Links'),
              const SizedBox(height: 5),
              const Text(
                'Our app does not include any external links.',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 14),

              // Contact Us
              _buildSectionTitle(context, '8. Contact Us'),
              const SizedBox(height: 5),
              const Text(
                'If you have any questions or concerns about our Privacy Policy or how we handle your data, please contact us via the support email provided in the Help Center of the app.',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 24),

            ],
          ),
        ),
      ),
    );
  }

  // Helper for Section Title
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w400,
        color: Colors.black87,
      ),
    );
  }

  // Helper for Bullet Points
  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 14, color: Colors.black)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
