import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoSplashScreen extends StatefulWidget {
  final String videoPath;
  final VoidCallback onVideoFinished;

  VideoSplashScreen({Key? key, required this.videoPath, required this.onVideoFinished}) : super(key: key);

  @override
  _VideoSplashScreenState createState() => _VideoSplashScreenState();
}

class _VideoSplashScreenState extends State<VideoSplashScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _videoFinished = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoPath);
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    await _controller.initialize();
    _controller.play();
    _controller.setLooping(false);
    setState(() {
      _isInitialized = true;
    });

    // Listen for video end
    _controller.addListener(() {
      if (_controller.value.position >= _controller.value.duration) {
        _controller.pause(); // Hold the last frame
        if (!_videoFinished) {
          setState(() {
            _videoFinished = true;
          });
          widget.onVideoFinished(); // Trigger callback
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        )
      ),
    );
  }
}