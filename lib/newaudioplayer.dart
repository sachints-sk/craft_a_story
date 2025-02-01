import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:share_plus/share_plus.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'Services/banner_ad_widget.dart';


class NewAudioPlayer extends StatefulWidget {
  final String title;
  final String description;
  final String coverurl;
  final String mode;
  final String voice;
  final String audioPath;

  const NewAudioPlayer({
    Key? key,
    required this.title,
    required this.description,
    required this.coverurl,
    required this.mode,
    required this.voice,
    required this.audioPath,
  }) : super(key: key);

  @override
  State<NewAudioPlayer> createState() => _NewAudioPlayerState();
}

class _NewAudioPlayerState extends State<NewAudioPlayer> {
  PlayerController controller = PlayerController();





  bool _isUploading = false;
  String _saveText = "Save your story to access it later.";
  final firestore = FirebaseFirestore.instance;
  String username ="";
  bool _subscribed = false;
  late final void Function(CustomerInfo) _customerInfoListener;


  @override
  void initState() {
    super.initState();

    _initializePlayer();
    getusername();
    _setupIsPro();
  }

  @override
  void dispose() {

    controller.dispose();
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
    Purchases.addCustomerInfoUpdateListener(_customerInfoListener);
  }


  void _playandPause() async {
    controller.playerState == PlayerState.playing
        ? await controller.pausePlayer()
        : await controller.startPlayer(finishMode: FinishMode.loop);
  }

  Future<void> _initializePlayer() async {

    await controller.preparePlayer(
      path: widget.audioPath,
      shouldExtractWaveform: true,
      noOfSamples: 100,
      volume: 1.0,
    );
    print('Audio Path: ${widget.audioPath}');
    await controller.startPlayer(finishMode: FinishMode.stop);

  }

  Future<void> _saveStory(String collection) async {
    setState(() {
      _isUploading = true;
      _saveText = "Just a moment, we're saving your story.";
    });

    try {

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final storyDocRef = firestore.collection(collection).doc();
      final storyId = storyDocRef.id;

      // Download and compress the cover image
      final coverImagePath = await _downloadAndCompressCoverImage(widget.coverurl);

      // Upload cover image
      final coverImageUrl = await _uploadFileToStorage(
        coverImagePath,
        'images/story_$storyId\_cover.jpg',
      );

      // Upload audio
      final audioUrl = await _uploadFileToStorage(
        widget.audioPath,
        'audios/story_$storyId.mp3',
      );

      // Save story data to Firestore
      await storyDocRef.set({

        'storyId': storyId,
        'mode': widget.mode,
        'userId': user.uid,
        'title': widget.title,
        'description': widget.description,
        'coverImageUrl': coverImageUrl,
        'isAudio': true,
        'audioUrl': audioUrl,
        'voice': widget.voice,
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _isUploading = false;
        _saveText = "Your story is saved! You can view it anytime later.";
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Story Saved!')),
        );
      });
    } catch (e) {
      print('Error saving story: $e');
      setState(() {
        _isUploading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save story.')),
        );
      });
    }
  }

  Future<void> _shareStory() async {

    try {
      // Get the local video file path
      final localAudioPath = widget.audioPath;
      final audioFile = File(localAudioPath);

      if (await audioFile.exists()) {
        // Share the video file if it exists
        await Share.shareXFiles(
          [XFile(localAudioPath)],
          text: 'I just created an incredible audio story: ${widget.title}! Made with Craft-a-Story. Check it out!',
        );
      }
    } catch (e) {
      print('Error while sharing story: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to share the story.')),
      );
    }


  }

  Future<String> _downloadAndCompressCoverImage(String coverImageUrl) async {
    final response = await http.get(Uri.parse(coverImageUrl));
    if (response.statusCode != 200) throw Exception('Failed to download cover image');

    final tempDir = await getTemporaryDirectory();
    final originalPath = '${tempDir.path}/original_cover_image.jpg';
    final originalFile = File(originalPath);
    await originalFile.writeAsBytes(response.bodyBytes);

    final compressedPath = '${tempDir.path}/compressed_cover_image.jpg';
    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      originalPath,
      compressedPath,
      quality: 30,
    );

    if (compressedFile == null) throw Exception('Image compression failed');
    return compressedFile.path;
  }

  Future<String> _uploadFileToStorage(String filePath, String storagePath) async {
    final file = File(filePath);
    final storageRef = FirebaseStorage.instance.ref().child(storagePath);
    await storageRef.putFile(file);
    return await storageRef.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Crafted Story',
          style: TextStyle( fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if(!_subscribed)
              BannerAdWidget(),


        AudioFileWaveforms(
        size: Size(MediaQuery.of(context).size.width, 200.0),
        playerController: controller,
        enableSeekGesture: true,
        waveformType: WaveformType.long,
        waveformData: [],
        animationCurve: Curves.easeIn,
        playerWaveStyle:  PlayerWaveStyle(
            fixedWaveColor: Colors.grey,
            liveWaveColor: Colors.blueAccent,
            spacing: 10,
          scaleFactor: 400,
          waveThickness: 3.5,
          waveCap: StrokeCap.butt,
          liveWaveGradient: LinearGradient(
            colors: [Colors.blue, Colors.purple],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(Rect.fromLTWH(0, 0, 200, 50)), // Define the gradient

        ),

    ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () =>  controller.startPlayer(finishMode: FinishMode.stop)
    ),
                IconButton(
                  icon: const Icon(Icons.pause),
                  onPressed: () =>  controller.pausePlayer()
    ),
                IconButton(
                  icon: const Icon(Icons.stop),
                  onPressed: () =>  controller.stopPlayer()
    ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8), // Add space before button
                  // Save Story Button
                  SizedBox(
                    width: double.infinity, // Make the button full-width
                    child: ElevatedButton.icon(

                      onPressed: () {
                        _saveStory('stories');
                      },
                      icon: const Icon(Icons.save, color: Colors.white,), // Save icon
                      label: const Text('Save Story',style: TextStyle(color: Colors.white),), // Button label
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),backgroundColor:  const Color(
                          0xFF282943),// Button padding
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  //temp save to explore button
                  if(username=="DYxrS1A8UuM0y1AOoA99yTIGTQn2")
                    SizedBox(
                      width: double.infinity, // Make the button full-width
                      child: ElevatedButton.icon(

                        onPressed: () {
                          _saveStory('Explore_stories');
                        },
                        icon: const Icon(Icons.save, color: Colors.white,), // Save icon
                        label: const Text('Save Story to Explore',style: TextStyle(color: Colors.white),), // Button label
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),backgroundColor:  const Color(
                            0xFF282943),// Button padding
                        ),
                      ),
                    ),

                  const SizedBox(height: 8), // Add space for description
                  Center( // Wrap in Center widget
                    child:  Text(
                      _saveText,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  if (_isUploading) const LinearProgressIndicator(),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Story Title
                      Expanded(
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,

                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.share,   ),
                        onPressed: _shareStory,
                      ),
                      // Like Button with Count

                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
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
                        widget.mode, // Placeholder for genre
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
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
                        widget.voice, // Placeholder for voice type
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),



                  const Divider(
                    color: Colors.grey,
                    thickness: 0.5,
                  ),

                  const SizedBox(height: 8),
                  Text(
                    widget.description,
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

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
