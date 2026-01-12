import 'package:ProductPlug/presentation/models/global_settings.dart';
import 'package:ProductPlug/presentation/models/promo_model.dart';
import 'package:ProductPlug/presentation/models/tax_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SettingsProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool _isLoaded = false;
  bool _isTaxLoading = false;
  bool _isTaxLoaded = false;

  GlobalSettings? _globalSettings;
  List<TaxModel> _taxes = [];

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoaded => _isLoaded;
  bool get isTaxLoading => _isTaxLoading;
  bool get isTaxLoaded => _isTaxLoaded;
  GlobalSettings? get globalSettings => _globalSettings;
  List<PromoCode> get promoCodes => _globalSettings?.promoCodes ?? [];
  List<TaxModel> get taxes => _taxes;
  List<TaxModel> get activeTaxes => _taxes.where((t) => t.isActive).toList();

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
      if (!e.toString().contains('permission-denied')) {
        Fluttertoast.showToast(msg: "Failed to load global promo data");
      }
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

  // -------------------------TAX MANAGEMENT-------------------------

  /// Fetch all taxes from Firestore
  Future<void> fetchTaxes() async {
    if (_isTaxLoaded) return;

    _isTaxLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('taxes')
          .orderBy('createdAt', descending: false)
          .get();

      _taxes =
          snapshot.docs.map((doc) => TaxModel.fromMap(doc.data())).toList();

      _isTaxLoaded = true;
    } catch (e, stack) {
      debugPrint('🔥 Error fetching taxes: $e');
      debugPrint('$stack');
      if (!e.toString().contains('permission-denied')) {
        Fluttertoast.showToast(msg: "Failed to load taxes");
      }
    } finally {
      _isTaxLoading = false;
      notifyListeners();
    }
  }

  /// Add a new tax
  Future<void> addTax({
    required String name,
    String? description,
    required double rate,
    required TaxType type,
    String? applicableRegion,
    int priority = 0,
    bool isDefault = false,
  }) async {
    _isTaxLoading = true;
    notifyListeners();

    try {
      final docRef = _firestore.collection('taxes').doc();
      final now = Timestamp.now();

      final newTax = TaxModel(
        id: docRef.id,
        name: name.trim(),
        description: description?.trim(),
        rate: rate,
        type: type,
        applicableRegion: applicableRegion?.trim(),
        isDefault: isDefault,
        isActive: true,
        createdAt: now,
      );

      await docRef.set(newTax.toMap());

      _taxes.add(newTax);

      Fluttertoast.showToast(msg: "Tax added successfully");
    } catch (e, stack) {
      debugPrint('🔥 Error adding tax: $e');
      debugPrint('$stack');
      Fluttertoast.showToast(msg: "Failed to add tax");
    } finally {
      _isTaxLoading = false;
      notifyListeners();
    }
  }

  /// Update an existing tax
  Future<void> updateTax({
    required String id,
    String? name,
    String? description,
    double? rate,
    TaxType? type,
    String? applicableRegion,
    int? priority,
    bool? isDefault,
    bool? isActive,
  }) async {
    _isTaxLoading = true;
    notifyListeners();

    try {
      final index = _taxes.indexWhere((t) => t.id == id);
      if (index == -1) throw Exception('Tax not found');

      final updatedTax = _taxes[index].copyWith(
        name: name,
        description: description,
        rate: rate,
        type: type,
        applicableRegion: applicableRegion,
        isDefault: isDefault,
        isActive: isActive,
        updatedAt: Timestamp.now(),
      );

      await _firestore.collection('taxes').doc(id).update(updatedTax.toMap());

      _taxes[index] = updatedTax;

      Fluttertoast.showToast(msg: "Tax updated successfully");
    } catch (e, stack) {
      debugPrint('🔥 Error updating tax: $e');
      debugPrint('$stack');
      Fluttertoast.showToast(msg: "Failed to update tax");
    } finally {
      _isTaxLoading = false;
      notifyListeners();
    }
  }

  /// Toggle tax active status
  Future<void> toggleTaxStatus(String id) async {
    try {
      final index = _taxes.indexWhere((t) => t.id == id);
      if (index == -1) return;

      final updatedTax = _taxes[index].copyWith(
        isActive: !_taxes[index].isActive,
        updatedAt: Timestamp.now(),
      );

      await _firestore.collection('taxes').doc(id).update({
        'isActive': updatedTax.isActive,
        'updatedAt': updatedTax.updatedAt,
      });

      _taxes[index] = updatedTax;
      notifyListeners();

      Fluttertoast.showToast(
        msg: updatedTax.isActive ? "Tax activated" : "Tax deactivated",
      );
    } catch (e, stack) {
      debugPrint('🔥 Error toggling tax status: $e');
      debugPrint('$stack');
      Fluttertoast.showToast(msg: "Failed to update tax status");
    }
  }

  /// Delete a tax
  Future<void> deleteTax(String id) async {
    _isTaxLoading = true;
    notifyListeners();

    try {
      await _firestore.collection('taxes').doc(id).delete();
      _taxes.removeWhere((t) => t.id == id);

      Fluttertoast.showToast(msg: "Tax deleted successfully");
    } catch (e, stack) {
      debugPrint('🔥 Error deleting tax: $e');
      debugPrint('$stack');
      Fluttertoast.showToast(msg: "Failed to delete tax");
    } finally {
      _isTaxLoading = false;
      notifyListeners();
    }
  }

  /// Clear all taxes
  Future<void> clearAllTaxes() async {
    _isTaxLoading = true;
    notifyListeners();

    try {
      final batch = _firestore.batch();
      for (final tax in _taxes) {
        batch.delete(_firestore.collection('taxes').doc(tax.id));
      }
      await batch.commit();

      _taxes.clear();

      Fluttertoast.showToast(msg: "All taxes cleared");
    } catch (e, stack) {
      debugPrint('🔥 Error clearing taxes: $e');
      debugPrint('$stack');
      Fluttertoast.showToast(msg: "Failed to clear taxes");
    } finally {
      _isTaxLoading = false;
      notifyListeners();
    }
  }

  /// Calculate total tax amount for a subtotal
  double calculateTotalTax(double subtotal) {
    return activeTaxes.fold(
        0.0, (sum, tax) => sum + tax.calculateTax(subtotal));
  }

  void singleProductPromocode({required PromoCode promo}) {
    try {} catch (e) {}
  }
}
