
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:firebase_app_installations/firebase_app_installations.dart';
import 'firebase_options.dart';
import 'Services/notification_services.dart';
import 'signinpage.dart';
import 'home.dart';
import 'dart:ui';
import 'signinPagenew.dart';
import 'onboarding_page.dart';
import 'UserNameInputScreen.dart';
import 'Services/theme_provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import 'video_splash_screen.dart';


import 'V2/Home.dart';


void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Hide only bottom system navigation bar
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await _initializeFirebaseServices();

  await initializeFCM();

  await initializeRevenueCat();



  FlutterNativeSplash.remove();



  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const CraftAStoryApp(),
    ),
  );
}

Future<void> _initializeFirebaseServices() async {
  // Initialize App Check
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
  );

  // Initialize Notifications
  await NotificationServices.instance.initialise();

  // Initialize Crashlytics and Performance Monitoring
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
}

class CraftAStoryApp extends StatefulWidget {
  const CraftAStoryApp({Key? key}) : super(key: key);

  @override
  _CraftAStoryAppState createState() => _CraftAStoryAppState();
}


class _CraftAStoryAppState extends State<CraftAStoryApp> {

  late Future<bool> _userCheckFuture;
  bool _showSplashScreen = true;

  @override
  void initState(){
    super.initState();
    _userCheckFuture = _checkUserSignedIn();
  }

  Future<bool> _checkUserSignedIn() async {
    final user = FirebaseAuth.instance.currentUser;

    if(user != null){
      await initializeRevenueCat();
      return true;
    }
    return false;
  }


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Craft-a-Story',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Color(0xFFF4E9E3),
        colorScheme: ThemeData.light().colorScheme.copyWith(
          surface: Colors.white, // Background color for NavigationBar
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: Colors.blueGrey,
        scaffoldBackgroundColor: Colors.grey[900],
        colorScheme: ThemeData.dark().colorScheme.copyWith(
          surface: Colors.grey[900], // Background color for NavigationBar
        ),
      ),
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: FutureBuilder<bool>(
        future: _userCheckFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.data == true) {
            return CraftAStoryApphome();
           // Navigate to your home page
          }else{
            return HomePage(); // Navigate to your onboarding page
          }
        },
      ),
    );
  }
}


Future<void> initializeRevenueCat() async {
  final user = FirebaseAuth.instance.currentUser;

  // Ensure the user is authenticated
  if (user != null) {
    final configuration = PurchasesConfiguration("goog_ROHmfEQIqmPakpNaNfXYdMByLKh")
      ..appUserID = user!.uid; // Pass Firebase UID as appUserID
    await Purchases.configure(configuration);
    print("RevenueCat configured for user ID: ${user.uid}");
  } else {
    // If no user is logged in, configure anonymously
    final configuration = PurchasesConfiguration("goog_ROHmfEQIqmPakpNaNfXYdMByLKh");
    await Purchases.configure(configuration);
    print("RevenueCat configured anonymously");
  }
}



class FirebaseMessagingService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initializeFCM() async {
    try {


      // Additional logic for backend token storage can be implemented here.
    } catch (e) {
      print('Error initializing FCM: $e');
    }
  }
}

// Initialize FCM after Firebase setup
Future<void> initializeFCM() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessagingService.initializeFCM();
}