import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'onboarding_page.dart';
import 'package:page_transition/page_transition.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart'; // Import your HomePage here
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'UserNameInputScreen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:firebase_performance/firebase_performance.dart';

class Signinpagenew extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LoginPage();
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isNewUser = false;
  bool _isPasswordVisible = false;
  bool _showEmailPassword = false; // Track whether to show email/pass fields
  bool _isLoading = false; // Track loading state

  void _signInWithEmail() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Start loading
      });
      try {
        await _signInWithEmailAndPassword(
            _emailController.text, _passwordController.text, context);
      } finally {
        setState(() {
          _isLoading = false; // Stop loading
        });
      }
    }
  }

  void _toggleEmailPasswordFields() {
    setState(() {
      _showEmailPassword = !_showEmailPassword; // Toggle the state
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
    } finally {

    }
  }

  Future<void> _signInWithEmailAndPassword(String email, String password,
      BuildContext context) async {
    try {
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Create user document if necessary
      await _createUserDocument(userCredential.user!);
      await initializeRevenueCat();

      // Navigate to Home Page
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const CraftAStoryApphome()),
            (Route<dynamic> route) => false,
      );
    } on FirebaseAuthException catch (e) {
      print('Error signing in with Email: $e');
      String errorMessage = 'An error occurred.';
      if (e.code == 'user-not-found') {
        errorMessage = 'User not found!';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Invalid password!';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $errorMessage'),
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
      String? profilePicUrl;
      // Check if the user document exists
      final docSnapshot = await userDocRef.get();
      if (!docSnapshot.exists) {

        // Step 1: Check if the user has a profile picture from Google
        if(user.photoURL != null){
          final profilePicPath = await _downloadAndCompressProfilePic(user.photoURL!);
          // Upload image to Storage
          profilePicUrl = await _uploadFileToStorage(
            profilePicPath,
            'profile_pics/user_${user.uid}.jpg',
          );

        }



        _isNewUser=true;
        await userDocRef.set({
          'userId': user.uid,
          'email': user.email,
          'createdAt': FieldValue.serverTimestamp(),
          'credits': newUserCredits,
          'profilePicUrl': profilePicUrl,
        });


      }
    } catch (e) {
      print('Error creating user document: $e');
    }
  }


  Future<String> _downloadAndCompressProfilePic(String imageUrl) async {
    Trace customTraceProfilePic = FirebasePerformance.instance.newTrace('Download-ProfilePic-CloudStorage');
    await customTraceProfilePic.start();
    // Step 1: Download the image
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode != 200) {
      throw Exception('Failed to download profile picture');
    }

    // Step 2: Save the image temporarily
    final tempDir = await getTemporaryDirectory();
    final originalPath = '${tempDir.path}/original_profile_pic.jpg';
    final originalImageFile = File(originalPath);
    await originalImageFile.writeAsBytes(response.bodyBytes);


    // Step 3: Compress the image
    final compressedPath = '${tempDir.path}/compressed_profile_pic.jpg';
    final compressedImageFile = await FlutterImageCompress.compressAndGetFile(
      originalPath,
      compressedPath,
      quality: 30, // Adjust quality as needed (0-100)
    );

    if (compressedImageFile == null) {
      throw Exception('Image compression failed');
    }
    await customTraceProfilePic.stop();
    // Return the path of the compressed image
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.grey[50],
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: Image.asset(
                          'assets/Splash10.png',
                          height: 180,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Brand Image Banner (Example using a Container with Background)
                    Container(
                      height: 40, // Adjust height as needed
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                              'assets/logo1.png'), // Replace with your banner image asset path
                          // Adjust fit as needed
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Conditionally show email/password fields

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _signInWithEmail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A2259),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                      ),
                      child: Text('Log In',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 20),

                    // Sign-in Options at the bottom
                    const SizedBox(height: 20),
                    const Divider(
                      thickness: 1.5,
                    ), // Added a divider
                    const SizedBox(height: 20),
                    OutlinedButton(
                      onPressed: () async {

                        setState(() {
                          _isLoading = true; // Start loading
                        });
                        UserCredential? userCredential =
                        await _signInWithGoogle();
                        if (userCredential != null) {
                          await _createUserDocument(userCredential.user!);
                          await initializeRevenueCat();
                          setState(() {
                            _isLoading = false; // Stop loading
                          });

                          print("_ is new user : $_isNewUser");
                          // Navigate after ensuring the current frame is complete
                          if (!_isNewUser)
                            if (context.mounted) {
                              Future.microtask(() {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                      const CraftAStoryApphome()),
                                      (Route<dynamic> route) => false,
                                );
                              });
                            }
                          if (_isNewUser)
                            if (context.mounted) {
                              Future.microtask(() {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => UserNameInputScreen()),
                                      (Route<dynamic> route) => false,
                                );
                              });
                            }
                        }
                        setState(() {
                          _isLoading = false; // Stop loading
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/google_logo.svg',
                            height: 25,
                          ),
                          const SizedBox(width: 12),
                          const Text('Continue with Google',
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Add space at the very bottom, so that UI looks consistent on multiple devices.
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}