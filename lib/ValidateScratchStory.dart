import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ValidateScratchStory extends StatefulWidget {
  final String story;

  const ValidateScratchStory({Key? key, required this.story}) : super(key: key);

  @override
  _ValidateScratchStoryState createState() => _ValidateScratchStoryState();
}

class _ValidateScratchStoryState extends State<ValidateScratchStory> {
  bool _isLoading = false;
  String _message = "";

  // Function to validate story
  Future<bool> validateStory(String story) async {
    try {
      final response = await http.post(
        Uri.parse("https://us-central1-adept-ethos-432515-v9.cloudfunctions.net/Validate-Story"),
        body: {'text': story},
      );

      if (response.statusCode == 200) {
        print("200 isvalid");
        return getBooleanFromGemini(response.body);
      } else {
        throw Exception("Validation failed. Status code: ${response.statusCode}");
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
        Uri.parse("https://us-central1-adept-ethos-432515-v9.cloudfunctions.net/moderate"),
        body: {'text': story},
      );
      

      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body);
        final moderationResult = responseJson['moderationResult'];
        if (moderationResult == null || moderationResult['moderationCategories'] == null) {
          setState(() {
            _message = "Moderation result is missing or invalid.";
          });
          return false;
        }

        final moderationCategories = moderationResult['moderationCategories'] as List<dynamic>;

        return isStorySafeForKids(moderationCategories);
      } else {
        throw Exception("Moderation failed. Status code: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        _message = "Error during moderation: $e";
      });
      print("Error during moderation: $e");
      return false;
    }
  }

  // Function to check if story is safe for kids
  bool isStorySafeForKids(List categories) {
    print(categories);
    for (var category in categories) {
      if (category['confidence'] > 0.3) {
        print("Story is not safe for kids due to category: ${category['name']}");
        setState(() {
          _message = "Story is not safe for kids due to category: ${category['name']}";
        });
        return false;
      }
    }
    setState(() {
      _message = "Story is safe for kids!";
    });
    return true;
  }

  // Validate and moderate story
  Future<void> validateAndModerateStory() async {
    setState(() {
      _isLoading = true;
      _message = "";
    });

    final isValid = await validateStory(widget.story);
    print("isvalid ${isValid}");
    if (isValid) {
      final isSafe = await moderateStory(widget.story);
      print("issafe ${isSafe}");
      if (!isSafe) {
        setState(() {
          _message = "Story is not safe for kids.";
        });
      }
    } else {
      setState(() {
        _message = "Story validation failed.";
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Validate Scratch Story"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Text(widget.story, style: const TextStyle(fontSize: 16)),
              ),
            ),
            if (_message.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  _message,
                  style: TextStyle(
                    color: _message.contains("safe") ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ElevatedButton(
              onPressed: validateAndModerateStory,
              child: const Text("Validate and Moderate"),
            ),
          ],
        ),
      ),
    );
  }
}

// Function to get boolean from string response
bool getBooleanFromGemini(String geminiResponse) {
  final text = geminiResponse.trim().toLowerCase();
  const yesPatterns = [r'yes', r'true', r'yeah', r'yup', r'affirmative', r'correct', r'1'];
  const noPatterns = [r'no', r'false', r'nope', r'nah', r'negative', r'incorrect', r'0'];

  for (final pattern in yesPatterns) {
    if (RegExp(pattern).hasMatch(text)) return true;
  }
  for (final pattern in noPatterns) {
    if (RegExp(pattern).hasMatch(text)) return false;
  }
  throw Exception("Invalid response: $geminiResponse");
}

