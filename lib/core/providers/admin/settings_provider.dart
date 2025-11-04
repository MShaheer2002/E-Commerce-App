import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/presentation/models/global_settings.dart';
import 'package:e_commerce_app/presentation/models/promo_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SettingsProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool _isLoaded = false;

  GlobalSettings? _globalSettings;

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoaded => _isLoaded;
  GlobalSettings? get globalSettings => _globalSettings;
  List<PromoCode> get promoCodes => _globalSettings?.promoCodes ?? [];

  // -------------------------PROMOCODE-------------------------

  /// Load current global promo data (for admin panel)
  Future<void> fetchGlobalPromo() async {
    if (_isLoaded) return;

    _isLoading = true;
    notifyListeners();

    try {
      final doc =
          await _firestore.collection('app_settings').doc('global_promo').get();

      if (doc.exists && doc.data() != null) {
        _globalSettings = GlobalSettings.fromMap(doc.data()!);
      } else {
        _globalSettings = const GlobalSettings(promoCodes: []);
      }

      _isLoaded = true;
    } catch (e, stack) {
      debugPrint('🔥 Error fetching global promo: $e');
      debugPrint('$stack');
      Fluttertoast.showToast(msg: "Failed to load global promo data");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Save or add a new global promo (append to the list)
  Future<void> saveGlobalPromo({
    required String code,
    required double discountPercent,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newPromo = PromoCode(
        code: code.trim().toUpperCase(),
        discountPercent: discountPercent,
        startTime: Timestamp.fromDate(startTime),
        endTime: Timestamp.fromDate(endTime),
      );

      // Merge with existing promos
      final existingPromos =
          List<PromoCode>.from(_globalSettings?.promoCodes ?? []);
      existingPromos.add(newPromo);

      final updatedSettings = GlobalSettings(promoCodes: existingPromos);

      await _firestore
          .collection('app_settings')
          .doc('global_promo')
          .set(updatedSettings.toMap());

      _globalSettings = updatedSettings;

      Fluttertoast.showToast(msg: "Promo added successfully");
    } catch (e, stack) {
      debugPrint('🔥 Error saving global promo: $e');
      debugPrint(stack.toString());
      Fluttertoast.showToast(msg: "Failed to save global promo");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Remove a specific promo by its code
  Future<void> removePromo(String code) async {
    _isLoading = true;
    notifyListeners();

    try {
      final existingPromos =
          List<PromoCode>.from(_globalSettings?.promoCodes ?? []);
      existingPromos.removeWhere((p) => p.code == code);

      final updatedSettings = GlobalSettings(promoCodes: existingPromos);

      await _firestore
          .collection('app_settings')
          .doc('global_promo')
          .set(updatedSettings.toMap());

      _globalSettings = updatedSettings;

      Fluttertoast.showToast(msg: "Promo removed successfully");
    } catch (e, stack) {
      debugPrint('🔥 Error removing promo: $e');
      debugPrint('$stack');
      Fluttertoast.showToast(msg: "Failed to remove promo");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear all promos
  Future<void> clearAllPromos() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestore.collection('app_settings').doc('global_promo').delete();
      _globalSettings = const GlobalSettings(promoCodes: []);

      Fluttertoast.showToast(msg: "All global promos removed");
    } catch (e, stack) {
      debugPrint('🔥 Error clearing promos: $e');
      debugPrint('$stack');
      Fluttertoast.showToast(msg: "Failed to clear promos");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void singleProductPromocode({required PromoCode promo}) {
    try {
        
    } catch (e) {}
  }
}
