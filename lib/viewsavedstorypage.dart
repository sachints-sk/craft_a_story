import 'dart:io';
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'story_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:share_plus/share_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Services/Review_services.dart';
import 'Services/StoryExplorer_banner_ad_widget.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';





class ViewSavedStoryPage extends StatefulWidget {
  final StoryData storyData;

  const ViewSavedStoryPage({Key? key, required this.storyData}) : super(key: key);

  @override
  State<ViewSavedStoryPage> createState() => _ViewSavedStoryPageState();
}

class _ViewSavedStoryPageState extends State<ViewSavedStoryPage> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isVideoInitialized = false;
  bool _showVideoPlayer = false;
  late PlayerController _audioController;
  bool isToggled= true;
  bool _isDownloading = false;
  bool _isDownloading2 = false;
  bool _subscribed = false;
  late final void Function(CustomerInfo) _customerInfoListener;
  String _localAudioPath="";
  double _currentVolume = 1.0;
  bool isPlaying = false;
  String username ="";
  int likeCount = 0;
  bool isLiked = false;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();

    _fetchLikeStatus();
    _audioController = PlayerController();
    _audioController.playerState == PlayerState.playing ? isPlaying = true : isPlaying = false;
    getusername();
    // Log the event that the story was viewed
    FirebaseAnalytics.instance.logEvent(
      name: 'story_viewed',
      parameters: {
        'story_id': widget.storyData.storyId,
        'story_title': widget.storyData.title,
        'user_id':username,
        'user_email':user!.email.toString(),
      },
    );
    _setupIsPro();

    _onStoryViewed();
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _audioController.dispose();
    _chewieController?.dispose();
    Purchases.removeCustomerInfoUpdateListener(_customerInfoListener);
    super.dispose();
  }
  Future<void> getusername() async{
    final user = FirebaseAuth.instance.currentUser;
    username= user!.uid;

  }
  Future<void> _setupIsPro() async {
    _customerInfoListener = (CustomerInfo customerInfo) {
      EntitlementInfo? entitlement = customerInfo.entitlements.all['Premium'];
      if (mounted) {
        setState(() {
          _subscribed = entitlement?.isActive ?? false;
        });
      }
    };
    Purchases.addCustomerInfoUpdateListener(_customerInfoListener!);
  }

  Future<void> _downloadAndPlayAudio() async {
    setState(() {
      _isDownloading = true;
    });
    _onStoryViewed();
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


  Future<void> _fetchLikeStatus() async {
    final storyDoc = FirebaseFirestore.instance.collection('Explore_stories').doc(widget.storyData.storyId);
    final docSnapshot = await storyDoc.get();

    if (docSnapshot.exists) {
      setState(() {
        likeCount = (docSnapshot.data()?['likeCount'] ?? 0) as int;
        List likedBy = (docSnapshot.data()?['likedBy'] ?? []);
         isLiked = likedBy.contains(FirebaseAuth.instance.currentUser!.uid);
      });
    }
  }

  Future<void> _toggleLike() async {
    final storyDoc = FirebaseFirestore.instance.collection('Explore_stories').doc(widget.storyData.storyId);
    final userId = FirebaseAuth.instance.currentUser!.uid;

    if (isLiked) {
      // Unlike the story
      await storyDoc.update({
        'likeCount': FieldValue.increment(-1),
        'likedBy': FieldValue.arrayRemove([userId]),
      });
      setState(() {
        likeCount--;
        isLiked = false;
      });
    } else {
      // Like the story
      await storyDoc.update({
        'likeCount': FieldValue.increment(1),
        'likedBy': FieldValue.arrayUnion([userId]),
      });
      setState(() {
        likeCount++;
        isLiked = true;
      });
    }
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
    if(mounted)
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

  Future<void> _shareStory() async {
    try {
      // Get the local video file path
      final localVideoPath = await _getLocalFilePath('video_${widget.storyData.storyId}.mp4');
      final videoFile = File(localVideoPath);

      if (await videoFile.exists()) {
        // Share the video file if it exists
        await Share.shareXFiles(
          [XFile(localVideoPath)],
          text: 'Check out this story: ${widget.storyData.title}. More amazing stories await on Craft-a-Story.',
        );
      } else {
        setState(() {
          _isDownloading2 = true;
        });
        // If the video doesn't exist, download it first
        await _downloadAndSaveVideo(widget.storyData.videoUrl, localVideoPath);

        setState(() {
          _isDownloading2 = false;
        });
        // After downloading, share the video
        await Share.shareXFiles(
          [XFile(localVideoPath)],
          text: 'Check out this story: ${widget.storyData.title}. More amazing stories await on Craft-a-Story.',
        );
      }
    } catch (e) {
      print('Error while sharing story: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to share the story.')),
      );
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
  void  isToggledFunction()async{
    if(_audioController!=null)
    _audioController.pausePlayer();

  }
  void  isnotToggledFunction() async{
    if(_videoPlayerController!=null)
    _videoPlayerController!.pause();
    // Load the audio into the controller

    await _audioController.preparePlayer(
      path: _localAudioPath,
      shouldExtractWaveform: true,
    );


  }

  void _onStoryViewed() async {
    print("onStoryViewed");
    // This should be called when the user creates their first story
    await AppPreferences.setFirstStoryCreated(true);


  }


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main UI
        Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF161825),
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: const Text(
              "Story Explorer",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            actions: [

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: AnimatedToggleSwitch<bool>.dual(
                  current: isToggled,
                  first: false,
                  second: true,
                  style: const ToggleStyle(
                    backgroundColor: Colors.white10,
                    indicatorColor: Colors.white70,

                    borderColor: Colors.white,
                  ),
                  height: 38.0,
                  spacing: 12.0,
                  onChanged: (value) {
                    setState(() {
                      isToggled = value;
                    });
                    if(value){
                      isToggledFunction();
                    }else{
                      isnotToggledFunction();
                    }
                  },
                  iconBuilder: (value) => value
                      ? const Icon(Icons.movie, color: const Color(0xFF161825))
                      : const Icon(Icons.volume_up, color: const Color(0xFF161825),),
                  textBuilder: (value) => value
                      ? const Text('Video', style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold))
                      : const Text('Audio', style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),


          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if(!_subscribed)
              BannerAdWidget(),
              // Video Player or Cover Image Section
              if(isToggled)
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

              if(!isToggled)
                _localAudioPath == ""
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
              if(!isToggled)
                if (_localAudioPath != "")
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
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white // Dark mode text color
                                : const Color(0xFF1A2259),

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
                  decoration: const BoxDecoration(


                  ),
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
        ),

        // Fullscreen loading overlay
        if (_isDownloading2)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
      ],
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

                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Like Button with Count
            Row(
            children: [
            IconButton(
            onPressed: _toggleLike,
            icon: Icon(
            isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
            color: isLiked ? Colors.blue : Theme.of(context).brightness == Brightness.dark
                ? Colors.white // Dark mode text color
                : Colors.black87,

            size: 28,
            ),
            ),
            Text(
            '$likeCount',
            style: const TextStyle(
            color: Colors.grey,
            fontSize: 16,
            ),
            ),
              IconButton(
                icon: Icon(Icons.share, color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white // Dark mode text color
                    : Colors.black87,  ),
                onPressed: _shareStory,
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

        const SizedBox(height: 10),
      ],
    );
  }

}
