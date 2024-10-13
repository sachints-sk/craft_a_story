import 'dart:io';
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'story_data.dart';

class ViewSavedStoryPage extends StatefulWidget {
  final StoryData storyData;

  const ViewSavedStoryPage({Key? key, required this.storyData})
      : super(key: key);

  @override
  State<ViewSavedStoryPage> createState() => _ViewSavedStoryPageState();
}

class _ViewSavedStoryPageState extends State<ViewSavedStoryPage> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isVideoInitialized = false;
  bool _showVideoPlayer = false; // To control video loading
  String _saveText = 'Save your story to access it later.';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> _initializePlayer() async {
    final localVideoPath = await _getLocalFilePath('video_${widget.storyData.storyId}.mp4');

    // Check if the video file exists locally
    if (await File(localVideoPath).exists()) {
      _videoPlayerController = VideoPlayerController.file(File(localVideoPath));
      print("Playing from local storage: $localVideoPath");
    } else {
      // If the video is not available locally, stream from Firebase Storage
      await _downloadAndSaveVideo(widget.storyData.videoUrl, localVideoPath);
      _videoPlayerController = VideoPlayerController.file(File(localVideoPath));
      print("Streaming from Firebase Storage and saved to local: $localVideoPath");
    }

    await _videoPlayerController.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      aspectRatio: 1,
      autoPlay: true,
      looping: false,
    );
    setState(() {
      _isVideoInitialized = true;
    });
  }

  Future<void> _downloadAndSaveVideo(String videoUrl, String localPath) async {
    final response = await http.get(Uri.parse(videoUrl));

    if (response.statusCode == 200) {
      // Write the file to local storage
      final file = File(localPath);
      await file.writeAsBytes(response.bodyBytes);
      print("Video downloaded and saved to local storage: $localPath");
    } else {
      throw Exception('Failed to download video');
    }
  }

  Future<String> _getLocalFilePath(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$filename';
  }

  // Function to handle play button click and load video
  void _onPlayButtonPressed() {
    setState(() {
      _showVideoPlayer = true;
      _initializePlayer(); // Load the video
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF161825),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Saved Story",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Show cover image with play button if video is not loaded
          Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: 1, // Ensures consistent height
                child: _showVideoPlayer
                    ? (_isVideoInitialized
                    ? Chewie(controller: _chewieController!)
                    : const Center(child: CircularProgressIndicator()))
                    : Image.network(
                  widget.storyData.coverImageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/testimage.png',
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
              if (!_showVideoPlayer)
                IconButton(
                  iconSize: 64,
                  icon: const Icon(Icons.play_circle_fill, color: Colors.white),
                  onPressed: _onPlayButtonPressed,
                ),
            ],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  widget.storyData.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          // Expanded widget to let the description take remaining height
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                child: Text(widget.storyData.description),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
