import 'package:flutter/material.dart';

class UpgradeToPremiumCard extends StatelessWidget {
  const UpgradeToPremiumCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFF00001E),
                Color(0xFF7673FF),
              ])
      ),
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Upgrade to Premium',
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Get access to exclusive features',
                  style: TextStyle(
                      fontSize: 14.0, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16.0),
          ElevatedButton(
            onPressed: () {
              // TODO: Handle upgrade action
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                )
            ),
            child: const Text(
              'Upgrade',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}