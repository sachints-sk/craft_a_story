import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart'; // For playing audio
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

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
  final user = FirebaseAuth.instance.currentUser;


  @override
  void initState() {
    super.initState();
    _loadSavedStory();
    _checkStoredAudio();
  }


  Future<void> _playAudioFromUrl(String userId) async {
    final audioUrl = 'https://storage.googleapis.com/craftastoryvoices/$userId.wav';

    try {
      // Play the audio from the URL
      await _audioPlayer.setUrl(audioUrl);
      await _audioPlayer.play();
      setState(() {
        _statusText = "Playing audio...";
      });
    } catch (e) {
      setState(() {
        _statusText = "Error playing audio.";
        print('Error playing audio: $e');
      });
    }
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

  Future<Uint8List?> _downloadAudio(String audioUrl) async {
    final response = await http.get(Uri.parse(audioUrl));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      print('Failed to download audio00: ${response.statusCode}');
      return null; // Return null if the download fails
    }
  }


  Future<void> _speakText(String text) async {

    setState(() {
      _statusText = "Generating audio...";
      _isLoading = true;
      _isAudioReady = false;
    });

    final url = Uri.parse('https://us-central1-adept-ethos-432515-v9.cloudfunctions.net/long-audio');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({

          "text": "",
          'userId': user?.uid,
          "languageCode": "ml-IN",
          "voiceName": "ml-IN-Wavenet-A"
        }),
      );

      if (response.statusCode == 200) {

        if (user != null) {
          final String userId = user!.uid; // Safe to use here
         // await _playAudioFromUrl(userId);
          final audioUrl = 'https://storage.googleapis.com/craftastoryvoices/${userId}.wav';
          final audioBytes = await _downloadAudio(audioUrl);
          if (audioBytes != null) {
            // Save the audio bytes as a temporary file (you can use this for FFmpeg)
            final audioFile = File('${(await getTemporaryDirectory()).path}/audio.mp3');
            await audioFile.writeAsBytes(audioBytes);
            print('Audio saved to: ${audioFile.path}');
            _storedAudioPath = audioFile.path;
            _playStoredAudio();
          } else {
            throw Exception("Failed to download audio");
          }
        } else {
          // Handle the case when the user is not logged in
          setState(() {
            _statusText = "User not logged in.";
          });
        }


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
              onPressed: _isLoading ? null : () => _speakText('പത്തു വയസ്സുകാരനായ നിഗേൽ, അലങ്കോലമായ തവിട്ടുനിറത്തിലുള്ള മുടി തലയിൽ ഒരു കുമ്പിൾ പോലെ കൂടിയിട്ട്, കുളത്തിന്റെ അരികിൽ മടി hesitateി നിന്നു, തണുത്ത വെള്ളം കണങ്കാലിൽ ചുറ്റിത്തിരിയുന്നു. തന്റെ അനിയത്തിയായ അമേലിയ വെള്ളത്തിലൂടെ എളുപ്പത്തിൽ തെന്നിമാറുന്നത് അവൻ എപ്പോഴും അഭിനന്ദിച്ചിരുന്നു, അവളുടെ സ്ട്രോക്കുകൾ മിനുസമുള്ളതും  ഒരു ദിവസം, നിഗേൽ നിരുത്സാഹിതനായി, വെള്ളം തന്റെ ശ്രമങ്ങളെ പ്രതിരോധിക്കുന്നതായി തോന്നി. അച്ഛൻ അവന്റെ നിരാശ ശ്രദ്ധിക്കുകയും അൽപ്പം കൂടി ശ്രദ്ധ കേന്ദ്രീകരിച്ച് വീണ്ടും ശ്രമിക്കാൻ അവനെ പ്രോത്സാഹിപ്പിക്കുകയും ചെയ്തു. നിഗേൽ ആഴത്തിൽ ശ്വാസിച്ചു, വെള്ളത്തിലൂടെ തെന്നിമാറുന്ന അമേലിയയെ ചിത്രീകരിച്ചു, വീണ്ടും ആരംഭിച്ചു. ഇത്തവണ, അത് വ്യത്യസ്തമായിരുന്നു. പുതുതായി കണ്ടെത്തിയ ദ്രവത്വത്തോടെ അവൻ ചലിച്ചു, അവന്റെ കൈകളും കാലുകളും ഏകകണ്ഠമായി പ്രവർത്തിച്ചു, തണുത്ത വെള്ളം ഒരു സൗഹൃദ ആലിംഗനം പോലെ അവന്റെ ചുറ്റും ഒഴുകുന്നു. അവൻ ഒടുവിൽ നീന്തുന്നുണ്ടെന്ന് മനസ്സിലായപ്പോൾ അഭിമാനത്തിന്റെ ഒരു തിരമാല അവനെ കഴുകി, വെറുതെ ആടിയല്ല. ആ ദിവസം മുതൽ, നിഗേൽ കുളത്തിൽ പതിവായി, നീന്തലിനോടുള്ള അവന്റെ സ്നേഹം ഓരോ സ്ട്രോക്കിലും വളരുന്നു. നീന്തൽ ലാപ്പുകളുടെ സന്തോഷം, സഹോദരിയുമായി മത്സരിക്കുന്നതിന്റെ സന്തോഷം, ചൂടുള്ള വേനൽക്കാല ദിവസം തണുത്ത വെള്ളത്തിലേക്ക് മുങ്ങുന്നതിന്റെ സന്തോഷം എന്നിവ അവൻ കണ്ടെത്തി. ഒരിക്കൽ വെള്ളത്തെ ഭയപ്പെട്ടിരുന്ന ആൺകുട്ടി നിഗേൽ ആത്മവിശ്വാസമുള്ള ഒരു നീന്തൽക്കാരനായി മാറി, അവന്റെ പ്രാരംഭ ഭയം വെള്ളത്തോടും അതിന്റെ എല്ലാ അത്ഭുതങ്ങളോടുമുള്ള ആഴത്തിലുള്ള സ്നേഹമായി മാറി. എത്ര കാലം നീന്തിലെങ്കിലും, ആ ആദ്യ വിജയ നിമിഷത്തിന്റെ ഓർമ്മ, അവന്റെ ശരീരം ഒടുവിൽ വെള്ളത്തിലൂടെ ഒന്നായി നീങ്ങുന്നതായി അനുഭവപ്പെട്ടപ്പോൾ, എല്ലായ്പ്പോഴും അവനോടൊപ്പം തുടരുമെന്ന് അവനറിയാമായിരുന്നു, അവന്റെ ധൈര്യത്തിന്റെയും സ്ഥിരോത്സാഹത്തിന്റെയും ഓർമ്മപ്പെടുത്തൽ.'),
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