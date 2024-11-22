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
    return StoryData(
      storyId: data['storyId'] ?? '',
      title: data['title'] ?? 'Untitled',
      description: data['description'] ?? 'No description available',
      coverImageUrl: data['coverImageUrl'] ?? '',
      videoUrl: data['videoUrl'] ?? '',
    );
  }
}