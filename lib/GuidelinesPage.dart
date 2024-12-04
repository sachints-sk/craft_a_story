import 'package:flutter/material.dart';

class GuidelinesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Story Guidelines',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),

        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Header



              Text(
                'Follow these guidelines to ensure your stories pass validation and remain appropriate for all users, especially children.',
                style:TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),

              // Sections
              _buildSection(
                title: '1. Appropriate Content',
                content:
                'All stories should be suitable for children and adhere to the intended family-friendly theme. Avoid inappropriate, explicit, or offensive content, including:\n'
                    '- Profanity or abusive language\n'
                    '- Violence, discrimination, or hate speech\n'
                    '- Sexual or adult themes',
              ),
              _buildSection(
                title: '2. Respectful Use of AI',
                content:
                'The AI tools are designed to foster creativity and imagination. Any misuse of these tools to generate harmful or inappropriate content is strictly prohibited. Violators risk account suspension or termination.',
              ),
              _buildSection(
                title: '3. Child-Safe Stories',
                content:
                'Ensure all generated stories are:\n'
                    '- Positive and uplifting\n'
                    '- Age-appropriate with themes suitable for young audiences\n'
                    '- Free from any potentially upsetting or scary elements.',
              ),
              _buildSection(
                title: '4. Fictional Characters and Details',
                content:
                'The details you provide for creating stories should be entirely fictional. Avoid using real-life names, brands, or personal details to prevent any unintended consequences.',
              ),
              _buildSection(
                title: '5. Prohibited Use Cases',
                content:
                'The following uses of the app are strictly forbidden:\n'
                    '- Promoting violence or hatred\n'
                    '- Spreading misinformation or propaganda\n'
                    '- Any form of bullying or harassment\n'
                    '- Generating content that violates laws or ethical standards',
              ),
              _buildSection(
                title: '6. Compliance with COPPA',
                content:
                'Craft-a-Story complies with the Children’s Online Privacy Protection Act (COPPA). Parents are encouraged to supervise app usage and ensure that all stories adhere to these guidelines.',
              ),
              _buildSection(
                title: '7. Editing and Reviewing Stories',
                content:
                'Before finalizing, carefully review the story generated by the app to:\n'
                    '- Ensure the narrative aligns with your intended theme\n'
                    '- Verify it adheres to the above guidelines\n'
                    '- Avoid any unintended messages or tone.',
              ),
              _buildSection(
                title: '8. Reporting Inappropriate Stories',
                content:
                'If you encounter a story that violates these guidelines, please report it through the Help Center. This helps us maintain a safe and creative environment for everyone.',
              ),

              // Footer
              const SizedBox(height: 30),
              Center(
                child: Text(
                  'Thank you for helping us create a safe and imaginative space for kids and families.',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontStyle: FontStyle.italic,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Craft-a-Story © 2024',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[800],
            height: 1.5,
          ),
        ),
        const Divider(height: 30, thickness: 0.5, color: Colors.grey),
      ],
    );
  }
}
