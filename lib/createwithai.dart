import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart'; // For storage permission
import 'processingpagetest.dart';
import 'package:page_transition/page_transition.dart';

class CreateStoryWithAI extends StatefulWidget {
  const CreateStoryWithAI({Key? key}) : super(key: key);

  @override
  State<CreateStoryWithAI> createState() => _CreateStoryWithAIState();
}

class _CreateStoryWithAIState extends State<CreateStoryWithAI> {
  final _formKey = GlobalKey<FormState>();

  // Input field controllers
  final TextEditingController _storyTitleController = TextEditingController();
  final TextEditingController _characterNameController = TextEditingController();
  final TextEditingController _characterAgeController = TextEditingController();
  final TextEditingController _storySettingController = TextEditingController();

  String? _selectedStoryType;
  String? _selectedGender; // Add variable to store selected gender

  final List<String> _genders = ['Boy', 'Girl'];

  // List of story types for the dropdown
  final List<String> _storyTypes = [
    'Adventure',
    'Fantasy',
    'Sci-Fi',
    'Mystery',
    'Humorous',
  ];

  String _generatedStory = '';
  bool _isLoading = false;

  Future<void> _navigateToProcessingPage() async {
    if (_formKey.currentState!.validate()) {
      // Construct the prompt
      String prompt = "Write a kids' story with the following details:\n";
      prompt += "Title: ${_storyTitleController.text}\n";
      prompt += "Kid's Name: ${_characterNameController.text}\n";
      prompt += "Gender: $_selectedGender\n"; // Add the selected gender to the prompt
      prompt += "Kid's Age: ${_characterAgeController.text}\n";
      prompt += "Story Mode: $_selectedStoryType\n";
      if (_storySettingController.text.isNotEmpty) {
        prompt += "Starting Point: ${_storySettingController.text}\n";
      }

      // Navigate to ProcessingPage and pass the prompt

      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.rightToLeft, // Slide transition from right to left
          child: ProcessingPage(prompt: prompt,title:_storyTitleController.text ,),
        ),
      );
    }
  }
  // Function to save the story to a local file
  Future<void> _saveStoryToLocalFile(String storyContent) async {
    // Request storage permission (Android)
    if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
        if (!status.isGranted) {
          // Handle permission denial
          print('Storage permission denied.');
          return;
        }
      }
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/generated_story.txt');
      await file.writeAsString(storyContent);
      print('Story saved to: ${file.path}');
      // Optional: Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Story saved!')),
      );
    } catch (e) {
      print('Error saving story to file: $e');
      // Optional: Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save story.')),
      );
    }
  }

  // Helper function to build text fields
  Widget _buildTextField(TextEditingController controller, String hintText) {
    return TextField(
      controller: controller,

      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  // Helper function to build the story type dropdown
  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedStoryType,
      decoration: InputDecoration(
        labelText: 'Story Type',
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: _storyTypes.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedStoryType = newValue;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a story type';
        }
        return null;
      },
    );
  }
  // Helper function to build the gender dropdown
  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      decoration: InputDecoration(
        labelText: 'Character Gender', // Label for the dropdown
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: _genders.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedGender = newValue;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a gender';
        }
        return null;
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF161825),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,color: Colors.white,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Imagine Your Story',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Story Title Input
              const Text(
                'Story Title',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildTextField(_storyTitleController, 'The Magic Forest'),

              // Main Character Name Input
              const SizedBox(height: 16),
              const Text(
                'Main Character Name',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildTextField(_characterNameController, 'Lily'),

              const SizedBox(height: 16), // Add some spacing

              // Gender Dropdown
              const Text(
                'Character Gender',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildGenderDropdown(),// Story Type Dropdown
              const SizedBox(height: 16),
              const Text(
                'Story Type',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildDropdown(),

              // Character Age Input
              const SizedBox(height: 16),
              const Text(
                'Character Age',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildTextField(_characterAgeController, '8'),

              // Story Setting Input
              const SizedBox(height: 16),
              const Text(
                'Story Setting',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildTextField(_storySettingController, 'A magical forest'),

              const SizedBox(height: 32),
              // Create Story Button
              Center(
                child: ElevatedButton(
                  onPressed: _navigateToProcessingPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E314E),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text('Craft Story',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
              if (_isLoading) const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

// Separate page to display the generated story
class StoryDisplayPage extends StatelessWidget {
  final String story;

  const StoryDisplayPage({Key? key, required this.story}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Generated Story"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(story),
        ),
      ),
    );
  }
}