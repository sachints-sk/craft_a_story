import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart'; // For storage permission
import 'processingpagetest.dart';
import 'package:page_transition/page_transition.dart';
import 'craftStoryFromScratch.dart';

class CreateStory extends StatefulWidget {

  const CreateStory({Key? key, }) : super(key: key);

  @override
  State<CreateStory> createState() => _CreateStoryState();
}

class _CreateStoryState extends State<CreateStory> {
  final _formKey = GlobalKey<FormState>();

  // Input field controllers
  final TextEditingController _storyTitleController = TextEditingController();


  String? _selectedStoryType;

  bool _submitted = false; // Flag to track form submission attempt


  final List<String> _storyTypes = [
    'Adventure', 'Fantasy', 'Sci-Fi', 'Mystery', 'Humorous',
  ];

  bool _isLoading = false;

  Future<void> _navigateToProcessingPage() async {
    setState(() {
      _submitted = true; // Mark form as submitted when the button is clicked
    });

    if (_formKey.currentState!.validate() && _selectedStoryType != null ) {


      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.rightToLeft,
          child: CraftStoryPage( mode:_selectedStoryType!, title: _storyTitleController.text,),
        ),
      );
    }
  }

  // TextFormField helper with validation
  Widget _buildTextFormField(TextEditingController controller, String hintText, String errorMessage) {
    return TextFormField(
      controller: controller,
      validator: (value) => value == null || value.isEmpty ? errorMessage : null,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildStoryTypeChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Story Type',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: _storyTypes.map((String storyType) {
            return ChoiceChip(
              label: Text(storyType),
              selected: _selectedStoryType == storyType,
              onSelected: (bool selected) {
                setState(() {
                  _selectedStoryType = selected ? storyType : null;
                });
              },
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
              labelStyle: TextStyle(
                color: _selectedStoryType == storyType
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurface,
              ),
            );
          }).toList(),
        ),
        if (_submitted && _selectedStoryType == null)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              'Please select a story type',
              style: TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Imagine Your Story', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                child: Image.asset(
                  'assets/personwritting2.png',
                  height: 200, // Adjust height as needed
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              const Text('Story Title', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildTextFormField(_storyTitleController, 'The Magic Forest', 'Please enter a story title'),

              const SizedBox(height: 16),
              _buildStoryTypeChips(),


              const SizedBox(height: 32),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _navigateToProcessingPage,


                    style: ElevatedButton.styleFrom(
                      backgroundColor:  const Color(0xFF1A2259),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                    child: const Text('Continue', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              if (_isLoading) const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

