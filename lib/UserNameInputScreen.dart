import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:page_transition/page_transition.dart';
import 'StoryIntroScreen.dart';

class UserNameInputScreen extends StatefulWidget {
  @override
  _UserNameInputScreenState createState() => _UserNameInputScreenState();
}

class _UserNameInputScreenState extends State<UserNameInputScreen> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false; // Add this line


  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveNameToFirestore() async {
    setState(() {
      _isLoading = true;
    });
    try{
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

        await userDocRef.update({
          'name': _nameController.text,
        });
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            child:  StoryIntroScreen(),
          ),
        );

        print("saved");

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User Not Logged In'))
        );
      }
    } catch (e){
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save name: $e'))
      );
    }
    finally{
      setState(() {
        _isLoading = false;
      });
    }
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
        child: Column(
          children: [
            SizedBox(height: 40),
            Expanded(
              flex: 2,
              child: Center(
                child: Stack(
                    alignment: Alignment.center,
                    children:[
                      Lottie.asset(
                        'assets/welcome.json',
                        width: 300,
                        height: 300,
                        fit: BoxFit.contain,
                        repeat: false,
                      ),

                    ]
                ),
              ),
            ),

            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "What's Your Name?",
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A2259),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Please enter your name to personalize your story creation experience.",
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Your Name',
                          labelStyle: GoogleFonts.poppins(),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: Color(0xFF1A2259).withOpacity(0.4))
                          ),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: Color(0xFF1A2259))
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your name.";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 30),
                      SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : () {
                              if (_formKey.currentState!.validate()) {
                                _saveNameToFirestore();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:  const Color(0xFF1A2259),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              textStyle: const TextStyle(fontSize: 18),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25)),
                            ),
                            child: _isLoading ?  CircularProgressIndicator()
                                : Text("Continue",
                                style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                )),
                          ))
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}