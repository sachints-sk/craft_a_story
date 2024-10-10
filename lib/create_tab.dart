import 'package:flutter/material.dart';

class CreateTab extends StatelessWidget {
  const CreateTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121224), // Dark background color
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // Align items to the top
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10), // Rounded corners for the image
              child: Image.asset(
                'assets/logo.png', // Replace with your image path
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 30),
            _buildCustomButton(
              context,
              'Create Stories with AI',
              onPressed: () {
                // Navigate to the AI story creation screen
              },
            ),
            const SizedBox(height: 20),
            _buildCustomButton(
              context,
              'Write Your Story',
              onPressed: () {
                // Navigate to the write your own story screen
              },
            ),
            const SizedBox(height: 20),
            _buildCustomButton(
              context,
              'Explore Stories',
              onPressed: () {
                // Navigate to the explore stories screen
              },
            ),
          ],
        ),
      ),
    );
  }

  // Function to build the custom button
  Widget _buildCustomButton(BuildContext context, String label, {required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity, // Full width button
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[600], // Customize button color
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(label, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}