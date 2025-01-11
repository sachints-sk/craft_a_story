import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthState extends ChangeNotifier {
  bool _isUserLoggedIn = false;

  bool get isUserLoggedIn => _isUserLoggedIn;

  // Constructor to check authentication status when the AuthState is initialized
  AuthState() {
    _checkUserSignedIn();
  }

  // Check if the user is signed in or not
  Future<void> _checkUserSignedIn() async {
    final user = FirebaseAuth.instance.currentUser;
    _isUserLoggedIn = user != null;
    notifyListeners(); // Notify listeners about the state change
    print("Authentication status updated: $_isUserLoggedIn");
  }

  // Method to manually update login state if needed
  void updateLoginState(bool isLoggedIn) {
    _isUserLoggedIn = isLoggedIn;
    notifyListeners();
    print("Manual update: isLoggedIn = $isLoggedIn");
  }
}
