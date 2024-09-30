import 'package:flutter/material.dart';


import 'testfolder/createimage.dart';
import 'testfolder/texttospeech.dart';
import 'testfolder/jsonimagegen.dart';

void main() {
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
          ],
        ),
      ),
    );
  }
}