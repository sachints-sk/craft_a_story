import 'package:flutter/material.dart';
import 'createwithai.dart';

class SelectModePage extends StatelessWidget {
  const SelectModePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background color to white
      appBar: AppBar(
        title: Text("Choose mode",textAlign: TextAlign.center,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
        backgroundColor: const Color(0xFF161825), // Set app bar color
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Handle back button press
          },
        ),

        elevation: 0, // Remove app bar shadow (optional)
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // First Card (AI-Powered Story Creation)
            _buildModeCard(
              context,
              icon: Icons.smart_toy_outlined, // Replace with AI-related icon
              title: 'Create with AI',
              description: 'Let your imagination run wild with our AI-powered story creator.',
              buttonLabel: 'Start Now',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>  CreateStoryWithAI(),
                  ),
                );
              },
              backgroundColor: const Color(0xFFF2D7ED), // Light pink
            ),
            const SizedBox(height: 20),
            // Second Card (Write Your Own Story)
            _buildModeCard(
              context,
              icon: Icons.edit,
              title: 'Write your own Stories',
              description: 'Create your own magical adventures and share them with friends.',
              buttonLabel: 'Get Writing',
              onPressed: () {
                // Navigate to the write your own story page
              },
              backgroundColor: const Color(0xFF161825), // Dark blue
              textColor: Colors.white, // White text for dark background
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String description,
        required String buttonLabel,
        required VoidCallback onPressed,
        required Color backgroundColor,
        Color textColor = Colors.black, // Default text color is black
      }) {
    return Card(
      color: backgroundColor,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              child: Icon(icon, size: 40, color: textColor),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: textColor),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                textStyle: const TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(buttonLabel, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}