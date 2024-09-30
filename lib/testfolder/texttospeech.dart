import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart'; // For service account authentication
import 'package:just_audio/just_audio.dart'; // For playing audio
import 'package:flutter/services.dart' show rootBundle; // For loading the JSON key

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
  String? _audioContent;
  String _statusText = "Ready to speak!";
  String? _accessToken; // Store the access token for the service account

  @override
  void initState() {
    super.initState();
    _authenticateWithServiceAccount(); // Authenticate when the app starts
  }

  // Method to authenticate using service account key
  Future<void> _authenticateWithServiceAccount() async {
    setState(() {
      _statusText = "Authenticating...";
    });

    // Load the service account key from the JSON file
    final String jsonKey = await rootBundle.loadString('assets/adept-ethos-432515-v9-1fa3e34d0b3e.json'); // Ensure the key is stored in assets

    // Parse the service account key JSON
    final accountCredentials = ServiceAccountCredentials.fromJson(jsonKey);

    // Define the required scopes
    final scopes = ['https://www.googleapis.com/auth/cloud-platform'];

    // Get the authenticated client
    final client = await clientViaServiceAccount(accountCredentials, scopes);

    // Extract the OAuth 2.0 token
    final accessToken = client.credentials.accessToken.data;

    setState(() {
      _accessToken = accessToken;
      _statusText = "Authenticated!";
    });

    print("Access Token: $_accessToken");
  }

  Future<void> _speakText(String text) async {
    if (_accessToken == null) {
      setState(() {
        _statusText = "Please wait for authentication!";
      });
      return;
    }

    setState(() {
      _statusText = "Generating audio...";
    });

    // Construct the API request URL
    final url = Uri.parse('https://texttospeech.googleapis.com/v1/text:synthesize');

    // Construct the request body
    final Map<String, dynamic> body = {
      'input': {'text': "The air crackled with static electricity as Nigel tightened the final bolt on his Time Hopper. Built from spare computer parts and his dad’s old lawnmower engine (don't worry, he asked!), the machine hummed with unpredictable energy. Nigel’s heart pounded with a mix of nerves and excitement. Today, he was going to meet Leonardo da Vinci! He punched in the date – April 15, 1452 – the year da Vinci was born. With a flash of light and a dizzying lurch, Nigel found himself in a bustling workshop, filled with the scent of fresh paint and wood shavings. A man with piercing blue eyes and a long, flowing beard looked up in surprise."},
      'voice': {
        'languageCode': 'en-US', // Set your desired language
        'name': 'en-US-Standard-F' // Choose a voice
      },
      'audioConfig': {
        'audioEncoding': 'MP3',
        "effectsProfileId": [
          "handset-class-device"
        ],
        "pitch": 2,
        "speakingRate": 1,
      },
    };

    // Send the API request
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken', // Use the retrieved token
        },
        body: jsonEncode(body),
      );

      // Process the response
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          _audioContent = data['audioContent'];
          _statusText = "Audio ready!";
        });
      } else {
        setState(() {
          _statusText = "Error: ${response.statusCode}";
        });
        print('Error: ${response.statusCode}');
        print('Error message: ${response.body}');
      }
    } catch (e) {
      setState(() {
        _statusText = "Error: $e";
      });
      print('Error: $e');
    }
  }

  Future<void> _playAudio() async {
    if (_audioContent != null) {
      final bytes = base64Decode(_audioContent!);
      await _audioPlayer.setAudioSource(AudioSource.uri(
        Uri.dataFromBytes(bytes, mimeType: 'audio/mpeg'),
      ));
      await _audioPlayer.play();
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
            ElevatedButton(
              onPressed: () => _speakText('Hello, how are you?'),
              child: const Text('Speak Text'),
            ),
            const SizedBox(height: 20),
            if (_audioContent != null) ...[
              ElevatedButton(
                onPressed: _playAudio,
                child: const Text('Play Audio'),
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