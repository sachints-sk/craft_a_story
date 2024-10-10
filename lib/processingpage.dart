import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
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

class ProcessingPage extends StatefulWidget {
  final String prompt; // Receive the prompt

  const ProcessingPage({Key? key, required this.prompt}) : super(key: key);

  @override
  State<ProcessingPage> createState() => _ProcessingPageState();
}

class _ProcessingPageState extends State<ProcessingPage> {
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
  int _scenelength = 0;
  Duration _audioDuration = Duration.zero;


  @override
  void initState() {
    super.initState();
    _processStory(); // Start processing the story as soon as the page loads
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose(); // Dispose of the video player
    super.dispose();
  }

  // Main function to handle all the processing steps
  Future<void> _processStory() async {
    try {
      await _clearOldImages();
      // 1. Generate the Story
      String story = await _generateStoryText(widget.prompt);

      // 2. Get Character Descriptions
      final characterDescriptions = await _getCharacterDescriptions(
          story) as List<String>;

      // 3. Generate Scenes (call the function here)
      List<Map<String, dynamic>> scenes = await _generateScenes(story);
      print("Generated Scenes: $scenes");


      // 4. Combine Scenes and Character Descriptions
      scenes = _appendCharacterDescriptions(scenes, characterDescriptions);

      _scenelength = scenes.length;
      setState(() {
        _statusText = "generating prompts";
      });


      setState(() {
        _statusText = "generating images)";
      });

      // 6. Generate Images
      final imageUrls = await _generateImagesFromPrompts(scenes);
      setState(() {
        _statusText = "generating audio)";
      });
      await _speakText(story);
      if (audioContent == null) { // Check if audio generation was successful
        setState(() {
          _statusText = "Error generating audio. Cannot create video.";
        });
        return;
      }
      setState(() {
        _statusText = "Creating video...";
      });


      await _createVideoFromImages(imageUrls, audioContent!);
      // 3. Generate Image Prompts (using characterDescriptions)
      // final imagePrompts = _generateImagePrompts(story, characterDescriptions);

      // 4. Generate Images (replace with your image generation API calls)
      // final imageUrls = await _generateImages(imagePrompts);

      // 5. Generate Audio (using your existing TTS code)
      // final audioContent = await _generateAudio(story);

      // 6. Create Video
      // videoPath = await _createVideo(imageUrls, audioContent);

      // 7. Initialize the video player
      //  _videoPlayerController = VideoPlayerController.file(File(videoPath!));
      //  await _videoPlayerController!.initialize();

      //  setState(() {
      //    _statusText = "Story created! Ready to play";
      //  });
    } catch (e) {
      print('Error during processing: $e');
      setState(() {
        _statusText = "Error: ${e.toString()}";
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
      double framerate = 1 / (_audioDuration.inSeconds > 0 ? _audioDuration.inSeconds : _scenelength);
      double imageDuration =1/(( _audioDuration.inSeconds / imageUrls.length)+1);
      print('Frame Rate $framerate');
      final arguments = [
        '-framerate',
        '$imageDuration',
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
      if (videoPath != null) {
        _videoPlayerController = VideoPlayerController.file(
            File(videoPath)); // videoPath is not null here
        await _videoPlayerController!.initialize();
        // ... (Rest of the video player setup)
      } else {
        print("Error: videoPath is null, cannot initialize video player.");
        // Handle the error (e.g., update _statusText to show an error message)
      }

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

  Future<void> _speakText(String text) async {
    setState(() {
      _statusText = "Generating audio...";
    });

    final url = Uri.parse(
        'https://us-central1-adept-ethos-432515-v9.cloudfunctions.net/createspeech');
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
      }
    } catch (e) {
      setState(() {
        _statusText = "Failed to generate audio.";
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

      // Make the API call to generate images using the scene description
      final output = await fal.subscribe("fal-ai/flux/schnell", input: {
        "prompt": prompt,
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

  // Function to append character descriptions to each scene
  List<Map<String, dynamic>> _appendCharacterDescriptions(
      List<Map<String, dynamic>> scenes, List<String> characterDescriptions) {
    setState(() {
      _statusText = "Combining prompt...";
    });
    // Create a copy of the scenes list to avoid modifying the original
    List<Map<String, dynamic>> modifiedScenes = List.from(scenes);

    // Loop through the scenes and add character descriptions (if available)
    // Add the full character descriptions to each scene
    for (int i = 0; i < modifiedScenes.length; i++) {
      modifiedScenes[i]['characterDescription'] =
          characterDescriptions.join('\n'); // Join descriptions with newlines
    }

    return modifiedScenes;
  }


  // Function to generate the story text using Gemini
  Future<String> _generateStoryText(String prompt) async {
    setState(() {
      _statusText = "Generating story...";
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
      }
    } catch (e) {
      print('Error generating story: $e');
      throw e; // Rethrow the exception
    }
  }

  // Function to generate scenes using your Cloud Function
  Future<List<Map<String, dynamic>>> _generateScenes(String prompt) async {
    setState(() {
      _statusText = "Generating Scenes...";
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
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error generating scenes: $e');

      throw e;
    }
  }

  // Function to get character descriptions from your Cloud Function
  Future<List<dynamic>> _getCharacterDescriptions(String story) async {
    setState(() {
      _statusText = "Getting Character Descriptions...";
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
      }
    } catch (e) {
      print('Error getting character descriptions: $e');
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Processing..."),
      ),
      body: Center(
        child: SingleChildScrollView( // This allows the content to scroll if it overflows
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text(_statusText),
              if (_videoPlayerController != null &&
                  _videoPlayerController!.value.isInitialized) ...[
                SizedBox(height: 20),
                AspectRatio(
                  aspectRatio: _videoPlayerController!.value.aspectRatio,
                  child: VideoPlayer(_videoPlayerController!),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _videoPlayerController!.value.isPlaying
                          ? _videoPlayerController!.pause()
                          : _videoPlayerController!.play();
                    });
                  },
                  child: Icon(
                    _videoPlayerController!.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                  ),
                ),
                ElevatedButton(
                  onPressed: _saveVideoToGallery,
                  child: const Text("Download Video"),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}