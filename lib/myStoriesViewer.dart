import 'dart:io';
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'story_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audio_waveforms/audio_waveforms.dart';


class Mystoriesviewer extends StatefulWidget {
  final StoryData storyData;

  const Mystoriesviewer({Key? key, required this.storyData}) : super(key: key);

  @override
  State<Mystoriesviewer> createState() => _MystoriesviewerState();
}

class _MystoriesviewerState extends State<Mystoriesviewer> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isVideoInitialized = false;
  bool _showVideoPlayer = false;
  late PlayerController _audioController;
  bool _isDownloading = false;
  String? _localAudioPath;
  double _currentVolume = 1.0;
  bool isPlaying = false;


  @override
  void initState() {
    _audioController = PlayerController();
    _audioController.playerState == PlayerState.playing ? isPlaying = true : isPlaying = false;
    super.initState();
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    _audioController.dispose();
    super.dispose();
  }




  Future<void> _downloadAndPlayAudio() async {
    setState(() {
      _isDownloading = true;
    });

    try {
      final localAudioPath =
      await _getLocalFilePath2('audio_${widget.storyData.storyId}.mp3');

      if (!await File(localAudioPath).exists()) {
        // Download audio if not already downloaded
        final response = await http.get(Uri.parse(widget.storyData.audioUrl));
        if (response.statusCode == 200) {
          final file = File(localAudioPath);
          await file.writeAsBytes(response.bodyBytes);
        } else {
          throw Exception('Failed to download audio');
        }
      }

      setState(() {
        _localAudioPath = localAudioPath;
      });

      // Load the audio into the controller
      await _audioController.preparePlayer(
        path: localAudioPath,
        shouldExtractWaveform: true,
      );

      // Start playback

    } catch (e) {
      print("Error downloading or playing audio: $e");
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  Future<String> _getLocalFilePath2(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$filename';
  }

  Future<void> _initializePlayer() async {
    final localVideoPath = await _getLocalFilePath('video_${widget.storyData.storyId}.mp4');

    if (await File(localVideoPath).exists()) {
      _videoPlayerController = VideoPlayerController.file(File(localVideoPath));
    } else {
      await _downloadAndSaveVideo(widget.storyData.videoUrl, localVideoPath);
      _videoPlayerController = VideoPlayerController.file(File(localVideoPath));
    }

    await _videoPlayerController?.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
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
          "Saved Story",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'delete') {
                // Delete the story document from Firestore
                await FirebaseFirestore.instance
                    .collection('stories')
                    .doc(widget.storyData.storyId)
                    .delete();
                Navigator.pop(context); // Close the page after deletion
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.black87),
                      SizedBox(width: 8),
                      Text(
                        'Delete Story',
                        style: TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ];
            },
            icon: const Icon(Icons.more_vert, color: Colors.white),
          ),

        ],
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video or Cover Image Section
          if (!widget.storyData.isAudio)
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
            )
          else
    _localAudioPath == null
    ? Container(
      width: double.infinity,
      height: 300, // or adjust based on your layout needs
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Image (Cover Image)
          if (widget.storyData.coverImageUrl != null)
            if (!_isDownloading)
            Positioned.fill(
              child: Image.network(
                widget.storyData.coverImageUrl!,
                fit: BoxFit.cover,
              ),
            ),
          // Play Button on top
          if (!_isDownloading)
            IconButton(
              iconSize: 64,
              icon: const Icon(Icons.play_circle_fill, color: Colors.white),
              onPressed: _downloadAndPlayAudio,
            ),
          // Circular Progress Indicator when downloading
          if (_isDownloading)
            const CircularProgressIndicator(),
        ],
      ),

    )


        : AudioFileWaveforms(
      size: Size(MediaQuery.of(context).size.width, 150.0),
      playerController: _audioController,
      enableSeekGesture: true,
      waveformType: WaveformType.long,
      animationCurve: Curves.easeInOut,
      playerWaveStyle: PlayerWaveStyle(
        fixedWaveColor: Colors.grey.shade300,
        liveWaveColor: Colors.blueAccent,
        scaleFactor: 400,
        waveThickness: 3.5,
        spacing: 10,
        waveCap: StrokeCap.round,
        liveWaveGradient: LinearGradient(
          colors: [const Color(0xFF1A2259), Colors.purple],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(Rect.fromLTWH(0, 0, 200, 50)),
      ),
    ),
          if (_localAudioPath != null)
            ...[
              const SizedBox(height: 20),
              // Control buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    iconSize: 36,
                    icon: Icon(Icons.replay_10),
                    onPressed: () async {
                      final currentPosition = await _audioController.getDuration(DurationType.current) ?? 0;
                      await _audioController.seekTo(currentPosition - 5000); // Rewind 10 seconds
                    },
                  ),
                  IconButton(
                    iconSize: 78,
                    icon: Icon(
                      isPlaying ? Icons.pause_circle : Icons.play_circle,
                      color: const Color(0xFF1A2259),
                    ),
                    onPressed: () async {
                      if (isPlaying) {
                        await _audioController.pausePlayer();
                      } else {
                        await _audioController.startPlayer(finishMode: FinishMode.stop);
                      }
                      setState(() {
                        isPlaying = !isPlaying; // Toggle play/pause state
                      });
                    },
                  ),
                  IconButton(
                    iconSize: 36,
                    icon: Icon(Icons.forward_10),
                    onPressed: () async {
                      final currentPosition = await _audioController.getDuration(DurationType.current) ?? 0;
                      await _audioController.seekTo(currentPosition + 5000); // Forward 10 seconds
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),


            ],





          // Scrollable Story Details Section
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStoryHeader(widget.storyData),
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
                storyData.mode, // Placeholder for genre
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
              'Voice: ', // Placeholder for voice type
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            Text(
              storyData.voice, // Placeholder for voice type
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        // Date Published
        const SizedBox(height: 8),
        Row(children: [Text(
          'Published on: ', // Placeholder for date
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
          Text(
            storyData.createdAt, // Placeholder for date
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),],),

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


        const SizedBox(height: 10),
      ],
    );
  }

}
