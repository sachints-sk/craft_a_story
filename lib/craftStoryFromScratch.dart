import 'package:flutter/material.dart';
import 'ValidateScratchStory.dart';

class CraftStoryPage extends StatefulWidget {
  final String title;
  final String mode;

  const CraftStoryPage({Key? key, required this.title,required this.mode}) : super(key: key);
  @override
  _CraftStoryPageState createState() => _CraftStoryPageState();
}

class _CraftStoryPageState extends State<CraftStoryPage> {
  final TextEditingController _textController = TextEditingController();
  bool _isContinueEnabled = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {
      _isContinueEnabled = _textController.text.trim().isNotEmpty;
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (_isContinueEnabled) {
      // Navigate to the next page or save story logic here
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ValidateScratchStory(story:_textController.text, title: widget.title,mode: widget.mode), // Replace with your next page
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Craft Your Story",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

      ),
      body: Container(

        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8.0,
                        offset: Offset(6, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      controller: _textController,
                      maxLines: null,
                      style: TextStyle(fontSize: 18.0),
                      decoration: InputDecoration(
                        hintText: "Start writing your story...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: ElevatedButton(
                onPressed: _isContinueEnabled ? _onContinue : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor:  Color(0xFF1A2259),
                  disabledBackgroundColor: Colors.grey, // Disabled color
                ),
                child: Text(
                  "Continue",
                  style: TextStyle(fontSize: 18.0, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NextPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Next Page")),
      body: Center(child: Text("Next steps go here!")),
    );
  }
}
