import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/presentation/models/banner_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'cloudinary_provider.dart';

class BannerProvider extends ChangeNotifier {
  final FirebaseFirestore _firebase = FirebaseFirestore.instance;

  // Fixed list of 5 banner slots
  List<BannerModel?> _bannerUrls = List.filled(5, null);
  List<BannerModel?> get bannerUrls => _bannerUrls;

  List<BannerModel> _banners = [];
  List<BannerModel> get banners => _banners;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Fetch all banners from Firestore
  Future<void> fetchBanners() async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firebase
          .collection('banners')
          .orderBy('position')
          .limit(5)
          .get();

      // Reset banners
      _bannerUrls = List.filled(5, null);

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final position = data['position'] ?? 0;

        if (position >= 0 && position < 5) {
          _bannerUrls[position] = BannerModel.fromJson(data);
        }
      }
    } catch (e, s) {
      log("[Fetch Banners] [Error] $e");
      log("[Fetch Banners] [Stack] $s");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Upload or update banner at specific position
  Future<void> pickAndUploadBanner(int index, BuildContext context) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (picked == null) return;

      final cloud = Provider.of<CloudinaryProvider>(context, listen: false);
      final url = await cloud.uploadImage(File(picked.path), folder: "banners");

      if (url != null) {
        // If banner exists at this position, update it
        if (_bannerUrls[index] != null) {
          final bannerId = _bannerUrls[index]!.bannerId;
          final banner = BannerModel(
            imageUrl: url,
            bannerId: bannerId,
          );

          await _firebase.collection('banners').doc(bannerId).update({
            'imageUrl': url,
            'position': index,
            'updatedAt': FieldValue.serverTimestamp(),
          });

          _bannerUrls[index] = banner;
        } else {
          // Create new banner
          final ref = _firebase.collection('banners').doc();
          final banner = BannerModel(
            imageUrl: url,
            bannerId: ref.id,
          );

          await ref.set({
            'imageUrl': url,
            'bannerId': ref.id,
            'position': index,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

          _bannerUrls[index] = banner;
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Banner uploaded successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e, s) {
      log("[Upload Banner] [Error] $e");
      log("[Upload Banner] [Stack] $s");

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading banner: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      notifyListeners();
    }
  }

  // Remove banner at specific position
  Future<void> removeBanner(int index, BuildContext context) async {
    try {
      if (_bannerUrls[index] != null) {
        final bannerId = _bannerUrls[index]!.bannerId;

        // Delete from Firestore
        if (bannerId != null && bannerId.isNotEmpty) {
          await _firebase.collection('banners').doc(bannerId).delete();
        }

        // Remove from local list
        _bannerUrls[index] = null;

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Banner removed successfully!'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        }

        notifyListeners();
      }
    } catch (e, s) {
      log("[Remove Banner] [Error] $e");
      log("[Remove Banner] [Stack] $s");

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing banner: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Delete all banners (utility function)
  Future<void> deleteAllBanners() async {
    try {
      final snapshot = await _firebase.collection('banners').get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      _bannerUrls = List.filled(5, null);
      notifyListeners();
    } catch (e, s) {
      log("[Delete All Banners] [Error] $e");
      log("[Delete All Banners] [Stack] $s");
    }
  }

  // Fetch active banners for display
  Future<void> userFetchBanner() async {
    try {
      if (_banners.isNotEmpty) {
        return;
      }
      _isLoading = true;
      notifyListeners();

      final snapshot =
          await _firebase.collection('banners').orderBy('position').get();

      _banners =
          snapshot.docs.map((doc) => BannerModel.fromJson(doc.data())).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e, s) {
      log("[User Fetch Banners] [Error] $e");
      log("[User Fetch Banners] [Stack] $s");
      _isLoading = false;
      notifyListeners();
    }
  }
}
