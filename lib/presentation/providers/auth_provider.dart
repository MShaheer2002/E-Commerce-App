import 'dart:developer';

import 'package:ProductPlug/presentation/providers/cache_provider.dart';
import 'package:ProductPlug/presentation/providers/profile_setup_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  String? _cachedRole;
  String? get currentRole => _cachedRole;

  // For routing, only consider user logged-in if emailVerified == trues
  User? get firebaseUser => _rawUser;
  bool get isLoggedIn {
    if (_rawUser == null) return false;
    // Allow admins to skip email verification
    if (_cachedRole == "admin") return true;
    return _rawUser!.emailVerified;
  }

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) async {
      _rawUser = user;
      if (user != null) {
        // ✅ Fetch role from Firestore on startup
        await getUserRole();
      } else {
        _cachedRole = null;
      }

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
      ProfileSetupProvider profileProvider, CacheProvider cacheProvider) async {
    setLoading(true);
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      final user = cred.user;
      if (user == null) {
        throw FirebaseAuthException(code: 'no-user', message: 'Login failed.');
      }
      await profileProvider.loadUserProfile(cacheProvider);
      // Ensure latest data
      await user.reload();

      final freshUser = _auth.currentUser;
      final role = await getUserRole();

      if (role != "admin" && (freshUser == null || !freshUser.emailVerified)) {
        await _auth.signOut();

        throw FirebaseAuthException(
          code: 'email-not-verified',
          message: 'Please verify your email before logging in.',
        );
      }
      if (role != "admin") {
        await profileProvider.saveUserFromAuth(freshUser!);
      } else if (role == "admin") {
        _rawUser = freshUser;
        _cachedRole = role;
        notifyListeners();
      }
      // If verified, _auth.authStateChanges will update _rawUser and route will allow home.

      log("Login In!!");
    } finally {
      setLoading(false);
    }
  }

  // ✅ GOOGLE SIGN-IN
  Future<void> signInWithGoogle(
      ProfileSetupProvider profileProvider, CacheProvider cacheProvider,
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
        await profileProvider.loadUserProfile(cacheProvider); // ✅ add this line
      }
    } catch (e) {
      debugPrint("Google Sign-In error: $e");
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  // ✅ APPLE SIGN-IN
  Future<void> signInWithApple(
      ProfileSetupProvider profileProvider, CacheProvider cacheProvider) async {
    try {
      setLoading(true);

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

      if (firebaseUser != null) {
        // ✅ Create Firestore profile if not exists
        await profileProvider.saveUserFromAuth(firebaseUser!);
        await profileProvider.loadUserProfile(cacheProvider);
      }
    } catch (e) {
      debugPrint("Apple Sign-In error: $e");
      rethrow;
    } finally {
      setLoading(false);
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
      // ignore: use_build_context_synchronously
      context.go("/");
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

  Future<String?> getUserRole() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    _cachedRole = doc.data()?['role'];
    return _cachedRole;
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      log("[Auth] Reset email sent to $email");
    } catch (e, s) {
      log("[Auth] Forgot password error: $e");
      log("[Auth] Stack: $s");
      rethrow;
    }
  }

  /// ✅ DELETE ACCOUNT (Permanent)
  /// Deletes user from Firebase Authentication and all related Firestore data
  bool _shouldNavigateToHome = false;
  bool get shouldNavigateToHome {
    if (_shouldNavigateToHome) {
      _shouldNavigateToHome = false; // Reset on read (consume)
      return true;
    }
    return false;
  }

  /// ✅ DELETE ACCOUNT (Permanent)
  /// Deletes user from Firebase Authentication and all related Firestore data
  Future<void> deleteAccount() async {
    try {
      setLoading(true);

      // ✅ Force navigation immediately to Home Screen
      _shouldNavigateToHome = true;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'no-user',
          message: 'No user is currently logged in.',
        );
      }

      final uid = user.uid;

      // 1️⃣ Delete user data from Firestore
      final firestore = FirebaseFirestore.instance;

      // Delete user profile
      await firestore.collection('users').doc(uid).delete();
      log("[Auth] Deleted user profile for $uid");

      // Delete cart
      await firestore.collection('carts').doc(uid).delete();
      log("[Auth] Deleted cart for $uid");

      // Delete favorites
      final favoritesSnapshot = await firestore
          .collection('favorites')
          .where('userId', isEqualTo: uid)
          .get();
      for (var doc in favoritesSnapshot.docs) {
        await doc.reference.delete();
      }
      log("[Auth] Deleted ${favoritesSnapshot.docs.length} favorites for $uid");

      // Delete orders (or mark as deleted)
      final ordersSnapshot = await firestore
          .collection('orders')
          .where('userId', isEqualTo: uid)
          .get();
      for (var doc in ordersSnapshot.docs) {
        await doc.reference.delete();
      }
      log("[Auth] Deleted ${ordersSnapshot.docs.length} orders for $uid");

      // 2️⃣ Delete user from Firebase Authentication
      await user.delete();
      log("[Auth] Deleted Firebase Auth user $uid");

      // 3️⃣ Sign out Google if signed in
      final googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }

      // 4️⃣ Clear local state
      _rawUser = null;
      _cachedRole = null;
      _shouldNavigateToHome = true;

      notifyListeners();
    } on FirebaseAuthException catch (e) {
      log("[Auth] Delete account error: ${e.code} - ${e.message}");

      // Handle re-authentication requirement
      if (e.code == 'requires-recent-login') {
        throw FirebaseAuthException(
          code: 'requires-recent-login',
          message:
              'Please log out and log back in before deleting your account.',
        );
      }

      rethrow;
    } catch (e, s) {
      log("[Auth] Delete account error: $e");
      log("[Auth] Stack: $s");
      rethrow;
    } finally {
      setLoading(false);
    }
  }
}
