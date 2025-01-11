import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class PremiumPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("Premium Member",
          style: GoogleFonts.blinker(
            textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 24),
          ),),
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        backgroundColor: Colors.grey[50],
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0), // Rounded corners for the animation

                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0), // clip the animation in circular radius
                  child: Lottie.asset(
                    'assets/premiumbadge.json', // Replace with your Lottie animation path.
                    height: 300,
                    width: 300,
                    fit: BoxFit.cover, // Makes animation occupy all the space
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                "Welcome to Premium!",
                style: GoogleFonts.montserrat(
                  textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 28, color: Colors.black87),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                "Thank you for supporting us! You are now enjoying a truly unlimited creative experience.",
                style: GoogleFonts.montserrat(
                  textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16, color: Colors.black54),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

            ],
          ),
        ),
      ),
    );
  }
}