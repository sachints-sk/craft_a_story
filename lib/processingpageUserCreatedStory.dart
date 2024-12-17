import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart' ;
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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'buycredits.dart';



class ProcessingPageUserCreatedStory extends StatefulWidget {
  final String story; // Receive the prompt
  final String title;
  final String language;
  final String voice;
  final String mode;

  const ProcessingPageUserCreatedStory({Key? key, required this.story,required this.title,required this.language,required this.voice, required this.mode}) : super(key: key);

  @override
  State<ProcessingPageUserCreatedStory> createState() => _ProcessingPageUserCreatedStoryState();
}

class _ProcessingPageUserCreatedStoryState extends State<ProcessingPageUserCreatedStory> {
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
  String videoPathCombined = "";
  String coverImageUrl="";
  int _scenelength = 0;
  Duration _audioDuration = Duration.zero;
  double _loadingProgress = 0.0; // Track loading progress (0.0 to 1.0)
  Timer? _timer;
  String translatedStory ="";
  String videoPathConverted="";


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
    _videoPlayerController?.dispose(); // Dispose of the video player
    super.dispose();
  }





  Future<void> requestStoragePermissions() async {
    // Request permission for devices running Android 10 or below
    if (await Permission.storage.isGranted) {
      print("Storage permission granted.");
    } else {
      // Check and request permission
      PermissionStatus status = await Permission.storage.request();
      if (status.isGranted) {
        print("Storage permission granted.");
      }
    }
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
    Trace customTrace = FirebasePerformance.instance.newTrace('Create-Visual-Story');
    await customTrace.start();
    try {
      // 1. Clear old images
      await requestStoragePermissions();
      await _clearOldImages();
      await _clearOldAudio();

      bool eligible= await canCreateStory(user!.uid,  10);
      print("Eligible : $eligible");


      if(eligible){



        _timer = await Timer.periodic(const Duration(milliseconds: 10), (timer) {
          setState(() {
            _loadingProgress += 0.01; // Increase progress by 1% every 50ms
            if (_loadingProgress >= 0.02) {
              _timer?.cancel(); // Stop the timer when progress reaches 100%
              // You can navigate to the next screen or perform other actions here
            }
          });
        });

        // 2. Generate the Story
        String story = widget.story;

        // 3. Get Character Descriptions
        final characterDescriptions = await _getCharacterDescriptions(story) as List<String>;

        _timer =await  Timer.periodic(const Duration(milliseconds: 10), (timer) {
          setState(() {
            _loadingProgress += 0.01; // Increase progress by 1% every 50ms
            if (_loadingProgress >= 0.2) {
              _timer?.cancel(); // Stop the timer when progress reaches 100%
              // You can navigate to the next screen or perform other actions here
            }
          });
        });

        // 4. Generate Scenes (call the function here)
        List<Map<String, dynamic>> scenes = await _generateScenes(story);
        print("Generated Scenes: $scenes");


        // 5. Combine Scenes and Character Descriptions
        List<Map<String, dynamic>> Conscenes = await _appendCharacterDescriptions(scenes, characterDescriptions);
        _timer =await Timer.periodic(const Duration(milliseconds: 10), (timer) {
          setState(() {
            _loadingProgress += 0.01; // Increase progress by 1% every 50ms
            if (_loadingProgress >= 0.35) {
              _timer?.cancel(); // Stop the timer when progress reaches 100%
              // You can navigate to the next screen or perform other actions here
            }
          });
        });
        _scenelength = scenes.length;
        print("concatinated scenes");
        print(Conscenes);

        // 5. Generate Cover Image
        coverImageUrl = await _generateCoverImage(Conscenes) ?? '';// Make coverImageUrl nullable
        print("Cover image URL: $coverImageUrl");



        setState(() {
          _statusText = "Designing visuals...";
        });

        // 6. Generate Images
        final imageUrls = await _generateImagesFromPrompts(Conscenes);


        setState(() {
          _statusText = "Crafting the soundtrack...";
        });

        await _speakTextTranslated(story);

        _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
          setState(() {
            _loadingProgress += 0.01; // Increase progress by 1% every 50ms
            if (_loadingProgress >= 0.7) {
              _timer?.cancel(); // Stop the timer when progress reaches 100%
              // You can navigate to the next screen or perform other actions here
            }
          });
        });
        setState(() {
          _statusText = "Bringing your video to life ...";
        });

        await _createVideoFromImagesTranslated(imageUrls);

        await _DeductCredits();

        _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
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
              child: NewVideoPlayer(
                videoPath: videoPathCombined!,
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
              child: NewVideoPlayer(
                videoPath: videoPathCombined!,
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


      } else {
        _showInsufficientCreditsDialog(context);

      }





    } catch (e) {
      print('Error during processing: $e');

      _showStoryCreationErrorDialog(context);
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
          'creditsToDeduct': 10,
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
          _showStoryCreationErrorDialog(context);
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

  Future<String?> _generateCoverImage(List<Map<String, dynamic>> scenes) async {
    if (scenes.isEmpty) {
      print("No scenes available to generate a cover image.");
      return null;
    }

    String prompt = scenes[0]['scene']; // Use the first scene as the prompt

    // Make the API call to generate the cover image
    final output = await fal.subscribe("fal-ai/flux/schnell", input: {
      "prompt": prompt,
      "image_size": "landscape_16_9", // Set landscape aspect ratio
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




  Future<void> _createVideoFromImagesTranslated(List<String> imageUrls) async {
    try {
      final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();

      // 1. Create a temporary directory to store downloaded images
      final tempDir = await getTemporaryDirectory();
      List<String> imagePaths = [];

      // 2. Download images and save them to the temporary directory
      for (int i = 0; i < imageUrls.length; i++) {
        final response = await http.get(Uri.parse(imageUrls[i]));
        if (response.statusCode == 200) {
          final imageFile = File('${tempDir.path}/image_$i.jpg');

          // Decode and encode as JPEG using the image package
          final decodedImage = img.decodeImage(response.bodyBytes);
          if (decodedImage != null) {
            print('Image $i dimensions: ${decodedImage.width}x${decodedImage
                .height}');
            print(imageFile.path);// Log dimensions
            final encodedImage = img.encodeJpg(decodedImage);
            await imageFile.writeAsBytes(encodedImage);
            imagePaths.add(imageFile.path);
            setState(() {
              _loadingProgress += (0.25/_scenelength); // Increase progress by 1% every 50ms

            });
          }
        } else {
          print('Failed to download image: ${response.statusCode}');
          _showStoryCreationErrorDialog(context);
          return;
        }
      }

      // 4. Create the video using ffmpeg
      videoPath = '${tempDir.path}/story_video.mp4';
      videoPathConverted = '${tempDir.path}/story_video_converted.mp4';

      double framerate = 1 / (_audioDuration.inSeconds > 0 ? _audioDuration.inSeconds : _scenelength);
      double imageDuration =1/(( _audioDuration.inSeconds / imageUrls.length)+1);
      print('Frame Rate $framerate');
      final arguments = [
        '-framerate',
        '$imageDuration',  // Frame rate per image
        '-i',
        '${tempDir.path}/image_%d.jpg',  // Input image pattern
        '-i',
        _storedAudioPath,  // Input audio file

        '-map',
        '0:v',  // Map video from images
        '-map',
        '1:a',  // Map audio
        '-c:v',
        'libx264',  // Video codec
        '-pix_fmt',
        'yuv420p',  // Pixel format
// Video filter for scaling and padding to 512x512
        '-vf',
        'scale=512:512:force_original_aspect_ratio=decrease,pad=512:512:(ow-iw)/2:(oh-ih)/2',


        '-y',  // Overwrite output file
        videoPath,  // Output video path
      ];



      final int returnCode = await _flutterFFmpeg.executeWithArguments(
          arguments);

      if (returnCode != 0) {
        print('FFmpeg execution failed with code $returnCode.');
        // Handle error
        return;
      }

      print('Video created at: $videoPath');

      await mergeNonCompatibleVideos(videoPath);

      // _statusText = 'Video created successfully.';  (No need to update here)

    } catch (e) {
      print('Error creating video: $e');
      setState(() {
        _statusText = 'Error creating video.';
      });
    }
  }
  Future<File> loadVideoFromAssets(String fileName) async {
    final byteData = await rootBundle.load('assets/$fileName');
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');

    // Write bytes to a new file in the temp directory
    await file.writeAsBytes(byteData.buffer.asUint8List());
    return file;
  }

  Future<void> mergeNonCompatibleVideos( String video2Path) async {
    final FlutterFFmpeg ffmpeg = FlutterFFmpeg();
    final tempDir = await getTemporaryDirectory();
    videoPathCombined = '${tempDir.path}/story_video_combined.mp4';

    final video1Path = await loadVideoFromAssets('video1.mp4');

    //   // FFmpeg command for re-encoding and merging
    //   final command = '''
    //   -i ${video1Path.path}
    //   -i $video2Path
    //   -filter_complex "[0:v:0][0:a:0][1:v:0][1:a:0]concat=n=2:v=1:a=1[outv][outa]"
    //   -map "[outv]"
    //   -map "[outa]"
    //   -c:v libx264
    //   -c:a aac
    //   -y $videoPathCombined
    // ''';
    String commandToExecute = '-y -i ${video1Path.path} -i $video2Path -filter_complex \'[0:v:0]fps=30,setsar=1[vid1]; [1:v:0]fps=30,setsar=1[vid2]; [0:a:0][1:a:0]concat=n=2:v=0:a=1[outa]; [vid1][vid2]concat=n=2:v=1:a=0[outv]\' -map \'[outv]\' -map \'[outa]\' $videoPathCombined';


    final result = await ffmpeg.execute(commandToExecute);

    if (result == 0) {
      print("Videos merged successfully into $videoPathCombined");
    } else {
      print("Error merging videos: $result");
      _showStoryCreationErrorDialog(context);
    }
  }



  Future<void> _speakText(String text) async {
    setState(() {
      _statusText = "Crafting the soundtrack ...";
    });
    print("normal method");
    print(widget.voice);
    final url = Uri.parse(
        'https://us-central1-adept-ethos-432515-v9.cloudfunctions.net/createspeech');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({ "text": text,
          "languageCode": widget.language,
          "voiceName": widget.voice
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        audioContent = data['audioContent'];

        await _audioPlayer.setAudioSource(
            AudioSource.uri(Uri.dataFromBytes(base64Decode(audioContent!), mimeType: 'audio/mpeg')));
        _audioDuration = _audioPlayer.duration ?? Duration.zero; // Get the duration or default to zero
        print("Audio duration: $_audioDuration");

      } else {
        setState(() {
          _statusText = "Error: ${response.statusCode}";
        });
        print('Error: ${response.body}');
        _showStoryCreationErrorDialog(context);
      }
    } catch (e) {
      setState(() {
        _statusText = "Failed to generate audio.";
        _showStoryCreationErrorDialog(context);
        print('Error: $e');
      });
    } finally {

    }
  }

  Future<List<String>> _generateImagesFromPrompts(
      List<Map<String, dynamic>> scenes) async {
    List<String> imageUrls = [];
    for (var scene in scenes) {
      // Extract the scene description
      String prompt = scene['scene'];
      print(prompt);
      // Make the API call to generate images using the scene description
      final output = await fal.subscribe("fal-ai/flux/schnell", input: {
        "prompt": prompt,
        "image_size": "square",
        "num_inference_steps": 4,
        "num_images": 1,
        "enable_safety_checker": false
      }, logs: true, webhookUrl: "https://optional.webhook.url/for/results",
          onQueueUpdate: (update) {
            print(update);

          });

      final images = output.data?["images"];
      if (images != null && images.isNotEmpty && images is List) {
        imageUrls.add(images[0]["url"]);
        setState(() {
          _loadingProgress += (0.25/_scenelength); // Increase progress by 1% every 50ms

        });
      }
    }
    return imageUrls;
  }

  // Function to generate image prompts
  List<String> _generateImagePrompts(List<Map<String, dynamic>> scenes) {
    List<String> imagePrompts = [];
    for (var scene in scenes) {
      // Use only the 'scene' which already includes character description
      String prompt = scene['scene'];
      imagePrompts.add(prompt);
    }
    return imagePrompts;
  }

  List<Map<String, dynamic>> _appendCharacterDescriptions(
      List<Map<String, dynamic>> scenes, List<String> characterDescriptions) {
    setState(() {
      _statusText = "Perfecting tale..";
    });
    // Create a copy of the scenes list to avoid modifying the original
    List<Map<String, dynamic>> modifiedScenes = List.from(scenes);

    // Join all character descriptions into a single string with a space separator
    String combinedCharacterDescriptions = characterDescriptions.join(' ');

    // Loop through each scene and append the character descriptions to the "scene" key
    for (int i = 0; i < modifiedScenes.length; i++) {
      modifiedScenes[i]['scene'] =
      '${modifiedScenes[i]['scene']} $combinedCharacterDescriptions';
    }

    return modifiedScenes;
  }

// Function to generate the story text using Gemini
  Future<String> _generateDub(String prompt) async {
    setState(() {
      _statusText = "converting story";
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

  // Function to generate scenes using your Cloud Function
  Future<List<Map<String, dynamic>>> _generateScenes(String prompt) async {
    setState(() {
      _statusText = "Setting the stage ...";
    });
    try {
      final response = await http.post(
        Uri.parse(
            'https://us-central1-adept-ethos-432515-v9.cloudfunctions.net/breakstorydown'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'story': prompt}),
      );
      print(response.body.toString());
      if (response.statusCode == 200) {
        String cleanedResponse = response.body
            .replaceAll("```json\n", "") // Remove leading backticks and "json"
            .replaceAll("```", ""); // Remove trailing backticks

        print(cleanedResponse.toString());
        final List<dynamic> responseData = jsonDecode(cleanedResponse);

        // Convert the dynamic list to a list of maps
        List<Map<String, dynamic>> scenes = responseData.map((item) {
          return {
            'scene': item['scene'],
          };
        }).toList();

        return scenes;
        print(scenes);
      } else {
        throw Exception('Failed to generate scenes: ${response.statusCode}');
        print('Response status code: ${response.statusCode}');
        _showStoryCreationErrorDialog(context);
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error generating scenes: $e');
      _showStoryCreationErrorDialog(context);

      throw e;
    }
  }

  // Function to get character descriptions from your Cloud Function
  Future<List<dynamic>> _getCharacterDescriptions(String story) async {
    setState(() {
      _statusText = "Shaping the heroes ...";
    });

    try {
      final response = await http.post(
        Uri.parse(
            'https://us-central1-adept-ethos-432515-v9.cloudfunctions.net/charectordescription'),
        // Your Cloud Function URL
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
            {'story': story}), // Send the story in the request body
      );

      if (response.statusCode == 200) {
        // Split the plain text response into a list of lines (character descriptions)
        List<String> descriptions = response.body.split('\n');
        // Remove any empty lines
        descriptions = descriptions.where((line) =>
        line
            .trim()
            .isNotEmpty).toList();
        print(descriptions);
        return descriptions;
      } else {
        throw Exception(
            'Failed to get character descriptions: ${response.statusCode}');
        _showStoryCreationErrorDialog(context);
      }
    } catch (e) {
      print('Error getting character descriptions: $e');
      _showStoryCreationErrorDialog(context);
      throw e; // Rethrow the exception to be handled in the main try...catch
    }
  }


  Future<void> _saveVideoToGallery() async {
    try {
      // Save the video to the gallery
      final result = await ImageGallerySaver.saveFile(videoPath!,
          isReturnPathOfIOS: true);

      // Check the result
      if (result['isSuccess']) {
        setState(() {
          _statusText = "Video saved to gallery!";
        });
      } else {
        setState(() {
          _statusText = "Failed to save video: ${result['errorMessage']}";
        });
      }
    } catch (e) {
      print('Error saving video: $e');
      setState(() {
        _statusText = "Error saving video: $e";
      });
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
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Blue circle with icons (replace with your actual icons)
              Container(
                width: 170,
                height: 170,

                child: Center( // Center the icon
                  child:  Lottie.asset(
                    'assets/writing.json',  // AI animation
                    width: 170,
                    height: 170,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Generating Your Story',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
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