import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/core/cache.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class ProfileSetupProvider extends ChangeNotifier {
  // Firebase Instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  final cache = CacheService();

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

  // Getters
  File? get profileImage => _profileImage;
  String get selectedGender => _selectedGender;
  DateTime? get dateOfBirth => _dateOfBirth;
  bool get isLoading => _isLoading;
  String? get imageUrl => _imageUrl;

  Future<void> saveUserFromAuth(User firebaseUser) async {
    final userRef = _firestore.collection('users').doc(firebaseUser.uid);
    final doc = await userRef.get();

    if (!doc.exists) {
      await userRef.set({
        'uid': firebaseUser.uid,
        'email': firebaseUser.email,
        'name': firebaseUser.displayName ?? '',
        'role': 'user', // default role
        'photoUrl': firebaseUser.photoURL ?? '',
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
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
    // return nameController.text.isNotEmpty &&
    //     emailController.text.isNotEmpty &&
    //     dobController.text.isNotEmpty &&
    //     _selectedGender.isNotEmpty &&
    //     phoneController.text.isNotEmpty &&
    //     addressController.text.isNotEmpty;

    return emailController.text.isNotEmpty;
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  // -----------------------------
  // FIREBASE LOGIC
  // -----------------------------

  /// Called after sign-in (email/password or Google)
  /// Saves basic user info if not already in Firestore
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
  Future<void> loadUserProfile() async {
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
        log("[Profile Setup Provider] in profile loaded");
        log("[Profile Setup Provider] ${_imageUrl}");

        await cache.cacheProfile(
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

  /// Save updated profile to Firestore & Firebase Auth
  Future<void> saveUserProfile() async {
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

      // Upload image if selected
      if (_profileImage != null) {
        final ref = _storage.ref().child('user_profiles/${user.uid}.jpg');
        try {
          final uploadTask = ref.putFile(_profileImage!);
          uploadTask.snapshotEvents.listen((event) {
            log("Upload: ${(event.bytesTransferred / event.totalBytes * 100).toStringAsFixed(1)}%");
          });

          await uploadTask;
          downloadUrl = await ref.getDownloadURL();
          await user.updatePhotoURL(downloadUrl);
        } catch (e) {
          log("[image upload error] $e");
        }
      }

      // Update Auth display name
      if (nameController.text.trim() != (user.displayName ?? '')) {
        await user.updateDisplayName(nameController.text.trim());
      }

      // Prepare profile data
      final profileData = {
        'id': user.uid,
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'dob': dobController.text.trim(),
        'gender': _selectedGender,
        'phone': phoneController.text.trim(),
        'address': addressController.text.trim(),
        'imageUrl': downloadUrl ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(profileData, SetOptions(merge: true));

      await cache.cacheProfile(
        name: nameController.text.trim(),
        imageUrl: downloadUrl ?? '',
        email: emailController.text.trim(),
      );

      Fluttertoast.showToast(msg: "Profile updated successfully!");
    } catch (e, stack) {
      debugPrint("🔥 Error saving profile: $e");
      debugPrint(stack.toString());
      Fluttertoast.showToast(msg: "Failed to update profile");
    } finally {
      _setLoading(false);
    }
  }

  // -----------------------------
  // Clean up
  // -----------------------------
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
