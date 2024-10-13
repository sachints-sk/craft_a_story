import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import for FirebaseAuth

import 'signinpage.dart';
import 'home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const CraftAStoryApp());
}

class CraftAStoryApp extends StatelessWidget {
  const CraftAStoryApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Craft-a-Story',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Use a StreamBuilder to listen for authentication state changes
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // If the user is logged in
          if (snapshot.hasData) {
            return const CraftAStoryApphome(); // Navigate to your home page
          } else {
            return const SignInPage(); // Navigate to sign-in page
          }
        },
      ),
    );
  }
}