import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io'; // For file operations
import 'package:path_provider/path_provider.dart'; // For local storage

class StoryCreationPage extends StatefulWidget {
  const StoryCreationPage({Key? key}) : super(key: key);

  @override
  State<StoryCreationPage> createState() => _StoryCreationPageState();
}

class _StoryCreationPageState extends State<StoryCreationPage> {
  final _formKey = GlobalKey<FormState>(); // For form validation

  // Input fields with controllers
  final TextEditingController _kidNameController = TextEditingController();
  final TextEditingController _kidAgeController = TextEditingController();
  String? _selectedStoryMode; // For dropdown
  final TextEditingController _startingPointController = TextEditingController();
  final TextEditingController _plotController = TextEditingController();
  final TextEditingController _outcomeController = TextEditingController();

  String _generatedStory = '';
  bool _isLoading = false;

  // List of story modes for the dropdown
  final List<String> _storyModes = [
    'Adventure',
    'Fantasy',
    'Sci-Fi',
    'Mystery',
    'Humorous',
  ];

  Future<void> _generateStory() async {
    if (_formKey.currentState!.validate()) { // Validate the form
      setState(() {
        _isLoading = true;
      });

      // Construct the prompt with user inputs
      String prompt = "Write a kids' story with the following details:\n";
      prompt += "Kid's Name: ${_kidNameController.text}\n";
      prompt += "Kid's Age: ${_kidAgeController.text}\n";
      prompt += "Story Mode: $_selectedStoryMode\n";
      if (_startingPointController.text.isNotEmpty) {
        prompt += "Starting Point: ${_startingPointController.text}\n";
      }
      if (_plotController.text.isNotEmpty) {
        prompt += "Plot: ${_plotController.text}\n";
      }
      if (_outcomeController.text.isNotEmpty) {
        prompt += "Outcome: ${_outcomeController.text}\n";
      }

      try {
        final response = await http.post(
          Uri.parse(
              'https://us-central1-adept-ethos-432515-v9.cloudfunctions.net/Create-Story'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'prompt': prompt}),
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          setState(() {
            _generatedStory = data['story'];
            _isLoading = false;
          });

          // Save the generated story to local storage
          await _saveStoryToLocalFile(data['story']);
        } else {
          // Error handling
          print('Error: ${response.statusCode}');
          print('Error message: ${response.body}');
          setState(() {
            _isLoading = false;
            _generatedStory = "Error generating story.";
          });
        }
      } catch (e) {
        // Error handling
        setState(() {
          _isLoading = false;
          _generatedStory = "Error: $e";
        });
        print('Error: $e');
      }
    }
  }

  // Function to save the story to a file in local storage
  Future<void> _saveStoryToLocalFile(String storyContent) async {
    try {
      // Get the app's document directory
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/generated_story.txt');

      // Write the story content to the file
      await file.writeAsString(storyContent);

      print('Story saved to: ${file.path}');
    } catch (e) {
      print('Error saving story to file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Story Generator'),
      ),
      body: SingleChildScrollView( // Allow scrolling for longer forms
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form( // Wrap the inputs with a Form widget
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: _kidNameController,
                  decoration: const InputDecoration(
                    labelText: "Kid's Name",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter a name";
                    }
                    return null; // Return null if the input is valid
                  },
                ),
                TextFormField(
                  controller: _kidAgeController,
                  decoration: const InputDecoration(
                    labelText: "Kid's Age",
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter an age";
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Story Mode",
                  ),
                  value: _selectedStoryMode,
                  items: _storyModes.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedStoryMode = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please select a story mode";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _startingPointController,
                  decoration: const InputDecoration(
                    labelText: "Starting Point (Optional)",
                  ),
                ),
                TextFormField(
                  controller: _plotController,
                  decoration: const InputDecoration(
                    labelText: "Plot (Optional)",
                  ),
                ),
                TextFormField(
                  controller: _outcomeController,
                  decoration: const InputDecoration(
                    labelText: "Outcome (Optional)",
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _generateStory,
                  child: const Text('Generate Story'),
                ),
                const SizedBox(height: 20),
                if (_isLoading)
                  const CircularProgressIndicator(),
                const SizedBox(height: 20),
                Container(
                  height: 300, // Fixed height for the generated story
                  child: SingleChildScrollView(
                    child: Text(_generatedStory),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}