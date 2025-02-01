import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'story_settings_screen.dart';
import 'package:page_transition/page_transition.dart';

class CharacterDetailsInputScreen extends StatefulWidget {
  final String title;

  const CharacterDetailsInputScreen({Key? key, required this.title}) : super(key: key);

  @override
  _CharacterDetailsInputScreenState createState() => _CharacterDetailsInputScreenState();
}

class _CharacterDetailsInputScreenState extends State<CharacterDetailsInputScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedGender = 'Boy';
  bool _submitted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Widget _buildGenderSegmentedButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Character Gender',
            style: GoogleFonts.poppins(
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<String>(
            segments: const <ButtonSegment<String>>[
              ButtonSegment<String>(
                value: 'Boy',
                label: Text('Boy'),
                icon: Icon(Icons.male),
              ),
              ButtonSegment<String>(
                value: 'Girl',
                label: Text('Girl'),
                icon: Icon(Icons.female),
              ),
            ],
            selected: {_selectedGender},
            onSelectionChanged: (Set<String> newSelection) {
              setState(() {
                _selectedGender = newSelection.first;
              });
            },
            style: ButtonStyle(
              padding: MaterialStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              ),
            ),
          ),
        ),
        if (_submitted && _selectedGender == null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Please select a gender',
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(color: Colors.red),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light(), // Override theme to light
      child: Scaffold(
        body: SingleChildScrollView( // Wrap the body in SingleChildScrollView to handle keyboard overlay
          child: Container(
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
                    SizedBox(height: 10),
                    Center(
                      child: RoundedImage(imagePath: 'assets/image04.png'),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Craft Your Main Character",
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
                      "Let's bring your character to life!",
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Character Name',
                        labelStyle: GoogleFonts.poppins(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Color(0xFF1A2259).withOpacity(0.4)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Color(0xFF1A2259)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter the character name";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _ageController,
                      decoration: InputDecoration(
                        labelText: 'Character Age',
                        labelStyle: GoogleFonts.poppins(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Color(0xFF1A2259).withOpacity(0.4)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Color(0xFF1A2259)),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter the character age";
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid age';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    _buildGenderSegmentedButton(),
                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _submitted = true;
                          });
                          if (_formKey.currentState!.validate() && _selectedGender != null) {
                            Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.rightToLeft,
                                child: StorySettingsScreen(
                                  title: widget.title,
                                  name: _nameController.text,
                                  Age: _ageController.text,
                                  gender: _selectedGender,
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A2259),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        ),
                        child: Text(
                          "Next",
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
