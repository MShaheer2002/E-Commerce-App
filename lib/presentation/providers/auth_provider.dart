import 'dart:developer';

import 'package:e_commerce_app/presentation/providers/profile_setup_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _rawUser; // actual Firebase user
  bool _isInitialized = false;
  bool _isLoading = false;

  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;

  // For routing, only consider user logged-in if emailVerified == true
  User? get firebaseUser => _rawUser;
  bool get isLoggedIn => _rawUser != null && _rawUser!.emailVerified;

  AuthProvider() {
    // One listener to maintain a stable initialized state and normalized user
    _auth.authStateChanges().listen((User? user) async {
      // Set raw user immediately
      _rawUser = user;

      // If a user exists but not verified, don't let them be considered logged in:
      // We won't proactively sign them out here (UI handles sign-out after signup/login attempt),
      // but route decisions use isLoggedIn which checks emailVerified.
      _isInitialized = true;
      notifyListeners();
    });
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // SIGN UP: creates user, sends verification, signs out. Returns success boolean or throws.
  Future<void> signUpWithEmail(String email, String password) async {
    setLoading(true);
    try {
      final userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCred.user;
      if (user == null) {
        throw FirebaseAuthException(
            code: 'no-user', message: 'User creation failed.');
      }

      // Send verification. If this throws, user account still exists; forward the error.
      await user.sendEmailVerification();

      // Immediately sign out the newly-created user so they must verify before signing in.
      await _auth.signOut();

      // _auth.authStateChanges will fire and update _rawUser accordingly.
    } finally {
      setLoading(false);
    }
  }

  // ✅ EMAIL & PASSWORD LOGIN
  // LOGIN: signIn + require verification. If not verified, sign out and throw.
  Future<void> loginWithEmail(String email, String password,
      ProfileSetupProvider profileProvider) async {
    setLoading(true);
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      final user = cred.user;
      if (user == null) {
        throw FirebaseAuthException(code: 'no-user', message: 'Login failed.');
      }
      await profileProvider.loadUserProfile();
      // Ensure latest data
      await user.reload();

      final freshUser = _auth.currentUser;

      if (freshUser == null || !freshUser.emailVerified) {
        await _auth.signOut();
        throw FirebaseAuthException(
          code: 'email-not-verified',
          message: 'Please verify your email before logging in.',
        );
      }

      // If verified, _auth.authStateChanges will update _rawUser and route will allow home.
      await profileProvider.saveUserFromAuth(freshUser);

      log("Login In!!");
    } finally {
      setLoading(false);
    }
  }

  // ✅ GOOGLE SIGN-IN
  Future<void> signInWithGoogle(ProfileSetupProvider profileProvider,
      {bool silent = false}) async {
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

      if (firebaseUser != null) {
        // ✅ Create Firestore profile if not exists
        await profileProvider.saveUserFromAuth(firebaseUser!);
        await profileProvider.loadUserProfile(); // ✅ add this line
      }
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
  Future<void> logout(BuildContext context) async {
    try {
      setLoading(true);

      final googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }

      await _auth.signOut();

      _rawUser = null;
      context.go("/login");
      notifyListeners();
    } catch (e) {
      debugPrint('Logout failed: $e');
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  // Useful helpers:
  Future<void> resendVerification() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
          code: 'no-user', message: 'No logged-in user.');
    }
    await user.sendEmailVerification();
  }

  // For UI to force refresh of user (e.g. after they clicked email link and returned)
  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
    _rawUser = _auth.currentUser;
    notifyListeners();
  }

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
