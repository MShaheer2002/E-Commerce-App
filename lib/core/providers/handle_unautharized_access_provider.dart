import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HandleUnauthorizedAccessProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _currentUser;
  bool _isLoading = true;

  HandleUnauthorizedAccessProvider() {
    // Automatically listen for login/logout state changes
    _auth.authStateChanges().listen((user) {
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
    });
  }

  /// Returns `true` if user is logged in and FirebaseAuth is ready.
  bool get isUserAuthenticated => _currentUser != null;

  /// Returns current logged-in user id, or null if not logged in.
  String? get userId => _currentUser?.uid;

  /// Expose loading state (useful during app start)
  bool get isLoading => _isLoading;

  /// Ensures user is authenticated before performing Firestore call.
  /// Throws if user is not logged in.
  Future<bool> ensureUserAuthenticated() async {
    if (_isLoading) {
      // Wait for Firebase to initialize auth state if still loading
      await Future.delayed(const Duration(milliseconds: 500));
    }

    if (_currentUser == null) {
      throw Exception('Unauthorized: User not logged in');
    }
    return true;
  }
}
