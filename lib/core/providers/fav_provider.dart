import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/core/providers/handle_unautharized_access_provider.dart';
import 'package:e_commerce_app/core/providers/product_analytics_provider.dart';
import 'package:e_commerce_app/presentation/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FavoriteService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final HandleUnauthorizedAccessProvider _authGuard;
  final ProductAnalyticsProvider _analyticsProvider;
  FavoriteService(this._authGuard, this._analyticsProvider);

  bool _isLoaded = false;
  bool _isLoading = false;
  final Set<String> _favoriteProductIds = {};

  bool get isloading => _isLoading;
  bool get isLoaded => _isLoaded;
  Set<String> get favoriteProductIds => _favoriteProductIds;
  bool isFavorite(String productId) => _favoriteProductIds.contains(productId);

  bool isProductFavorite(String productId) {
    return _favoriteProductIds.contains(productId);
  }

  Future<void> loadFavoritesForUser() async {
    if (_isLoaded) return;

    try {
      await _authGuard.ensureUserAuthenticated();
      final userId = _authGuard.userId!;
      final querySnapshot = await _firestore
          .collection('favorites')
          .where('userId', isEqualTo: userId)
          .get();

      _favoriteProductIds
        ..clear()
        ..addAll(querySnapshot.docs.map((doc) => doc['productId'] as String));

      _isLoaded = true;
      notifyListeners();
    } catch (e, stack) {
      debugPrint('🔥 Error loading favorites: $e');
      debugPrint('$stack');
    }
  }

  Future<void> toggleFavorite(String productId) async {
    await _authGuard.ensureUserAuthenticated();
    final userId = _authGuard.userId!;

    final isCurrentlyFav = _favoriteProductIds.contains(productId);

    // ✅ STEP 1: Optimistic UI update
    if (isCurrentlyFav) {
      _favoriteProductIds.remove(productId);
    } else {
      _favoriteProductIds.add(productId);
    }
    notifyListeners(); // instantly update the UI

    try {
      final favoritesRef = _firestore.collection('favorites');

      if (isCurrentlyFav) {
        // Remove from Firestore
        final existing = await favoritesRef
            .where('userId', isEqualTo: userId)
            .where('productId', isEqualTo: productId)
            .limit(1)
            .get();

        if (existing.docs.isNotEmpty) {
          await favoritesRef.doc(existing.docs.first.id).delete();
        }
      } else {
        // Add to Firestore
        final docRef = favoritesRef.doc();
        await docRef.set({
          'id': docRef.id,
          'userId': userId,
          'productId': productId,
          'addedAt': Timestamp.now(),
        });
        unawaited(_analyticsProvider.incrementAddToFav(productId));
      }
    } catch (e, stack) {
      // STEP 2: Revert if Firestore call fails
      if (isCurrentlyFav) {
        _favoriteProductIds.add(productId);
      } else {
        _favoriteProductIds.remove(productId);
      }
      notifyListeners();

      debugPrint('Error toggling favorite: $e');
      debugPrint(stack.toString());

      Fluttertoast.showToast(
          msg: "Failed to update favorite. Please try again.");
    }
  }

  Future<List<ProductModel>> fetchFavoriteProducts({
    DocumentSnapshot? lastDoc,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _authGuard.ensureUserAuthenticated();
      final userId = _authGuard.userId!;

      // STEP 1 — Get favorite product IDs (for this user)
      final favSnapshot = await _firestore
          .collection('favorites')
          .where('userId', isEqualTo: userId)
          .get();

      if (favSnapshot.docs.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return [];
      }
      ;

      final productIds =
          favSnapshot.docs.map((doc) => doc['productId'] as String).toList();

      // STEP 2 — Limit product IDs for now (pagination-ready)
      final idsForPage = productIds.toList();

      // STEP 3 — Fetch matching products in one query (single whereIn)
      final query =
          _firestore.collection('products').where('id', whereIn: idsForPage);

      final productSnapshot = await query.get();

      _isLoading = false;
      notifyListeners();

      // STEP 4 — Return list of products
      return productSnapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data()))
          .toList();
    } catch (e, stack) {
      debugPrint('🔥 Error fetching favorite products: $e');
      debugPrint('$stack');
      return [];
    }
  }
}
