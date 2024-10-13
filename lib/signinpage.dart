import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart'; // Import your HomePage here

class SignInPage extends StatelessWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121224),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png', // Replace with your image
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 30),
            const Text(
              'Welcome Creator!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Unleash your creativity with our fun and interactive story creation app. Designed especially for kids, our app uses AI to help you...',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            // Use _buildSignInButton with Google logo path
            _buildSignInButton('assets/google_13170545.png', 'Sign up with Google', context),
          ],
        ),
      ),
    );
  }

  // Function to create user document in Firestore
  Future<void> _createUserDocument(User user) async {
    final firestore = FirebaseFirestore.instance;
    final userDocRef = firestore.collection('users').doc(user.uid);

    // Check if the user document already exists
    final docSnapshot = await userDocRef.get();
    if (!docSnapshot.exists) {
      // Create the document if it doesn't exist
      await userDocRef.set({
        'userId': user.uid,
        'displayName': user.displayName,
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(), // Use server timestamp
        // ... add other user data as needed
      });

      print('User document created successfully!');
    } else {
      print('User document already exists!');
    }
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print('Error signing in with Google: $e');
      // Handle error appropriately, e.g., show a SnackBar
      return null;
    }
  }

  Widget _buildSignInButton(String imagePath, String label, BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        UserCredential? userCredential = await _signInWithGoogle();
        if (userCredential != null) {
          // Create user document in Firestore
          await _createUserDocument(userCredential.user!);
          // Navigate to the Home page and remove all previous routes
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const CraftAStoryApphome()), // Replace HomePage with your actual home screen widget
                (Route<dynamic> route) => false,
          );
          print("User signed in: ${userCredential.user!.uid}");
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        textStyle: const TextStyle(fontSize: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imagePath, height: 34, width: 34), // Google logo
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
