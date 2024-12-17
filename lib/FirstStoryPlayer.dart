import 'dart:io';
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home.dart';
import 'package:page_transition/page_transition.dart';

class FirstStoryPlayer extends StatefulWidget {
  final String videoPath;
  final String title;
  final String description;
  final String coverurl;
  final String mode;
  final String voice;
  final String audioPath;

  const FirstStoryPlayer({
    Key? key,
    required this.videoPath,
    required this.title,
    required this.description,
    required this.coverurl,
    required this.mode,
    required this.voice,
    required this.audioPath
  }) : super(key: key);

  @override
  State<FirstStoryPlayer> createState() => _FirstStoryPlayerState();
}

class _FirstStoryPlayerState extends State<FirstStoryPlayer> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isUploading = false;
  String _saveText = "Save your story to access it later.";
  final firestore = FirebaseFirestore.instance;
  String username ="";

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    getusername();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> _initializePlayer() async {
    _videoPlayerController = VideoPlayerController.file(File(widget.videoPath));
    await _videoPlayerController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      aspectRatio: 1,
      autoPlay: true,
      looping: false,
      // showControls: false
    );
    setState(() {});
  }

  Future<void> getusername() async{
    final user = FirebaseAuth.instance.currentUser;
    username= user!.uid;

  }

  Future<void> goHome() async{
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => CraftAStoryApphome()),
          (Route<dynamic> route) => false, // Removes all existing routes
    );

  }
  Future<void> _saveStoryToFirebase() async {
    Trace customTraceVideoStory = FirebasePerformance.instance.newTrace('Upload-VideoStory-CloudStorage');
    await customTraceVideoStory.start();
    setState(() {
      _isUploading = true;
      _saveText="Just a moment, we're saving your story.";
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      username= user!.uid;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final storyDocRef = firestore.collection('stories').doc();
      final storyId = storyDocRef.id;
      final coverImagePath = await _downloadAndCompressCoverImage(widget.coverurl);
      final coverImageUrl = await _uploadFileToStorage(
        coverImagePath,
        'images/story_$storyId\_cover.jpg',
      );
      final videoUrl = await _uploadFileToStorage(
        widget.videoPath,
        'videos/story_$storyId.mp4',
      );
      final audioUrl = await _uploadFileToStorage(
        widget.audioPath,
        'audios/story_$storyId.mp3',   // Use storyId here
      );


      await storyDocRef.set({
        'storyId': storyId,
        'mode': widget.mode,
        'userId': user!.uid,
        'title': widget.title,
        'description': widget.description,
        'coverImageUrl': coverImageUrl,
        'videoUrl': videoUrl,
        'audioUrl': audioUrl,
        'voice' : widget.voice,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await _saveFileLocally(coverImagePath, 'cover_$storyId.jpg');
      await _saveFileLocally(widget.videoPath, 'video_$storyId.mp4');


      await customTraceVideoStory.stop();
      setState(() {
        _isUploading = false;
        _saveText="Your story is saved! You can view it anytime later.";
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

  Future<void> _saveStoryToExplore() async {
    setState(() {
      _isUploading = true;
      _saveText="Just a moment, we're saving your story.";
    });

    try {
      final firestore = FirebaseFirestore.instance;
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // 1. Generate the storyId first
      final storyDocRef = firestore.collection('Explore_stories').doc();
      final storyId = storyDocRef.id;


// 2. Download the cover image
      final coverImagePath = await _downloadAndCompressCoverImage(widget.coverurl);

      // 3. Upload cover image to Storage and get its URL
      final coverImageUrl = await _uploadFileToStorage(
        coverImagePath,
        'images/story_$storyId\_cover.jpg', // Use storyId here
      );

      // 4. Upload video to Storage and get its URL
      final videoUrl = await _uploadFileToStorage(
        widget.videoPath,
        'videos/story_$storyId.mp4',   // Use storyId here
      );
      // 5. Upload audio to Storage and get its URL
      final audioUrl = await _uploadFileToStorage(
        widget.audioPath,
        'audios/story_$storyId.mp3',   // Use storyId here
      );
      // 5. Upload story data to Firestore (including coverImageUrl and videoUrl)
      await storyDocRef.set({ // Use storyDocRef with the generated ID
        'storyId': storyId,
        'mode': widget.mode,
        'userId': user.uid,
        'title': widget.title,
        'description': widget.description,
        'coverImageUrl': coverImageUrl,
        'videoUrl': videoUrl,
        'audioUrl': audioUrl,
        'voice' : widget.voice,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 6. Save cover image and video locally
      //  await _saveFileLocally(coverImagePath, 'cover_$storyId.jpg');
      //  await _saveFileLocally(widget.videoPath, 'video_$storyId.mp4');

      setState(() {
        _isUploading = false;
        _saveText="Your story is saved! You can view it anytime later.";
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


  Future<void> _saveFileLocally(String filePath, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final newFile = File('${directory.path}/$fileName');
      final file = File(filePath);
      await file.copy(newFile.path);
      print('File saved locally: ${newFile.path}');
    } catch (e) {
      print('Error saving file locally: $e');
    }
  }

  Future<String> _downloadCoverImage(String coverImageUrl) async {
    final response = await http.get(Uri.parse(coverImageUrl));
    if (response.statusCode == 200) {
      final tempDir = await getTemporaryDirectory();
      final coverImagePath = '${tempDir.path}/cover_image.jpg';
      final coverImageFile = File(coverImagePath);
      await coverImageFile.writeAsBytes(response.bodyBytes);
      return coverImagePath;
    } else {
      throw Exception('Failed to download cover image');
    }
  }

  Future<String> _downloadAndCompressCoverImage(String coverImageUrl) async {
    final response = await http.get(Uri.parse(coverImageUrl));
    if (response.statusCode != 200) {
      throw Exception('Failed to download cover image');
    }
    final tempDir = await getTemporaryDirectory();
    final originalPath = '${tempDir.path}/original_cover_image.jpg';
    final originalImageFile = File(originalPath);
    await originalImageFile.writeAsBytes(response.bodyBytes);
    final compressedPath = '${tempDir.path}/compressed_cover_image.jpg';
    final compressedImageFile = await FlutterImageCompress.compressAndGetFile(
      originalPath,
      compressedPath,
      quality: 30,
    );
    if (compressedImageFile == null) {
      throw Exception('Image compression failed');
    }
    return compressedImageFile.path;
  }

  Future<String> _uploadFileToStorage(String filePath, String storagePath) async {
    final storage = FirebaseStorage.instance;
    final file = File(filePath);
    final storageRef = storage.ref().child(storagePath);
    try {
      await storageRef.putFile(file);
      final downloadURL = await storageRef.getDownloadURL();
      return downloadURL;
    } on FirebaseException catch (e) {
      print('Error uploading file: ${e.code}');
      throw e;
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


  Future<void> _shareStory() async{
    try {
      final localVideoPath = widget.videoPath;
      final videoFile = File(localVideoPath);
      if (await videoFile.exists()) {
        await Share.shareXFiles(
          [XFile(localVideoPath)],
          text: 'I just created an incredible story: ${widget.title}! Made with Craft-a-Story. Check it out!',
        );
      }
    } catch (e) {
      print('Error while sharing story: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to share the story.')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black,),
          onPressed: () {
            goHome();
          },
        ),
        title: Text('Your Crafted Story',
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.w600),
          ),),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _chewieController != null &&
                _videoPlayerController.value.isInitialized
                ? AspectRatio(
              aspectRatio: 1,
              child: Chewie(
                controller: _chewieController!,
              ),
            )
                : const Center(
              child: CircularProgressIndicator(),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isUploading ? null : () {
                        _saveStoryToFirebase();
                      },
                      icon: const Icon(Icons.save, color: Colors.black,),
                      label: Text('Save Story', style: GoogleFonts.poppins(
                        textStyle: const TextStyle(color: Colors.black),
                      )),
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.grey.shade200,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))
                      ),
                    ),
                  ),

                  if(username=="DYxrS1A8UuM0y1AOoA99yTIGTQn2")
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _saveStoryToExplore();
                        },
                        icon: const Icon(Icons.save, color: Colors.white,),
                        label: Text('Save to Explore', style: GoogleFonts.poppins(
                          textStyle: const TextStyle(color: Colors.white),
                        )),
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: const Color(0xFF1A2259),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      _saveText,
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(color: Color(0xFF373636)),
                      ),
                    ),
                  ),
                  if (_isUploading)
                    const LinearProgressIndicator(),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isUploading ? null : () {
                        goHome();
                      },
                      icon: const Icon(Icons.home, color: Colors.white,),
                      label: Text('Let\'s Go Home!', style: GoogleFonts.poppins(
                        textStyle: const TextStyle(color: Colors.white),
                      )),
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFF1A2259),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.title,
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.black
                            ),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      InkWell(
                        onTap: _shareStory,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                          ),
                          child: Icon(Icons.share, color: Theme.of(context).colorScheme.onPrimaryContainer,size: 28,),
                        ),
                      ),

                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.category, color: Colors.grey[500], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Genre: ',
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[500]
                          ),
                        ),
                      ),
                      Text(
                        widget.mode,
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.record_voice_over, color: Colors.grey[500], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Voice: ',
                        style:  GoogleFonts.poppins(
                          textStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                      Text(
                        widget.voice,
                        style:  GoogleFonts.poppins(
                          textStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(
                    color: Colors.grey,
                    thickness: 0.5,
                  ),
                  const SizedBox(height: 16),
                  Text(
                      widget.description,
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                            fontSize: 16,
                            color: Colors.black
                        ),
                      )
                  ),

                  const SizedBox(height: 20),
                  const Divider(
                    color: Colors.grey,
                    thickness: 0.5,
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}