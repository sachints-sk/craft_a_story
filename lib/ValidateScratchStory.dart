import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:lottie/lottie.dart';
import 'SelectStoryTypeUserCreatedStory.dart';
import 'package:page_transition/page_transition.dart';
import 'GuidelinesPage.dart';

class ValidateScratchStory extends StatefulWidget {
  final String story;
  final String title;
  final String mode;

  const ValidateScratchStory({Key? key, required this.story, required this.title,required this.mode}) : super(key: key);

  @override
  _ValidateScratchStoryState createState() => _ValidateScratchStoryState();
}

class _ValidateScratchStoryState extends State<ValidateScratchStory> {
  bool _isLoading = false;

  bool _analysing = false;
  bool _analysed = false;
  bool _validatefailed = false;
  bool _moderatefailed = false;
  bool _issuccess = false;
  String _message = "";
  // Categories you want to check
  List<String> selectedCategories = ['Insult', 'Profanity','Toxic','Sexual','Violent'];

  @override
  void initState() {
    super.initState();
    validateAndModerateStory();
  }

  // Function to validate story
  Future<bool> validateStory(String story) async {
    try {
      final response = await http.post(
        Uri.parse(
            "https://us-central1-adept-ethos-432515-v9.cloudfunctions.net/Validate-Story"),
        body: {'text': story},
      );

      if (response.statusCode == 200) {
        print("200 isvalid");
        return getBooleanFromGemini(response.body);
      } else {
        throw Exception(
            "Validation failed. Status code: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        _message = "Error during validation: $e";
      });
      print("Error during validation: $e");
      return false;
    }
  }

  // Function to moderate story
  Future<bool> moderateStory(String story) async {
    try {
      final response = await http.post(
        Uri.parse(
            "https://us-central1-adept-ethos-432515-v9.cloudfunctions.net/moderate"),
        body: {'text': story},
      );

      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body);
        final moderationResult = responseJson['moderationResult'];
        if (moderationResult == null ||
            moderationResult['moderationCategories'] == null) {
          setState(() {
            _message = "Moderation result is missing or invalid.";
          });
          return false;
        }

        final moderationCategories =
            moderationResult['moderationCategories'] as List<dynamic>;

        return isStorySafeForKids(moderationCategories, selectedCategories);
      } else {
        throw Exception(
            "Moderation failed. Status code: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        _message = "Error during moderation: $e";
      });
      print("Error during moderation: $e");
      return false;
    }
  }

  /// Function to check if story is safe for kids
  bool isStorySafeForKids(List categories, List<String> selectedCategories) {
    print(categories);

    // Filter only the selected categories to check
    final filteredCategories = categories.where((category) =>
        selectedCategories.contains(category['name'])
    );

    for (var category in filteredCategories) {
      if (category['confidence'] > 0.5) {
        print(
            "Story is not safe for kids due to category: ${category['name']}");
        setState(() {
          _message =
          "Story is not safe for kids due to category: ${category['name']}";
          _moderatefailed = true;
        });
        return false;
      }
    }

    setState(() {
      _message = "Story is safe for kids!";
      _issuccess = true;
    });
    return true;
  }


  // Validate and moderate story
  Future<void> validateAndModerateStory() async {
    setState(() {
      _analysing = true;
      _message = "";
    });

    final isValid = await validateStory(widget.story);
    print("isvalid ${isValid}");
    if (isValid) {
      final isSafe = await moderateStory(widget.story);
      print("issafe ${isSafe}");
      if (!isSafe) {
        setState(() {

          _analysing = false;
          _moderatefailed= true;
        });


      }else{
        setState(() {
          _analysing = false;

        });
        await Future.delayed(const Duration(seconds: 3));
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            child:  SelectStoryTypePageUserCreatedStory(story: widget.story,title: widget.title,mode: widget.mode),
          ),
        );
      }
    } else {
      setState(() {

        _analysing = false;
        _validatefailed = true;
      });
    }

    setState(() {
      _analysing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Safety Assurance",style: TextStyle( fontWeight: FontWeight.bold)),
      ),
      body:


      Center(
          child:Padding(padding: const EdgeInsets.only(left: 16,right: 16),
            child:
             Column(
              // Use a Column for the description

              mainAxisSize: MainAxisSize.min,
              children: [
                if(_analysing)
                  ...[
                Lottie.asset('assets/analyse.json', width: 200,
                  height: 200,),
                Text(
                  'Analyzing Story',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
                Text(
                  'Analyzing the story. Please hold on while we review its content.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18.0),
                ),],
                if(_validatefailed)
                  ...[
                    Lottie.asset('assets/failed.json', width: 200,
                      height: 200,
                    repeat: false),
                    Text(
                      'Story Validation Failed',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                    Text(
                      "The input provided does not meet the criteria for a valid story.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18.0),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child:  GuidelinesPage(),
                          ),
                        );
                      },
                      child: Text(
                        "Check Guideline",
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14.0, color: Colors.grey),
                      ),
                    ),
                  ],
                if(_moderatefailed)
                  ...[
                    Lottie.asset('assets/failed.json', width: 200,
                      height: 200,
                    repeat: false),
                    Text(
                      'Story Moderation Rejected',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                    Text(
                      "Your story violates our community guidelines.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18.0),
                    ),
                    Text(
                      _message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 17.0),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child:  GuidelinesPage(),
                          ),
                        );
                      },
                      child: Text(
                        "Check Guideline",
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14.0, color: Colors.grey),
                      ),
                    ),],
                if(_issuccess)
                  ...[
                    Lottie.asset('assets/success.json', width: 160,
                      height:160,
                    repeat: false),
                    Text(
                      'Checked and Safe',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                    Text(
                      'This story has been validated and is safe for young audiences.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18.0),
                    ),],

              ],
            ) ,) )
    );
  }
}

// Function to get boolean from string response
bool getBooleanFromGemini(String geminiResponse) {
  final text = geminiResponse.trim().toLowerCase();
  const yesPatterns = [
    r'yes',
    r'true',
    r'yeah',
    r'yup',
    r'affirmative',
    r'correct',
    r'1'
  ];
  const noPatterns = [
    r'no',
    r'false',
    r'nope',
    r'nah',
    r'negative',
    r'incorrect',
    r'0'
  ];

  for (final pattern in yesPatterns) {
    if (RegExp(pattern).hasMatch(text)) return true;
  }
  for (final pattern in noPatterns) {
    if (RegExp(pattern).hasMatch(text)) return false;
  }
  throw Exception("Invalid response: $geminiResponse");
}
