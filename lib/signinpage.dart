import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
            _buildSignInButton('assets/google_13170545.png', 'Sign up with Google'),
          ],
        ),
      ),
    );
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


  Widget _buildSignInButton(String imagePath, String label) {
    return ElevatedButton(
      onPressed: () async {
        UserCredential? userCredential = await _signInWithGoogle();
        if (userCredential != null) {
          // Navigate to the next screen or perform other actions
          print("User signed in: ${userCredential.user!.uid}");
        }
      }, // Add your sign-in logic here
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
          Text(label, style: const TextStyle(color: Colors.black,fontWeight: FontWeight.w500 )),
        ],
      ),
    );
  }
}