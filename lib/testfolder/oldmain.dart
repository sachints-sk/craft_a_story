import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


import 'testfolder/createimage.dart';
import 'testfolder/texttospeech.dart';
import 'testfolder/jsonimagegen.dart';
import 'testfolder/combineaudiovideo.dart';
import 'testfolder/createstory.dart';
import 'testfolder/readstory.dart';
import 'testfolder/homeScreen.dart';
import 'signinpage.dart';
import 'home.dart';
import 'processingpagetest.dart';
import 'newvideoplayer.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Important!

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const CraftAStoryApp()); // Start your app
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
      home: const HomeScreen(), // This is now your home screen
    );
  }
}

// --- Home Screen ---
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Craft-a-Story"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SignInPage(),
                  ),
                );
              },
              child: const Text("signup"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ImageGenerationPage(),
                  ),
                );
              },
              child: const Text("Go to Image Generator"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyApp(),
                  ),
                );
              },
              child: const Text("Go to Text to Speech"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const JsonImageGenerator(),
                  ),
                );
              },
              child: const Text("json img gen"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CombineAudioVideo(),
                  ),
                );
              },
              child: const Text("combine audiovid"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StoryCreationPage(),
                  ),
                );
              },
              child: const Text("create"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SavedStoryPage(),
                  ),
                );
              },
              child: const Text("read"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CraftAStoryApphome(),
                  ),
                );
              },
              child: const Text("home"),
            ),
          ],
        ),
      ),
    );
  }
}