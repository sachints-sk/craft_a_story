import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'FirstStoryProccessing.dart';

class StorySettingsScreen extends StatefulWidget {
  final String title;
  final String name;
  final String Age;
  final String gender;

  const StorySettingsScreen({Key? key, required this.title, required this.name, required this.Age, required this.gender}) : super(key: key);




  @override
  _StorySettingsScreenState createState() => _StorySettingsScreenState();
}

class _StorySettingsScreenState extends State<StorySettingsScreen> {
  String? _selectedStoryType;
  final _formKey = GlobalKey<FormState>();
  final _plotController = TextEditingController();
  bool _submitted = false;

  final List<String> _storyTypes = ['Adventure', 'Fantasy', 'Educational', 'Sci-Fi','Mystery'];


  @override
  void dispose() {
    _plotController.dispose();
    super.dispose();
  }


  Widget _buildStoryTypeChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
              'Story Type',
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              )
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
              backgroundColor: Colors.white70,

              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),

            );
          }).toList(),
        ),
        if (_submitted && _selectedStoryType == null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
                'Please select a story type',
                style: GoogleFonts.poppins(
                  textStyle: const TextStyle(color: Colors.red),
                )
            ),
          ),
      ],
    );
  }



  Widget _buildStoryPlotInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Required Story Plot',
            style: GoogleFonts.poppins(
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        TextFormField(
          controller: _plotController,
          maxLines: 3, // Allows for multi-line input
          decoration: InputDecoration(
              hintText: 'Enter a brief plot for your story',
              hintStyle: GoogleFonts.poppins(
                textStyle: TextStyle(color: Colors.grey.shade500),
              ),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Color(0xFF1A2259).withOpacity(0.4))
              ),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Color(0xFF1A2259))
              )
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please enter a story plot";
            }
            return null;
          },
        ),
      ],
    );
  }


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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Center(
                  child: RoundedImage(imagePath: 'assets/personwriting.png'),
                ),
                SizedBox(height: 20),
                Text(
                  "What kind of Story do you want ?",
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
                  "Choose the story type and plot to bring your story to life!",
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ),
                SizedBox(height: 10),
                _buildStoryTypeChips(),
                SizedBox(height: 10),
                _buildStoryPlotInput(),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (){
                      setState(() {
                        _submitted = true;
                      });
                      if(_formKey.currentState!.validate() && _selectedStoryType != null){
                      //  Navigator.pushNamed(context, '/story-creation-loading');
                        String prompt = "Write a kids' story with the following details:\n";
                        prompt += "Title: ${widget.title}\n";
                        prompt += "Character's Name: ${widget.name}\n";
                        prompt += "Gender: ${widget.gender}\n";
                        prompt += "Character's Age: ${widget.Age}\n";
                        prompt += "Story Mode: $_selectedStoryType\n";
                        prompt += "Story Plot: ${_plotController.text}\n";

                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child:  ProcessingPage(title: widget.title,prompt: prompt,mode: _selectedStoryType!,language: "en-US",voice: "en-US-Journey-F",),
                          ),
                        );





                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:  const Color(0xFF1A2259),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                    ),
                    child: Text(
                      "Create My Story!",
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
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


class RoundedImage extends StatelessWidget {
  final String imagePath;

  const RoundedImage({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: constraints.maxHeight * 0.2,
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