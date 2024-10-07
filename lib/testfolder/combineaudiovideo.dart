import 'dart:io';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fal_client/fal_client.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:image/image.dart' as img;
import 'package:googleapis_auth/auth_io.dart'; // For service account authentication
import 'package:just_audio/just_audio.dart'; // For playing audio
import 'package:flutter/services.dart' show rootBundle; // For loading the JSON key
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:chewie/chewie.dart';

class CombineAudioVideo extends StatefulWidget {
  const CombineAudioVideo({super.key});

  @override
  State<CombineAudioVideo> createState() => _CombineAudioVideoState();
}

class _CombineAudioVideoState extends State<CombineAudioVideo> {
  final fal = FalClient.withCredentials(
      "6aa78a3f-c213-4e62-885d-6cc0a6a17d2e:ea116f46d65044e7b5e4c6dad6a921d7");
  String _statusText = "Ready to generate!";
  List<String> _generatedImageUrls = [];
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController; // Add ChewieController
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _audioContent;
  String _statusText2 = "audio not generated!";
  String? _accessToken;
  String videoPath = "";

  @override
  void initState() {
    super.initState();
    _authenticateWithServiceAccount(); // Authenticate when the app starts
  }


  @override
  void dispose() {
    // Dispose of the video player controller when the widget is disposed
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  // Method to authenticate using service account key
  Future<void> _authenticateWithServiceAccount() async {
    setState(() {
      _statusText2 = "Authenticating...";
    });

    // Load the service account key from the JSON file
    final String jsonKey = await rootBundle.loadString(
        'assets/adept-ethos-432515-v9-1fa3e34d0b3e.json'); // Ensure the key is stored in assets

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
      _statusText2 = "Authenticated!";
    });

    print("Access Token: $_accessToken");
  }

  Future<void> _speakText(String text) async {
    if (_accessToken == null) {
      setState(() {
        _statusText2 = "Please wait for authentication!";
      });
      return;
    }

    setState(() {
      _statusText2 = "Generating audio...";
    });

    // Construct the API request URL
    final url = Uri.parse(
        'https://texttospeech.googleapis.com/v1/text:synthesize');

    // Construct the request body
    final Map<String, dynamic> body = {
      'input': {
        'text': "Nigel, a sprightly ten-year-old with a mop of unruly brown hair, stood hesitantly at the edge of the pool, the cool water swirling around his ankles. He'd always admired the way his older sister, Amelia, glided effortlessly through the water, her strokes smooth and graceful. Now, it was his turn to learn, a mix of excitement and apprehension bubbling in his stomach. His dad, a burly man with a booming laugh, stood by the side, encouraging him with a warm smile. ""Come on, champ, you can do this!"" He had the perfect floaties – bright blue and shaped like dolphins – securely strapped around his arms, a testament to his father's belief in him. Nigel took a deep breath, then, with a determined hop, he plunged into the refreshing water. For a moment, he just floated, feeling the buoyant weightlessness of the water, a sensation that was both foreign and exciting. His dad, his voice muffled by the distance, guided him: ""Now, just kick your legs, Nigel, like a mermaid!"" Nigel giggled and wiggled his legs, the water churning around him. The first day, he mainly just practiced kicking and floating, with his dad's comforting voice a constant reassurance. He even managed a few clumsy attempts at dog paddling, ending up with a mouthful of water every time. The days turned into weeks, each session at the pool filled with laughter, frustration, and a growing sense of achievement. Nigel's legs became stronger, his kicks more powerful. His dad taught him how to hold his breath and glide under the water, a magical underwater world of shimmering sunlight and playful shadows unfolding before his eyes. He still found it challenging to put all the techniques together, often struggling to keep his balance or remembering which arm to move next. One day, Nigel felt discouraged, the water seeming to resist his efforts. His dad noticed his frustration and encouraged him to try again, this time with a little more focus. Nigel took a deep breath, picturing Amelia gliding through the water, and started again. This time, it was different. He moved with a newfound sense of fluidity, his arms and legs working in unison, the cool water flowing around him like a friendly embrace. A wave of pride washed over him as he realized he was finally swimming, not just bobbing. From that day on, Nigel became a regular at the pool, his love for swimming growing with every stroke. He discovered the joy of swimming laps, of racing his sister, and of diving into the cool water on a hot summer day. Nigel, the boy who once feared the water, had become a confident swimmer, his initial fear transformed into a deep love for the water and all its wonders. He knew that no matter how long he swam, the memory of that first triumphant moment, when he felt his body finally move through the water as one, would stay with him always, a reminder of his courage and perseverance."
      },
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
          _statusText2 = "Audio ready!";
        });
      } else {
        setState(() {
          _statusText2 = "Error 6: ${response.statusCode}";
        });
        print('Error 5: ${response.statusCode}');
        print('Error message: ${response.body}');
      }
    } catch (e) {
      setState(() {
        _statusText2 = "Error 4: $e";
      });
      print('Error 3: $e');
    }
  }


  Future<void> _generateImagesAndVideo() async {
    setState(() {
      _statusText = "Loading JSON...";
    });

    try {
      // Clear old images before generating new ones
      await _clearOldImages();
      // 1. Load JSON
      final jsonString = await rootBundle.loadString(
          'assets/your_prompts.json');
      final jsonData = jsonDecode(jsonString);

      setState(() {
        _statusText = "Generating images...";
      });

      // 2. Generate Images
      _generatedImageUrls = await _generateImagesFromPrompts(jsonData);

      await _speakText("hi");
      if (_audioContent == null) { // Check if audio generation was successful
        setState(() {
          _statusText = "Error generating audio. Cannot create video.";
        });
        return;
      }

      setState(() {
        _statusText = "Creating video...";
      });


      await _createVideoFromImages(_generatedImageUrls, _audioContent!);

      setState(() {
        _statusText = "Video created!";
      });
    } catch (e) {
      setState(() {
        _statusText = "Error 1: ${e.toString()}";
      });
      print("Error 2: $e");
    }
  }

  Future<List<String>> _generateImagesFromPrompts(List<dynamic> prompts) async {
    List<String> imageUrls = [];
    for (var promptData in prompts) {
      // Extract the prompt from the JSON data
      String prompt = promptData['prompt'];

      // Make the API call to generate images using the extracted prompt
      final output = await fal.subscribe("fal-ai/flux/schnell", input: {
        "prompt": prompt, // Use the prompt directly from the JSON
        "image_size": "portrait_16_9",
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
      }
    }
    return imageUrls;
  }

  Future<void> _saveVideoToGallery(String videoPath) async {
    try {
      // Save the video to the gallery
      final result = await ImageGallerySaver.saveFile(
          videoPath, isReturnPathOfIOS: true);

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

  Future<void> _createVideoFromImages(List<String> imageUrls,
      String audioData) async {
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
                .height}'); // Log dimensions
            final encodedImage = img.encodeJpg(decodedImage);
            await imageFile.writeAsBytes(encodedImage);
            imagePaths.add(imageFile.path);
          }
        } else {
          print('Failed to download image: ${response.statusCode}');
          return;
        }
      }
      // 3. Save the audio data to a temporary file
      final audioFile = File('${tempDir.path}/audio.mp3');
      await audioFile.writeAsBytes(base64Decode(audioData));
      // 4. Create the video using ffmpeg
      videoPath = '${tempDir.path}/story_video.mp4';
      final arguments = [
        '-framerate',
        '1/15',
        // 1 frame per 5 seconds (adjust as needed)
        '-i',
        '${tempDir.path}/image_%d.jpg',
        // Input image pattern
        '-i',
        audioFile.path,
        // Use the saved audio file

        '-map',
        '0:v',
        // Map video from images
        '-map',
        '1:a',
        '-c:v',
        'mpeg4',
        // Video codec
        '-pix_fmt',
        'yuv420p',
        // Pixel format
        '-vf',
        'scale=576:1024:force_original_aspect_ratio=decrease,pad=576:1024:(ow-iw)/2:(oh-ih)/2',
        // Ensure dimensions are even for compatibility
        '-y',
        // Overwrite output file

        videoPath,
        // Output video path
      ];

      final int returnCode = await _flutterFFmpeg.executeWithArguments(
          arguments);

      if (returnCode != 0) {
        print('FFmpeg execution failed with code $returnCode.');
        // Handle error
        return;
      }

      print('Video created at: $videoPath');
      // _statusText = 'Video created successfully.';  (No need to update here)

      // Initialize the video player controller
      _videoPlayerController = VideoPlayerController.file(File(videoPath));

      // Initialize ChewieController
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        aspectRatio: 9 / 16,
        autoPlay: true,
        looping: false,
      );

      await _videoPlayerController!.initialize();

      setState(() {
        _statusText = "Video is ready! Tap to play.";
      });
    } catch (e) {
      print('Error creating video: $e');
      setState(() {
        _statusText = 'Error creating video.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("JSON Image Generator"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _generateImagesAndVideo,
                child: const Text("Generate Images & Video"),
              ),
              const SizedBox(height: 20),
              Text(_statusText),
              const SizedBox(height: 20),
              Text(_statusText2),
              const SizedBox(height: 20),

              // Video section
              if (_chewieController != null && _chewieController!.videoPlayerController.value.isInitialized)
                Column(
                  children: [
                    // Chewie player widget with 9:16 aspect ratio
                    AspectRatio(
                      aspectRatio: 9 / 16, // Maintain aspect ratio
                      child: Chewie(controller: _chewieController!),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        _saveVideoToGallery(videoPath);
                      },
                      child: const Text("Download Video"),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}