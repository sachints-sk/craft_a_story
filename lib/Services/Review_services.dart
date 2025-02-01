import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static const _firstStoryCreatedKey = 'firstStoryCreated';
  static const _lastReviewPromptDateKey = 'lastReviewPromptDate';
  static const _hasReviewedKey = 'hasReviewed';  // New key to track if the user has reviewed

  // Save first story creation flag
  static Future<void> setFirstStoryCreated(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(_firstStoryCreatedKey, value);
  }

  // Get first story creation flag
  static Future<bool> getFirstStoryCreated() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_firstStoryCreatedKey) ?? false;
  }

  // Save the last review prompt date
  static Future<void> setLastReviewPromptDate(DateTime date) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(_lastReviewPromptDateKey, date.toIso8601String());
  }

  // Get the last review prompt date
  static Future<DateTime?> getLastReviewPromptDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? dateString = prefs.getString(_lastReviewPromptDateKey);
    return dateString != null ? DateTime.parse(dateString) : null;
  }

  // Save review status (whether the user has reviewed the app)
  static Future<void> setHasReviewed(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(_hasReviewedKey, value);
  }

  // Get review status
  static Future<bool> getHasReviewed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasReviewedKey) ?? false;
  }
}
