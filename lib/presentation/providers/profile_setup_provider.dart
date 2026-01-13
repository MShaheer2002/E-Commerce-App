import 'dart:developer';
import 'dart:io';

import 'package:ProductPlug/core/providers/admin/cloudinary_provider.dart';
import 'package:ProductPlug/presentation/providers/cache_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
// Import your CloudinaryProvider

class ProfileSetupProvider extends ChangeNotifier {
  // Firebase Instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  // Add Cloudinary Provider
  final CloudinaryProvider _cloudinaryProvider = CloudinaryProvider();

  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  // Local fields
  File? _profileImage;
  String _selectedGender = '';
  DateTime? _dateOfBirth;
  bool _isLoading = false;
  String? _imageUrl;
  double _uploadProgress = 0.0;

  // Getters
  File? get profileImage => _profileImage;
  String get selectedGender => _selectedGender;
  DateTime? get dateOfBirth => _dateOfBirth;
  bool get isLoading => _isLoading;
  String? get imageUrl => _imageUrl;
  double get uploadProgress => _uploadProgress;
  bool get isUploading => _cloudinaryProvider.isUploading;

  Future<void> saveUserFromAuth(User firebaseUser) async {
    final userRef = _firestore.collection('users').doc(firebaseUser.uid);
    final doc = await userRef.get();

    final data = doc.data();
    final bool hasRole = data != null && data.containsKey('role');

    if (!doc.exists || !hasRole) {
      // If doc doesn't exist OR it exists but has no role (e.g. created by FCM logic),
      // merge the basic role and auth data.
      await userRef.set({
        'uid': firebaseUser.uid,
        'email': firebaseUser.email,
        'name': firebaseUser.displayName ?? '',
        'role': 'user',
        'photoUrl': firebaseUser.photoURL ?? '',
        'updatedAt': Timestamp.now(),
        if (!doc.exists) 'createdAt': Timestamp.now(),
      }, SetOptions(merge: true));
      log("[Profile Setup] Ensured user document and role for ${firebaseUser.uid}");
    }
  }

  // -----------------------------
  // UI helpers
  // -----------------------------
  void setGender(String gender) {
    _selectedGender = gender;
    notifyListeners();
  }

  void setDateOfBirth(DateTime date) {
    _dateOfBirth = date;
    dobController.text = '${date.day}/${date.month}/${date.year}';
    notifyListeners();
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );
      if (picked != null) {
        _profileImage = File(picked.path);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
      Fluttertoast.showToast(msg: "Failed to pick image");
    }
  }

  bool validateForm() {
    return emailController.text.isNotEmpty;
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void _setUploadProgress(double progress) {
    _uploadProgress = progress;
    notifyListeners();
  }

  // -----------------------------
  // FIREBASE LOGIC
  // -----------------------------

  /// Called after sign-in (email/password or Google)
  Future<void> createUserIfNew() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final docRef = _firestore.collection('users').doc(user.uid);
      final doc = await docRef.get();

      if (!doc.exists) {
        await docRef.set({
          'id': user.uid,
          'name': user.displayName ?? '',
          'email': user.email ?? '',
          'imageUrl': user.photoURL ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });
        debugPrint("🟢 User document created for ${user.uid}");
      } else {
        debugPrint("🟡 User document already exists.");
      }
    } catch (e, stack) {
      debugPrint("🔥 Error creating user doc: $e");
      debugPrint(stack.toString());
    }
  }

  /// Load profile from Firestore
  Future<void> loadUserProfile(CacheProvider cacheProvider) async {
    log("[Profile Setup Provider] in load Profile");
    final user = _auth.currentUser;
    if (user == null) {
      Fluttertoast.showToast(msg: "No user logged in");
      return;
    }

    try {
      _setLoading(true);
      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists) {
        final data = doc.data()!;
        nameController.text = data['name'] ?? '';
        emailController.text = data['email'] ?? user.email ?? '';
        dobController.text = data['dob'] ?? '';
        phoneController.text = data['phone'] ?? '';
        addressController.text = data['address'] ?? '';
        _selectedGender = data['gender'] ?? '';
        _imageUrl = data['imageUrl'] ?? '';

        if (dobController.text.isNotEmpty && dobController.text.contains('/')) {
          final parts = dobController.text.split('/');
          if (parts.length == 3) {
            _dateOfBirth = DateTime(
              int.parse(parts[2]),
              int.parse(parts[1]),
              int.parse(parts[0]),
            );
          }
        }
        log("[Profile Setup Provider] profile loaded");
        log("[Profile Setup Provider] $_imageUrl");

        await cacheProvider.updateProfile(
          name: data['name'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
          email: data['email'] ?? user.email ?? '',
        );
      } else {
        nameController.text = user.displayName ?? '';
        emailController.text = user.email ?? '';
        _imageUrl = user.photoURL ?? '';
      }
    } catch (e, stack) {
      debugPrint("🔥 Error loading profile: $e");
      debugPrint(stack.toString());
      Fluttertoast.showToast(msg: "Failed to load profile");
    } finally {
      _setLoading(false);
    }
  }

  /// Save updated profile to Firestore using Cloudinary for image upload
  Future<void> saveUserProfile(CacheProvider cacheProvider) async {
    final user = _auth.currentUser;
    if (user == null) {
      Fluttertoast.showToast(msg: "No user logged in");
      return;
    }

    if (!validateForm()) {
      Fluttertoast.showToast(msg: "Please fill all required fields");
      return;
    }

    try {
      _setLoading(true);
      String? downloadUrl = _imageUrl;

      // Upload image to Cloudinary if selected
      if (_profileImage != null) {
        try {
          _setUploadProgress(0.3);
          Fluttertoast.showToast(
            msg: "Uploading image...",
            backgroundColor: Colors.blue,
          );

          // Upload to Cloudinary with folder organization
          final cloudinaryUrl = await _cloudinaryProvider.uploadImage(
            _profileImage!,
            folder: 'user_profiles/${user.uid}',
          );

          _setUploadProgress(0.7);

          if (cloudinaryUrl != null) {
            downloadUrl = cloudinaryUrl;
            // Update Firebase Auth profile photo URL
            await user.updatePhotoURL(downloadUrl);
            log("[Cloudinary Upload] Success: $downloadUrl");
          } else {
            throw Exception("Failed to upload image to Cloudinary");
          }

          _setUploadProgress(1.0);
        } catch (e) {
          log("[Cloudinary upload error] $e");
          Fluttertoast.showToast(
            msg: "Failed to upload image",
            backgroundColor: Colors.red,
          );
          _setLoading(false);
          return;
        }
      }

      // Update Auth display name
      if (nameController.text.trim() != (user.displayName ?? '')) {
        await user.updateDisplayName(nameController.text.trim());
      }

      // Prepare profile data
      final profileData = {
        // 'id': user.uid,
        'name': nameController.text.trim(),
        // 'email': emailController.text.trim(),
        'dob': dobController.text.trim(),
        'gender': _selectedGender,
        'phone': phoneController.text.trim(),
        'address': addressController.text.trim(),
        'imageUrl': downloadUrl ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Save to Firestore
      await _firestore.collection('users').doc(user.uid).update(
            profileData,
          );

      // Update local cache and notify listeners
      await cacheProvider.updateProfile(
        name: nameController.text.trim(),
        imageUrl: downloadUrl ?? '',
        email: emailController.text.trim(),
      );

      Fluttertoast.showToast(
        msg: "Profile updated successfully!",
        backgroundColor: Colors.green,
      );

      // Reset upload progress
      _setUploadProgress(0.0);
    } catch (e, stack) {
      log("[Profile Update] Error saving profile: $e");
      debugPrint(stack.toString());
      Fluttertoast.showToast(
        msg: "Failed to update profile",
        backgroundColor: Colors.red,
      );
    } finally {
      _setLoading(false);
    }
  }

  // -----------------------------
  // Clean up
  // -----------------------------
  void clearData() {
    nameController.clear();
    emailController.clear();
    dobController.clear();
    phoneController.clear();
    addressController.clear();
    _profileImage = null;
    _selectedGender = '';
    _dateOfBirth = null;
    _imageUrl = null;
    _uploadProgress = 0.0;
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    dobController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }
}
