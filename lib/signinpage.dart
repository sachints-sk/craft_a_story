import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart'; // Import your HomePage here
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFF121224),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
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
              _buildSignInButton(
                'assets/google_13170545.png',
                'Sign in with Google',
                context,
              ),
              const SizedBox(height: 20),
              _buildEmailLoginFields(
                emailController,
                passwordController,
                context,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailLoginFields(TextEditingController emailController,
      TextEditingController passwordController, BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: "Email",
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12))),
          ),
        ),
        const SizedBox(height: 15),
        TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: "Password",
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12))),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async {
            await _signInWithEmailAndPassword(
              emailController.text,
              passwordController.text,
              context,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: const Text(
            'Sign in with Email',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ],
    );
  }

  Future<void> _signInWithEmailAndPassword(String email, String password,
      BuildContext context) async {
    try {
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Create user document if necessary
      await _createUserDocument(userCredential.user!);

      // Navigate to Home Page
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const CraftAStoryApphome()),
            (Route<dynamic> route) => false,
      );
    } catch (e) {
      print('Error signing in with Email: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    }
  }

  Future<void> _createUserDocument(User user) async {
    final firestore = FirebaseFirestore.instance;
    final userDocRef = firestore.collection('users').doc(user.uid);

    try {
      // Initialize Remote Config
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setDefaults({'NewUserCredits': 0});
      await remoteConfig.fetchAndActivate();

      final newUserCredits = remoteConfig.getInt('NewUserCredits');

      // Check if the user document exists
      final docSnapshot = await userDocRef.get();
      if (!docSnapshot.exists) {
        await userDocRef.set({
          'userId': user.uid,

          'email': user.email,
          'createdAt': FieldValue.serverTimestamp(),
          'credits': newUserCredits,
        });
      }
    } catch (e) {
      print('Error creating user document: $e');
    }
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser
          ?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  Future<void> initializeRevenueCat() async {
    final user = FirebaseAuth.instance.currentUser;

    // Ensure the user is authenticated
    if (user != null) {
      final configuration = PurchasesConfiguration(
          "goog_ROHmfEQIqmPakpNaNfXYdMByLKh")
        ..appUserID = user!.uid; // Pass Firebase UID as appUserID
      await Purchases.configure(configuration);
      print("RevenueCat configured for user ID: ${user.uid}");
    } else {
      // If no user is logged in, configure anonymously
      final configuration = PurchasesConfiguration(
          "goog_ROHmfEQIqmPakpNaNfXYdMByLKh");
      await Purchases.configure(configuration);
      print("RevenueCat configured anonymously");
    }
  }


  Widget _buildSignInButton(String imagePath, String label,
      BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        UserCredential? userCredential = await _signInWithGoogle();
        if (userCredential != null) {
          await _createUserDocument(userCredential.user!);
          await initializeRevenueCat();

          // Navigate after ensuring the current frame is complete
          if (context.mounted) {
            Future.microtask(() {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => const CraftAStoryApphome()),
                    (Route<dynamic> route) => false,
              );
            });
          }
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
          Image.asset(imagePath, height: 34, width: 34),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
