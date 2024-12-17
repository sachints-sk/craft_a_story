import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


// story_data.dart
class StoryData {
  final String storyId;
  final String title;
  final String description;
  final String coverImageUrl;
  final String videoUrl;
  final String heading;
  final String mode;
  final String createdAt;
  final String voice;
  final int likes;
  final bool isAudio;
  final String audioUrl;

  StoryData({
    required this.storyId,
    required this.title,
    required this.description,
    required this.coverImageUrl,
    required this.videoUrl,
    this.heading = "",
    this.mode="",
    this.voice="",
    this.createdAt="",
    this.likes=0,
    this.isAudio=false,
    this.audioUrl="",
  });
  // Add this static method to create an instance from Firestore data
  static StoryData fromFirestore(Map<String, dynamic> data) {
    DateTime createdAtDate;
    if (data['createdAt'] != null) {
      createdAtDate = (data['createdAt'] as Timestamp).toDate();
    } else {
      createdAtDate = DateTime.now(); // Temporary fallback for missing timestamps
    }
    String formattedDate = DateFormat('dd-MM-yyyy').format(createdAtDate);


    return StoryData(
      storyId: data['storyId'] ?? '',
      title: data['title'] ?? 'Untitled',
      description: data['description'] ?? 'No description available',
      coverImageUrl: data['coverImageUrl'] ?? '',
      videoUrl: data['videoUrl'] ?? '',
      mode: data['mode'] ?? '',
      voice: data['voice'] ?? '',
      createdAt:formattedDate ?? '',
      isAudio: data['isAudio'] ?? false,
      audioUrl: data['audioUrl'] ?? '',
      likes: data['likes'] ?? 0,


    );
  }
}