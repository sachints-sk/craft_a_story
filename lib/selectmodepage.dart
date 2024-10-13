import 'package:flutter/material.dart';
import 'createwithai.dart';
import 'package:page_transition/page_transition.dart';

class SelectModePage extends StatelessWidget {
  const SelectModePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF161825),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Choose Your Path",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                "Choose mode for story creation.",
                style: TextStyle(

                  fontSize: 18,
                ),
              ),const SizedBox(height: 30),
              _buildModeCard(
                context,
                imagePath: 'assets/aiwriting.png',
                title: 'Create with AI',
                description: 'Generate a story in seconds...',
                buttonText: 'Get Started',
                onPressed: () {
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.rightToLeft,
                      child: const CreateStoryWithAI(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildModeCard(
                context,
                imagePath: 'assets/personwriting.png',
                title: 'Write Your Story',
                description: 'Craft a story from scratch...',
                buttonText: 'Start Writing',
                onPressed: () {
                  // Navigate to the write your own story page
                },
              ),



            ],
          ),
        ),
      ),
    );
  }

  // Reusable widget for mode cards
  Widget _buildModeCard(
      BuildContext context, {
        required String imagePath,
        required String title,
        required String description,
        required String buttonText,
        required VoidCallback onPressed,
      }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image at the top
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            child: Image.asset(
              imagePath,
              height: 150, // Adjust height as needed
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Arrange elements with space between
              children: [
                Column( // Wrap title and description in a Column for vertical arrangement
                  crossAxisAlignment: CrossAxisAlignment.start, // Align text to the start (left)
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4), // Small vertical spacing
                    Text(
                      description,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    textStyle: const TextStyle(fontSize: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(buttonText, style: const TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}