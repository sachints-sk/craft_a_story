import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'firebase_options.dart';
import 'testfolder/texttospeech.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'dart:ui';
import 'signinpage.dart';
import 'home.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
//  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
//  PlatformDispatcher.instance.onError = (error, stack) {
//    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
////  };
  runApp(const CraftAStoryApp());
}

class CraftAStoryApp extends StatefulWidget {
  const CraftAStoryApp({Key? key}) : super(key: key);

  @override
  _CraftAStoryAppState createState() => _CraftAStoryAppState();
}

class _CraftAStoryAppState extends State<CraftAStoryApp> {


  @override
  void initState(){
    super.initState();
    initialisation();
  }

  void initialisation() async{

    await Future.delayed(const Duration(seconds: 3));
    FlutterNativeSplash.remove();
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Craft-a-Story',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: Colors.blue, // Set your primary color
        scaffoldBackgroundColor: Colors.white, // Set the background color
      ),
      // Use a StreamBuilder to listen for authentication state changes
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // If the user is logged in
          if (snapshot.hasData) {
            return const CraftAStoryApphome(); // Navigate to your home page
          } else {
            return const SignInPage(); // Navigate to sign-in page
          }
        },
      ),
    );
  }
}
