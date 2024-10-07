import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart'; // For file access

class SavedStoryPage extends StatefulWidget {
  const SavedStoryPage({Key? key}) : super(key: key);

  @override
  State<SavedStoryPage> createState() => _SavedStoryPageState();
}

class _SavedStoryPageState extends State<SavedStoryPage> {
  String _savedStory = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedStory();
  }

  // Function to load the saved story from the file
  Future<void> _loadSavedStory() async {
    try {
      // Get the app's document directory
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/generated_story.txt');

      // Check if the file exists
      if (await file.exists()) {
        // Read the file content
        String storyContent = await file.readAsString();
        setState(() {
          _savedStory = storyContent;
          _isLoading = false;
        });
      } else {
        setState(() {
          _savedStory = "No saved story found.";
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading story: $e');
      setState(() {
        _savedStory = "Error loading the saved story.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Story'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator() // Show loading indicator
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Text(
              _savedStory,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }
}