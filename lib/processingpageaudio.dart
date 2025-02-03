import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:fal_client/fal_client.dart';
import 'package:image/image.dart' as img;
import 'package:googleapis_auth/auth_io.dart'; // For service account authentication
import 'package:just_audio/just_audio.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:chewie/chewie.dart';
import 'dart:async'; // For Timer
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';
import 'newvideoplayer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:just_audio/just_audio.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'newaudioplayer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'buycredits.dart';
import 'package:firebase_analytics/firebase_analytics.dart';




class ProcessingPageAudio extends StatefulWidget {
  final String prompt; // Receive the prompt
  final String title;
  final String language;
  final String voice;
  final String mode;

  const ProcessingPageAudio({Key? key, required this.prompt,required this.title,required this.language,required this.voice, required this.mode}) : super(key: key);

  @override
  State<ProcessingPageAudio> createState() => _ProcessingPageAudioState();
}

class _ProcessingPageAudioState extends State<ProcessingPageAudio> {
  final fal = FalClient.withCredentials(
      "4fad3a2a-9580-4460-a015-71224c171ca2:88cd0149a1673ef98b55fc87849301c8");
  int scenelength = 0;

  String _statusText = "Ready to generate!";
  List<String> _generatedImageUrls = [];
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController; // Add ChewieController
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? audioContent;

  String _statusText2 = "audio not generated!";
  String? _accessToken;
  String videoPath = "";
  String coverImageUrl="";
  int _scenelength = 0;
  Duration _audioDuration = Duration.zero;
  double _loadingProgress = 0.0; // Track loading progress (0.0 to 1.0)
  Timer? _timer;
  String translatedStory ="";


  bool _isLoading = false;
  bool _isAudioReady = false;
  bool _isStoredAudioAvailable = false;
  String _storedAudioPath="";
  final user = FirebaseAuth.instance.currentUser;



  @override
  void initState() {
    super.initState();
    _processStory(); // Start processing the story as soon as the page loads

  }

  @override
  void dispose() {
    _timer?.cancel();

    super.dispose();
  }




  Future<bool> canCreateStory(String userId, int requiredCredits) async {
    try {
      // Reference to the Firestore user document
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      // Check if the document exists
      if (!userDoc.exists) {
        print("User document not found.");
        return false;
      }

      // Extract user's current credits
      final userCredits = userDoc['credits'] as int? ?? 0;

      // Compare credits
      return userCredits >= requiredCredits;
    } catch (e) {
      print("Error checking story eligibility: $e");
      return false; // Return false in case of an error
    }
  }





  // Main function to handle all the processing steps
  Future<void> _processStory() async {
    Trace customTrace = FirebasePerformance.instance.newTrace('Create-audio-Story');
    await customTrace.start();
    await FirebaseAnalytics.instance.logEvent(
      name: 'Story_Created_Audio',
      parameters: {
        'user_email':user!.email.toString(),
      },
    );
    try {
      await _clearOldImages();
      await _clearOldAudio();

      bool eligible= await canCreateStory(user!.uid,  2);
      print("Eligible : $eligible");

      if(eligible){

        _timer = await Timer.periodic(const Duration(milliseconds: 50), (timer) {
          setState(() {
            _loadingProgress += 0.01; // Increase progress by 1% every 50ms
            if (_loadingProgress >= 0.02) {
              _timer?.cancel(); // Stop the timer when progress reaches 100%
              // You can navigate to the next screen or perform other actions here
            }
          });
        });
        setState(() {
          _statusText = "Creating Story...";
        });

        // 2. Generate the Story
        String story = await _generateStoryText(widget.prompt);
        _timer =await Timer.periodic(const Duration(milliseconds: 50), (timer) {
          setState(() {
            _loadingProgress += 0.01; // Increase progress by 1% every 50ms
            if (_loadingProgress >= 0.4) {
              _timer?.cancel(); // Stop the timer when progress reaches 100%
              // You can navigate to the next screen or perform other actions here
            }
          });
        });


        setState(() {
          _statusText = "Creating Audio...";
        });

        await _speakTextTranslated(story);

        _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
          setState(() {
            _loadingProgress += 0.01; // Increase progress by 1% every 50ms
            if (_loadingProgress >= 0.6) {
              _timer?.cancel(); // Stop the timer when progress reaches 100%
              // You can navigate to the next screen or perform other actions here
            }
          });
        });

        setState(() {
          _statusText = "Creating prompt...";
        });

        final coverPrompt = await _getcoverPrompt(story) as String;
        _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
          setState(() {
            _loadingProgress += 0.01; // Increase progress by 1% every 50ms
            if (_loadingProgress >= 0.9) {
              _timer?.cancel(); // Stop the timer when progress reaches 100%
              // You can navigate to the next screen or perform other actions here
            }
          });
        });

        setState(() {
          _statusText = "Creating Cover...";
        });
        coverImageUrl = await _generateCoverImage(coverPrompt) ?? '';// Make coverImageUrl nullable
        print("Cover image URL: $coverImageUrl");
        await _DeductCredits();
        _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
          setState(() {
            _loadingProgress += 0.01; // Increase progress by 1% every 50ms
            if (_loadingProgress >= 1) {
              _timer?.cancel(); // Stop the timer when progress reaches 100%
              // You can navigate to the next screen or perform other actions here
            }
          });
        });



        setState(() {
          _statusText = "Story created! Ready to play";
        });

        await customTrace.stop();

        if(widget.language=="en-US"){
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft, // Slide transition from right to left
              child: NewAudioPlayer(

                title: widget.title,
                voice: widget.voice,
                description: story,
                coverurl: coverImageUrl,
                mode:widget.mode,
                audioPath:_storedAudioPath,
              ),
            ),
          );
        }else{
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft, // Slide transition from right to left
              child: NewAudioPlayer(

                title: widget.title,
                voice: widget.voice,
                description: translatedStory,
                coverurl: coverImageUrl,
                mode:widget.mode,
                audioPath:_storedAudioPath!,

              ),
            ),
          );
        }
      }else {
        _showInsufficientCreditsDialog(context);

      }







    } catch (e) {
      print('Error during processing: $e');
      _showStoryCreationErrorDialog(context);
    }
  }



  Future<void> _DeductCredits() async {
    setState(() {
      _statusText = "Updating Credits ....";
    });
    try {
      final response = await http.post(
        Uri.parse(
            'https://us-central1-craft-a-story.cloudfunctions.net/DeductCredits'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': user!.uid,
          'creditsToDeduct': 2,
        }),
      );

      if (response.statusCode == 200) {
        print("Credits deducted successfully");
      } else {
        throw Exception('Failed to deduct credit: ${response.statusCode}');
        _showStoryCreationErrorDialog(context);
      }
    } catch (e) {
      print('Error Deduct Credit: $e');
      _showStoryCreationErrorDialog(context);
      throw e; // Rethrow the exception
    }
  }

  void _showInsufficientCreditsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GiffyDialog.lottie(
          Lottie.asset(
            'assets/coinswallet.json',
            width: 170,
            height: 170,
          ),
          title: Text(
            'Insufficient Credits',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.w600,
              color: Colors.redAccent,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Oops! You don\'t have enough credits to craft a story.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18.0),
              ),
              const SizedBox(height: 16),
              const Text(
                "Top up your credits now to continue your creative journey!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.0),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pop();// Close the dialog
              },
              child: Text(
                'Close',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                _processStory();
                Navigator.of(context).pop();
              },
              child: Text(
                'Retry',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:  const Color(0xFF1A2259),

              ),
              onPressed: () {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child:  PurchaseCreditsPage(),
                  ),
                ); // Navigate to Buy Credits page
              },
              child: Text(
                'Buy Credits',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }


  void _showStoryCreationErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GiffyDialog.lottie(
          Lottie.asset(
            'assets/error2.json', // Replace with your error animation (like a warning or error icon)
            width: 170,
            height: 170,
          ),
          title: Text(
            'Error Occurred',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.w600,
              color: Colors.redAccent,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              SizedBox(height: 10),
              Text(
                "Something went wrong while creating your story. Please try again .",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.0),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                'Close',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                _processStory(); // Retry story creation
                Navigator.of(context).pop();
              },
              child: Text(
                'Retry',
                style: TextStyle(color: Colors.grey),
              ),
            ),

          ],
        );
      },
    );
  }




// Function to get character descriptions from your Cloud Function
  Future<String> _getcoverPrompt(String story) async {
    setState(() {
      _statusText = "Shaping the heroes ...";
    });

    try {
      final response = await http.post(
        Uri.parse(
            'https://us-central1-adept-ethos-432515-v9.cloudfunctions.net/createCoverImagePrompt'),
        // Your Cloud Function URL
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
            {'story': story}), // Send the story in the request body
      );

      if (response.statusCode == 200) {
        // Split the plain text response into a list of lines (character descriptions)
        String descriptions = response.body.toString();
        print(descriptions);
        return descriptions;
      } else {
        throw Exception(
            'Failed to get cover Prompt: ${response.statusCode}');
        _showStoryCreationErrorDialog(context);
      }
    } catch (e) {
      print('Error getting Cover Prompt: $e');
      _showStoryCreationErrorDialog(context);
      throw e; // Rethrow the exception to be handled in the main try...catch
    }
  }

  Future<void> _speakTextTranslated(String text) async {

    setState(() {
      _statusText = "Generating audio...";
      _isLoading = true;
      _isAudioReady = false;
    });

    print("translated");
    print(widget.voice);
    final url = Uri.parse('https://us-central1-adept-ethos-432515-v9.cloudfunctions.net/long-audio');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({

          "text": text,
          'userId': user?.uid,
          "languageCode": widget.language,
          "voiceName": widget.voice
        }),
      );

      if (response.statusCode == 200) {

        if (user != null) {
          final data = jsonDecode(response.body);
          translatedStory = data['finaltext'];
          print(translatedStory);
          final String userId = user!.uid; // Safe to use here
          // await _playAudioFromUrl(userId);
          final audioUrl = 'https://storage.googleapis.com/craftastoryvoices2/${userId}.wav?t=${DateTime.now().millisecondsSinceEpoch}';
          final audioBytes = await _downloadAudio(audioUrl);

          if (audioBytes != null) {

            // Save audio bytes as a temporary file
            final tempDir = await getTemporaryDirectory();
            final audioFile1 = File('${tempDir.path}/audio.wav');
            await audioFile1.writeAsBytes(audioBytes);

            // Set the audio source to the saved file
            await _audioPlayer.setFilePath(audioFile1.path);
            // Get the audio duration
            _audioDuration = _audioPlayer.duration ?? Duration.zero;
            print("Audio duration: $_audioDuration");




            final audioFile = File('${(await getTemporaryDirectory()).path}/audio.mp3');
            await audioFile.writeAsBytes(audioBytes);
            print('Audio saved to: ${audioFile.path}');
            _storedAudioPath = audioFile.path;

          } else {
            throw Exception("Failed to download audio");
            _showStoryCreationErrorDialog(context);
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
        // Check if the audio was saved successfully
      } else {
        setState(() {
          _statusText = "Error: ${response.statusCode}";
        });
        print('Error: ${response.body}');
      }
    } catch (e) {
      setState(() {
        _statusText = "Failed to generate audio.";
        _showStoryCreationErrorDialog(context);
        print('Error: $e');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  Future<Uint8List?> _downloadAudio(String audioUrl) async {
    final response = await http.get(Uri.parse(audioUrl));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      print('Failed to download audio: ${response.statusCode}');

      return null; // Return null if the download fails
    }
  }

  Future<void> _clearOldAudio() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final audioFilePath = '${tempDir.path}/audio.wav';
      final audioFile = File(audioFilePath);

      if (await audioFile.exists()) {
        await audioFile.delete();
        print('Old audio cleared.');
      } else {
        print('No old audio to clear.');
      }
    } catch (e) {
      print('Error clearing old audio: $e');
    }
  }




  // Function to generate the story text using Gemini
  Future<String> _generateStoryText(String prompt) async {
    setState(() {
      _statusText = "Crafting your tale ....";
    });
    try {
      final response = await http.post(
        Uri.parse(
            'https://us-central1-adept-ethos-432515-v9.cloudfunctions.net/Create-Story'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'prompt': prompt}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['story'];
      } else {
        throw Exception('Failed to generate story: ${response.statusCode}');
        _showStoryCreationErrorDialog(context);
      }
    } catch (e) {
      print('Error generating story: $e');
      _showStoryCreationErrorDialog(context);
      throw e; // Rethrow the exception
    }
  }



  Future<String?> _generateCoverImage(String coverPrompt) async {


    String prompt = coverPrompt; // Use the first scene as the prompt

    // Make the API call to generate the cover image
    final output = await fal.subscribe("fal-ai/flux/schnell", input: {
      "prompt": prompt,
      "image_size": "square", // Set landscape aspect ratio
      "num_inference_steps": 4,
      "num_images": 1,
      "enable_safety_checker": false
    }, logs: true, webhookUrl: "https://optional.webhook.url/for/results",
        onQueueUpdate: (update) {
          print(update);
        });

    final images = output.data?["images"];
    if (images != null && images.isNotEmpty && images is List) {
      return images[0]["url"]; // Return the cover image URL
    } else {
      return null;
    }
  }


  Future<void> _clearOldImages() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final dir = Directory(tempDir.path);

      // List all files in the directory
      final List<FileSystemEntity> files = dir.listSync();

      // Delete all image files with the pattern "image_*.jpg"
      for (var file in files) {
        if (file is File && file.path.contains('image_') &&
            file.path.endsWith('.jpg')) {
          await file.delete();
        }
      }
      print('Old images cleared.');
    } catch (e) {
      print('Error clearing old images: $e');
    }
  }

  // Function to simulate a loading process
  void _startLoadingSimulation() {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        _loadingProgress += 0.01; // Increase progress by 1% every 50ms
        if (_loadingProgress >= 1.0) {
          _timer?.cancel(); // Stop the timer when progress reaches 100%
          // You can navigate to the next screen or perform other actions here
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Blue circle with icons (replace with your actual icons)
              Container(
                width: 220,
                height: 220,

                child: Center( // Center the icon
                  child:  Lottie.asset(
                    'assets/Animation001.json',  // AI animation
                    width: 220,
                    height: 220,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Generating Your Story',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,

                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Please wait while we craft a perfect tale for you.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 30),
              // Linear Progress Indicator
              LinearProgressIndicator(
                value: _loadingProgress, // Use the loading progress variable
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueGrey), // Customize color
                minHeight: 8, // Set the height of the progress bar
              ),
              const SizedBox(height: 20),

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text(
                  _statusText,
                  style: const TextStyle(color: Colors.grey),
                ),Text(
                  '${(_loadingProgress * 100).toInt()}%', // Display percentage
                  style: const TextStyle(color: Colors.grey,),
                ),
                ],
              )

            ],
          ),
        ),
      ),


    );
  }
}