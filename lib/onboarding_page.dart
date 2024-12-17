import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'signinPagenew.dart';
import 'package:lottie/lottie.dart';
import 'package:animate_do/animate_do.dart';




class Onboarding extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Onboarding',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Montserrat',
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          bodyMedium: TextStyle(color: Colors.black54),
          bodySmall: TextStyle(color: Colors.black45),
        ),
      ),
      home: OnboardingPage(),
    );
  }
}

class OnboardingPage extends StatefulWidget {
  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      'title': 'Craft Magical Stories with AI!',
      'description': 'Unlock a world of enchanting stories for your little ones. Create personalized adventures or explore curated tales.',
      'image': 'assets/onboarding1.png',
      'isLottie': false,
    },
    {
      'title': 'Become a Storyteller! Let AI Create Just for You',
      'description': 'Simply provide a few details, and our AI will weave unique stories with engaging characters and vibrant scenes.',
      'image': 'assets/onboarding2.png',
      'isLottie': false,
    },
    {
      'title': 'Experience Stories in Multiple Languages',
      'description': 'Immerse your kids in stories crafted in your preferred language. We offer a range of premium voices for an authentic and engaging experience.',
      'image': 'assets/language3.json', // Now referencing the lottie animation
      'isLottie': true, // Added a field to determine if it's lottie or not
    },
    {
      'title': 'Discover New Stories Daily',
      'description': 'Explore our ever-growing library of curated stories, with fresh content added every day!.',
      'image': 'assets/onboarding3.png',
      'isLottie': false,
    },
  ];

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      // Handle Onboarding complete action
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.leftToRight,
          child:  Signinpagenew(),
        ),
      );
      print('Onboarding Complete!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingData.length,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  return OnboardingSlide(
                    title: _onboardingData[index]['title']!,
                    description: _onboardingData[index]['description']!,
                    image: _onboardingData[index]['image']!,
                    isLottie: _onboardingData[index]['isLottie'],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildPageIndicator(),
                  ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:  const Color(0xFF1A2259),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child:  _currentPage == _onboardingData.length - 1
                        ? const  Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Get Started',
                          style:  TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        SizedBox(width: 8,),
                        Icon(Icons.arrow_forward_ios, size: 18,color: Colors.white, )
                      ],
                    )
                        : const Icon(Icons.arrow_forward_ios, size: 20,color: Colors.white,),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20,),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _onboardingData.length,
            (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index ? Colors.indigo: Colors.grey,
          ),
        ),
      ),
    );
  }
}

class OnboardingSlide extends StatelessWidget {
  final String title;
  final String description;
  final String image;
  final bool isLottie;

  const OnboardingSlide({
    Key? key,
    required this.title,
    required this.description,
    required this.image,
    this.isLottie = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(26.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInLeft(
            child: isLottie
                ?  LottieWidget(animationPath: image)
                : RoundedImage(
                imagePath: image
            ),
          ),
          const SizedBox(height: 32.0),
          FadeInRight(
            child: Text(
              title,
              style: GoogleFonts.blinker(
                textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 26),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16.0),
          FadeInLeft(
            child: Text(
              description,
              style: GoogleFonts.blinker(
                textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 18),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
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
            maxHeight: constraints.maxHeight * 0.6,
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

class LottieWidget extends StatelessWidget {
  final String animationPath;
  const LottieWidget({Key? key, required this.animationPath}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: constraints.maxHeight * 0.6,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: Lottie.asset(
              animationPath,
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }
}