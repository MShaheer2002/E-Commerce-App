import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  User? _user;
  User? get user => _user;
  bool get isLoggedIn => _user != null;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) async {
      _user = user;
      if (user == null) {
        await signInWithGoogle(silent: true); // ✅ try restoring Google session
      }
      notifyListeners();
    });
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // ✅ EMAIL & PASSWORD SIGN UP
  Future<void> signUpWithEmail(String email, String password) async {
    try {
      setLoading(true);
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint("Sign up error: ${e}");
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  // ✅ EMAIL & PASSWORD LOGIN
  Future<void> loginWithEmail(String email, String password) async {
    try {
      setLoading(true);
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint("Login error: $e");
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  // ✅ GOOGLE SIGN-IN
  Future<void> signInWithGoogle({bool silent = false}) async {
    try {
      final googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = silent
          ? await googleSignIn.signInSilently()
          : await googleSignIn.signIn();

      if (googleUser == null) return; // user cancelled

      setLoading(true);
      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint("Google Sign-In error: $e");
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  // ✅ APPLE SIGN-IN
  Future<void> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      await _auth.signInWithCredential(oauthCredential);
    } catch (e) {
      debugPrint("Apple Sign-In error: $e");
      rethrow;
    }
  }

  // ✅ LOGOUT
  Future<void> logout() async {
    try {
      setLoading(true);

      final googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }

      await _auth.signOut();

      _user = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Logout failed: $e');
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  // ✅ EMAIL VALIDATION
  bool validateEmail(String email) {
    final emailRegex =
        RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return emailRegex.hasMatch(email.trim());
  }

  // ✅ PASSWORD VALIDATION
  bool validatePassword(String password) {
    return password.trim().length >= 8;
  }
}
