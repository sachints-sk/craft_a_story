import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ReviewUsPage extends StatelessWidget {
  // The URL for the app's Play Store page (you need to replace this with your actual app URL)
  final String playStoreUrl = "https://play.google.com/store/apps/details?id=com.yourcompany.yourapp";

  // Launch the URL for reviewing the app
  Future<void> _launchURL() async {
    if (await canLaunch(playStoreUrl)) {
      await launch(playStoreUrl);
    } else {
      throw 'Could not open the Play Store.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Review Us"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Display a friendly message
            Text(
              "Enjoying the app? We'd love to hear your thoughts!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold ,color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white // Dark mode text color
                  : Colors.black,),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            // Explanation or benefits of leaving a review
            Text(
              "Your feedback helps us improve the app and provide a better experience. Please take a moment to leave a review.",
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            // A star rating icon (optional, you can customize this or use an image)
            Icon(
              Icons.star_rate,
              size: 100,
              color: Colors.orange,
            ),
            SizedBox(height: 30),
            // Button to redirect to Play Store
            ElevatedButton(
              onPressed: _launchURL,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text("Rate Our App"),
            ),
            SizedBox(height: 20),
            // Optional: A dismiss button if the user doesn't want to review now
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the page
              },
              child: Text(
                "Maybe Later",
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
