import 'package:flutter/material.dart';  // Make sure you're importing Material
import 'package:toggle_switch/toggle_switch.dart';
import 'package:google_fonts/google_fonts.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({Key? key}) : super(key: key);

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  bool isAnnual = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Pick Your Plan",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Tagline
             Text(
              "Unlock the Magic of Storytelling!",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700, // Use Bold 700
                fontSize: 24,                // Font size example
              ),
            ),

             Text(
              "Choose the plan that's right for your little storyteller.",
              style: GoogleFonts.poppins(
                // Use Bold 700
                fontSize: 16,                // Font size example
              ),
            ),
            const SizedBox(height: 10),



            // Subscription Plans with Expanded for better spacing
            Expanded(
              child: ListView( // Use ListView for scrolling if needed
                children: [
                  _buildSubscriptionCard(
                    planName: 'Storyteller Plus',
                    price:  '\$6.99/month',
                    description: const [
                      '+50 credits for Crafting Stories',
                      'Multi-language story creation',
                      'Access to 100+ precarafted stories ',
                    ],
                    highlighted: false, // Not the most popular plan
                  ),
                  const SizedBox(height: 20),
                  _buildSubscriptionCard(
                    planName: 'Storyteller Pro',
                    price:  '\$12.99/month',
                    description: const [
                      '+100 credits for Crafting personalized \n stories',
                      'Multi-language story creation',
                      'Access to over 100 expertly crafted\n stories ',
                      'Enjoy premium-quality studio voices',

                    ],
                    highlighted: true, // Highlight the Pro plan
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Reusable Subscription Card Widget with styling
  Widget _buildSubscriptionCard({
    required String planName,
    required String price,
    required List<String> description,
    required bool highlighted, // Flag to highlight a plan
  }) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: highlighted ? Colors.blue[50] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: highlighted ? Colors.blue : Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plan Name with Optional "Most Popular" Tag
          Row(
            children: [
              Text(
                planName,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700, // Use Bold 700
                  fontSize: 18,                // Font size example
                  color: highlighted ? Colors.blue : Colors.black,
                ),
              ),

              if (highlighted)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'MOST POPULAR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),
          Text(
            price,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          // Features List
          ...description.map((feature) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0), // Add spacing between features
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.blue, size: 18),
                const SizedBox(width: 8),
                Text(feature),
              ],
            ),
          )),
          const SizedBox(height: 20),
          // Select Plan Button
          Center(
            child: ElevatedButton(
              onPressed: () {
                // Action when plan is selected
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                textStyle: const TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'SELECT PLAN',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}