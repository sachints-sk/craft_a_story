import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart'; // For playing audio
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String _statusText = "Ready to speak!";
  String _savedStory = '';
  bool _isLoading = false;
  bool _isAudioReady = false;
  bool _isStoredAudioAvailable = false;
  String? _storedAudioPath;

  @override
  void initState() {
    super.initState();
    _loadSavedStory();
    _checkStoredAudio();
  }

  // Function to load the saved story from the file
  Future<void> _loadSavedStory() async {
    setState(() {
      _statusText = "Loading saved story...";
      _isLoading = true;
    });

    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/generated_story.txt');

      if (await file.exists()) {
        String storyContent = await file.readAsString();
        setState(() {
          _savedStory = storyContent;
          _statusText = "Story loaded.";
        });
      } else {
        setState(() {
          _savedStory = "No saved story found.";
        });
      }
    } catch (e) {
      print('Error loading story: $e');
      setState(() {
        _savedStory = "Error loading the saved story.";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkStoredAudio() async {
    try {
      final directory = await getTemporaryDirectory();
      final audioFile = File('${directory.path}/output_audio.mp3');

      if (await audioFile.exists()) {
        setState(() {
          _isStoredAudioAvailable = true;
          _storedAudioPath = audioFile.path;
        });
      } else {
        setState(() {
          _isStoredAudioAvailable = false;
        });
      }
    } catch (e) {
      print('Error checking stored audio: $e');
      setState(() {
        _isStoredAudioAvailable = false;
      });
    }
  }

  Future<void> _speakText(String text) async {
    setState(() {
      _statusText = "Generating audio...";
      _isLoading = true;
      _isAudioReady = false;
    });

    final url = Uri.parse('https://us-central1-adept-ethos-432515-v9.cloudfunctions.net/createspeech');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'text': text}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final audioContent = data['audioContent'];
        await _saveAndPlayAudio(audioContent);
        setState(() {
          _statusText = "Audio ready!";
          _isAudioReady = true;
        });
        _checkStoredAudio(); // Check if the audio was saved successfully
      } else {
        setState(() {
          _statusText = "Error: ${response.statusCode}";
        });
        print('Error: ${response.body}');
      }
    } catch (e) {
      setState(() {
        _statusText = "Failed to generate audio.";
        print('Error: $e');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveAndPlayAudio(String base64Audio) async {
    final directory = await getTemporaryDirectory();
    final audioFile = File('${directory.path}/output_audio.mp3');

    try {
      final bytes = base64Decode(base64Audio);
      await audioFile.writeAsBytes(bytes);

      // Play the saved audio
      await _audioPlayer.setFilePath(audioFile.path);
      await _audioPlayer.play();
    } catch (e) {
      setState(() {
        _statusText = "Error playing audio.";
        print('Error playing audio: $e');
      });
    }
  }

  Future<void> _playStoredAudio() async {
    if (_storedAudioPath != null) {
      try {
        await _audioPlayer.setFilePath(_storedAudioPath!);
        await _audioPlayer.play();
        setState(() {
          _statusText = "Playing stored audio...";
        });
      } catch (e) {
        setState(() {
          _statusText = "Error playing stored audio.";
          print('Error playing stored audio: $e');
        });
      }
    } else {
      setState(() {
        _statusText = "No stored audio found.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Text to Speech Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_isLoading) ...[
              CircularProgressIndicator(),
              const SizedBox(height: 20),
            ],
            ElevatedButton(
              onPressed: _isLoading ? null : () => _speakText(''),
              child: const Text('Speak Text'),
            ),
            const SizedBox(height: 20),
            if (_isStoredAudioAvailable) ...[
              ElevatedButton(
                onPressed: _playStoredAudio,
                child: const Text('Play Stored Audio'),
              ),
            ],
            const SizedBox(height: 20),
            Text(_statusText),
          ],
        ),
      ),
    );
  }
}