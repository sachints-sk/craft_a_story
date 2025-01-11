import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'StoryTitleInputScreen.dart';
import 'package:page_transition/page_transition.dart';

class StoryIntroScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0F4F7),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Center(
                child: RoundedImage(imagePath: 'assets/image02.png'),
              ),
              SizedBox(height: 20),
              Text(
                "Ready to Craft Your First Story?",
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A2259),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Get ready to experience the magic of creating a unique story with our AI. Just a few steps, and your first enchanting tale will be ready!",
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                 //   Navigator.pushNamed(context, '/story-creation');
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.rightToLeft,
                        child:  StoryTitleInputScreen(),
                      ),
                    );

                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A2259),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                  ),
                  child: Text(
                    "Let's Get Started!",
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                  child: Text("Powered By AI",style: TextStyle(color: Colors.grey[400],fontSize: 15) )
              )
            ],
          ),
        ),
      ),
    );
  }
}


class RoundedImage extends StatelessWidget {
  final String imagePath;

  const RoundedImage({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: constraints.maxHeight * 0.5,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }
}