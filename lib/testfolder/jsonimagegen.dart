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
// ... import video processing library (e.g., ffmpeg)

class JsonImageGenerator extends StatefulWidget {
  const JsonImageGenerator({Key? key}) : super(key: key);

  @override
  State<JsonImageGenerator> createState() => _JsonImageGeneratorState();
}

class _JsonImageGeneratorState extends State<JsonImageGenerator> {
  final fal = FalClient.withCredentials("bacd28f5-5a70-43d8-a518-bec50127ffc4:3bef61636d12c9b5d1ad0d032c925317");
  String _statusText = "Ready to generate!";
  List<String> _generatedImageUrls = [];
  VideoPlayerController? _videoPlayerController;

  @override
  void dispose() {
    // Dispose of the video player controller when the widget is disposed
    _videoPlayerController?.dispose();
    super.dispose();
  }
  Future<void> _generateImagesAndVideo() async {
    setState(() {
      _statusText = "Loading JSON...";
    });

    try {
      // 1. Load JSON
      final jsonString = await rootBundle.loadString('assets/your_prompts.json');
      final jsonData = jsonDecode(jsonString);

      setState(() {
        _statusText = "Generating images...";
      });

      // 2. Generate Images
      _generatedImageUrls = await _generateImagesFromPrompts(jsonData);

      setState(() {
        _statusText = "Creating video...";
      });


      await _createVideoFromImages(_generatedImageUrls);

      setState(() {
        _statusText = "Video created!";
      });
    } catch (e) {
      setState(() {
        _statusText = "Error: ${e.toString()}";
      });
      print("Error: $e");
    }
  }

  Future<List<String>> _generateImagesFromPrompts(List<dynamic> prompts) async {
    List<String> imageUrls = [];
    for (var promptData in prompts) {
      String theme = promptData['Theme'];
      String prompt = promptData['prompt'];
      String characterDescription = promptData['charector description'].toString();

      final output = await fal.subscribe("fal-ai/flux/schnell", input: {
        "prompt": "$theme: $prompt $characterDescription",
        "image_size": "square",
        "num_inference_steps": 4,
        "num_images": 1,
        "enable_safety_checker": true
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

  Future<void> _createVideoFromImages(List<String> imageUrls) async {
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
          final encodedImage = img.encodeJpg(decodedImage!);

          await imageFile.writeAsBytes(encodedImage);
          imagePaths.add(imageFile.path);
        } else {
          print('Failed to download image: ${response.statusCode}');
          // Handle error appropriately, e.g., throw an exception
          return; // Or continue with the next image
        }
      }

      // 3. Create the video using ffmpeg
      final videoPath = '${tempDir.path}/story_video.mp4';
      final arguments = [
        '-framerate', '1/5',  // 1 frame per 5 seconds (adjust as needed)
        '-i', '${tempDir.path}/image_%d.jpg', // Input image pattern
        '-c:v', 'mpeg4', // Video codec
        '-pix_fmt', 'yuv420p',  // Pixel format
        '-vf', 'pad=ceil(iw/2)*2:ceil(ih/2)*2', // Ensure dimensions are even for compatibility
        '-y', // Overwrite output file

        videoPath, // Output video path
      ];


      final int returnCode = await _flutterFFmpeg.executeWithArguments(arguments);

      if (returnCode != 0) {
        print('FFmpeg execution failed with code $returnCode.');
        // Handle error
        return;
      }

      print('Video created at: $videoPath');
      // _statusText = 'Video created successfully.';  (No need to update here)

      // 4. Initialize the video player controller
      _videoPlayerController = VideoPlayerController.file(File(videoPath));

      // 5. Initialize the controller and play the video
      await _videoPlayerController!.initialize();
      // await _videoPlayerController!.play(); // Don't auto-play

      setState(() {
        // Update UI to reflect that video is ready
        _statusText = "Video is ready! Tap to play.";  // Update status text
      });

    } catch (e) {
      print('Error creating video: $e');
      _statusText = 'Error creating video.';
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("JSON Image Generator"),
      ),
      body: Center(
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
            // 6. Display the video player
          if (_videoPlayerController != null && _videoPlayerController!.value.isInitialized)
      Column(
    children: [
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
    _videoPlayerController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
    ),
    ),
    ],
    ),
          ],
        ),
      ),
    );
  }
}