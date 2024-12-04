import 'package:flutter/material.dart';

class GuideDetailPage extends StatelessWidget {
  final List<Map<String, String>> steps = [
    {
      'question': 'How to Create a Story?',
      'answer': '1. Tap "Create Story" on the home page.\n2. Choose a template and follow the instructions to customize your story.',
    },
    {
      'question': 'How to Use Credits?',
      'answer': '1. Go to the Store from the menu.\n2. Choose the desired credit package and make a purchase.',
    },
    {
      'question': 'How to Manage Audio Files?',
      'answer': '1. After creating a story, tap "Generate Audio".\n2. Choose the voice and save your audio file.',
    },
    // Add more steps as required
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Step-by-Step Guide"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: steps.length,
          itemBuilder: (context, index) {
            return ExpansionTile(
              title: Text(steps[index]['question']!),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(steps[index]['answer']!),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
