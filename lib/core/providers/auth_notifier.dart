import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthNotifier extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;

  AuthNotifier() {
    // Listen for Firebase auth state changes
    _auth.authStateChanges().listen((u) {
      user = u;
      notifyListeners(); // notify go_router to refresh
    });
  }
}
