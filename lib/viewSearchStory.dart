import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'story_data.dart';

class ViewStoryByIdPage extends StatefulWidget {
  final String storyId;

  const ViewStoryByIdPage({Key? key, required this.storyId}) : super(key: key);

  @override
  State<ViewStoryByIdPage> createState() => _ViewStoryByIdPageState();
}

class _ViewStoryByIdPageState extends State<ViewStoryByIdPage> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isVideoInitialized = false;
  bool _showVideoPlayer = false;
  StoryData? _storyData;
  bool _isLoading = true;
  String _saveText = 'Save your story to access it later.';

  @override
  void initState() {
    super.initState();
    _fetchStoryData();
  }

  Future<void> _fetchStoryData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('Explore_stories')
          .doc(widget.storyId)
          .get();

      if (doc.exists) {
        setState(() {
          _storyData = StoryData.fromFirestore(doc.data()!);
          _isLoading = false;
        });
      } else {
        throw Exception("Story not found");
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      // Handle or display error
      print("Failed to fetch story: $error");
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> _initializePlayer() async {
    final localVideoPath = await _getLocalFilePath('video_${widget.storyId}.mp4');

    if (_storyData != null) {
      if (await File(localVideoPath).exists()) {
        _videoPlayerController = VideoPlayerController.file(File(localVideoPath));
      } else {
        await _downloadAndSaveVideo(_storyData!.videoUrl, localVideoPath);
        _videoPlayerController = VideoPlayerController.file(File(localVideoPath));
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
  }

  Future<void> _downloadAndSaveVideo(String videoUrl, String localPath) async {
    final response = await http.get(Uri.parse(videoUrl));

    if (response.statusCode == 200) {
      final file = File(localPath);
      await file.writeAsBytes(response.bodyBytes);
    } else {
      throw Exception('Failed to download video');
    }
  }

  Future<String> _getLocalFilePath(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$filename';
  }

  void _onPlayButtonPressed() {
    setState(() {
      _showVideoPlayer = true;
      _initializePlayer();
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
          "View Story",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _storyData == null
          ? const Center(child: Text("Story not found"))
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video Player or Cover Image Section
          Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: _showVideoPlayer
                    ? (_isVideoInitialized
                    ? Chewie(controller: _chewieController!)
                    : const Center(child: CircularProgressIndicator()))
                    : Image.network(
                  _storyData!.coverImageUrl,
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
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStoryHeader(_storyData!),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }




Widget _buildStoryHeader(StoryData storyData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and Like button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Story Title
            Expanded(
              child: Text(
                storyData.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Like Button with Count
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    // Handle like action
                  },
                  icon: const Icon(
                    Icons.thumb_up_alt_outlined,
                    color: Colors.grey,
                    size: 28,
                  ),
                ),
                Text(
                  '5', // Placeholder for like count
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Story Type as a Badge
        Container(


          child: Row(
            children: [
              const Icon(Icons.category, color: Colors.grey, size: 20),
              const SizedBox(width: 8),
              Text(
                'Genre: ', // Placeholder for genre
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              Text(
                'Fantasy', // Placeholder for genre
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Story Voice and Publish Date
        Row(
          children: [
            const Icon(Icons.record_voice_over, color: Colors.grey, size: 20),
            const SizedBox(width: 8),
            Text(
              'Voice: Gentle Male Gentle Male', // Placeholder for voice type
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        // Date Published
        const SizedBox(height: 8),
        Text(
          'Published on: 20 Oct 2023', // Placeholder for date
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        const Divider(
          color: Colors.grey,
          thickness: 0.5,
        ),

        const SizedBox(height: 8),
        Text(
          storyData.description,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 20),

        // Divider
        const Divider(
          color: Colors.grey,
          thickness: 0.5,
        ),
        const SizedBox(height: 10),

        // Additional Info
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Length of Story
            Row(
              children: [
                const Icon(Icons.timer, color: Colors.grey, size: 20),
                const SizedBox(width: 8),
                Text(
                  '10 min read', // Placeholder for story length
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            // Other info, like genre or reading age
            Row(
              children: [
                const Icon(Icons.category, color: Colors.grey, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Genre: Fantasy', // Placeholder for genre
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

}
