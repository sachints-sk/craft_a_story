import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart'; // For temporary file
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:share_plus/share_plus.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'Services/banner_ad_widget.dart';


class NewVideoPlayer extends StatefulWidget {
  final String videoPath; // Pass the video path as a parameter
  final String title;
  final String description;
  final String coverurl;
  final String mode;
  final String voice;
  final String audioPath;

  const NewVideoPlayer({
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
  State<NewVideoPlayer> createState() => _NewVideoPlayerState();
}

class _NewVideoPlayerState extends State<NewVideoPlayer> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
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
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    Purchases.removeCustomerInfoUpdateListener(_customerInfoListener);// Dispose Chewie controller
    super.dispose();
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

  Future<void> _initializePlayer() async {
    // Initialize the video player
    _videoPlayerController = VideoPlayerController.file(File(widget.videoPath));


    await _videoPlayerController.initialize();

    // Initialize Chewie controller
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      aspectRatio: 1,
      autoPlay: true,
      looping: false, // Set to false if you don't want looping
      // Add other Chewie options as needed
    );

    setState(() {}); // Update the UI
  }

Future<void> getusername() async{
  final user = FirebaseAuth.instance.currentUser;
  username= user!.uid;

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

      // 1. Generate the storyId first
      final storyDocRef = firestore.collection('stories').doc();
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
        'userId': user!.uid,
        'title': widget.title,
        'description': widget.description,
        'coverImageUrl': coverImageUrl,
        'videoUrl': videoUrl,
        'audioUrl': audioUrl,
        'voice' : widget.voice,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 6. Save cover image and video locally
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


  // Helper function to save a file to local storage
  Future<void> _saveFileLocally(String filePath, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final newFile = File('${directory.path}/$fileName');
      final file = File(filePath);
      await file.copy(newFile.path);
      print('File saved locally: ${newFile.path}');
    } catch (e) {
      print('Error saving file locally: $e');
      // ... (handle error appropriately) ...
    }
  }

  // Helper function to download the cover image
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
    // Step 1: Download the image
    final response = await http.get(Uri.parse(coverImageUrl));
    if (response.statusCode != 200) {
      throw Exception('Failed to download cover image');
    }

    // Step 2: Save the image temporarily
    final tempDir = await getTemporaryDirectory();
    final originalPath = '${tempDir.path}/original_cover_image.jpg';
    final originalImageFile = File(originalPath);
    await originalImageFile.writeAsBytes(response.bodyBytes);

    // Step 3: Compress the image
    final compressedPath = '${tempDir.path}/compressed_cover_image.jpg';
    final compressedImageFile = await FlutterImageCompress.compressAndGetFile(
      originalPath,
      compressedPath,
      quality: 30, // Adjust quality as needed (0-100)
    );

    if (compressedImageFile == null) {
      throw Exception('Image compression failed');
    }

    // Return the path of the compressed image
    return compressedImageFile.path;
  }




  // Helper function to upload files to Firebase Storage
  Future<String> _uploadFileToStorage(String filePath, String storagePath) async {
    final storage = FirebaseStorage.instance;
    final file = File(filePath);

    // Create a reference to the file's path in Firebase Storage
    final storageRef = storage.ref().child(storagePath);

    // Upload the file
    try {
      await storageRef.putFile(file);
      print('Uploaded file to: ${storageRef.fullPath}');
      // Get and return the download URL
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
    // Get the local video file path
    final localVideoPath = widget.videoPath;
    final videoFile = File(localVideoPath);

    if (await videoFile.exists()) {
      // Share the video file if it exists
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
          icon: const Icon(Icons.close,),
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
        title: const Text('Crafted Story',style: TextStyle(fontWeight: FontWeight.bold),),
      ),
      body: SingleChildScrollView( // Make the Column scrollable
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if(!_subscribed)
              BannerAdWidget(),
            // Video Player using Chewie
            _chewieController != null &&
                _videoPlayerController.value.isInitialized
                ? AspectRatio(
                   aspectRatio: 1, // Keep the video player square
                    child: Chewie(
                    controller: _chewieController!,
              ),
            )
                : const Center(
              child: CircularProgressIndicator(), // Show loader while video is initializing
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const SizedBox(height: 8), // Add space before button
                  // Save Story Button
                  SizedBox(
                    width: double.infinity, // Make the button full-width
                    child: ElevatedButton.icon(

                      onPressed: () {
                        _saveStoryToFirebase();
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
                        _saveStoryToExplore();
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
                  if (_isUploading)
                    const LinearProgressIndicator(),
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