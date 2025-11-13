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
  final List<ProductModel> _favoriteProducts = [];

  bool get isloading => _isLoading;
  bool get isLoaded => _isLoaded;
  Set<String> get favoriteProductIds => _favoriteProductIds;
  List<ProductModel> get favoriteProducts =>
      List.unmodifiable(_favoriteProducts);

  bool isFavorite(String productId) => _favoriteProductIds.contains(productId);

  // ---------------------------------------------------------------------------
  // ✅ Load favorite product IDs (for current user)
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

  // ---------------------------------------------------------------------------
  // ✅ Toggle favorite status (Firestore + local state)
  Future<void> toggleFavorite(String productId) async {
    await _authGuard.ensureUserAuthenticated();
    final userId = _authGuard.userId!;
    final isCurrentlyFav = _favoriteProductIds.contains(productId);

    // Optimistic UI update
    if (isCurrentlyFav) {
      _favoriteProductIds.remove(productId);
      _favoriteProducts.removeWhere((p) => p.id == productId);
    } else {
      _favoriteProductIds.add(productId);
    }
    notifyListeners();

    try {
      final favoritesRef = _firestore.collection('favorites');
      if (isCurrentlyFav) {
        // Remove favorite
        final existing = await favoritesRef
            .where('userId', isEqualTo: userId)
            .where('productId', isEqualTo: productId)
            .limit(1)
            .get();

        if (existing.docs.isNotEmpty) {
          await favoritesRef.doc(existing.docs.first.id).delete();
        }
      } else {
        // Add favorite
        final docRef = favoritesRef.doc();
        await docRef.set({
          'id': docRef.id,
          'userId': userId,
          'productId': productId,
          'addedAt': Timestamp.now(),
        });
        unawaited(_analyticsProvider.incrementAddToFav(productId));

        // Optional: add fetched product locally
        final prodDoc =
            await _firestore.collection('products').doc(productId).get();
        if (prodDoc.exists) {
          _favoriteProducts.add(ProductModel.fromMap(prodDoc.data()!));
        }
      }
      notifyListeners();
    } catch (e, stack) {
      // Revert if failed
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

  // ---------------------------------------------------------------------------
  // ✅ Fetch favorite products from Firestore
  Future<List<ProductModel>> fetchFavoriteProducts({
    DocumentSnapshot? lastDoc,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authGuard.ensureUserAuthenticated();
      final userId = _authGuard.userId!;

      // Get favorite product IDs
      final favSnapshot = await _firestore
          .collection('favorites')
          .where('userId', isEqualTo: userId)
          .get();

      if (favSnapshot.docs.isEmpty) {
        _favoriteProducts.clear();
        _isLoading = false;
        notifyListeners();
        return [];
      }

      final productIds =
          favSnapshot.docs.map((doc) => doc['productId'] as String).toList();

      final query =
          _firestore.collection('products').where('id', whereIn: productIds);

      final productSnapshot = await query.get();

      final products = productSnapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data()))
          .toList();

      _favoriteProducts
        ..clear()
        ..addAll(products);

      _isLoading = false;
      _isLoaded = true;
      notifyListeners();

      return _favoriteProducts;
    } catch (e, stack) {
      debugPrint('🔥 Error fetching favorite products: $e');
      debugPrint('$stack');
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  // ---------------------------------------------------------------------------
  // ✅ Public method to load (if not loaded)
  Future<void> loadFavoriteProducts({bool isRefresh = false}) async {
    if (_isLoaded && !isRefresh && _favoriteProducts.isNotEmpty) return;
    await fetchFavoriteProducts();
  }

  // ---------------------------------------------------------------------------
  // ✅ Manual refresh (for pull-to-refresh)
  Future<void> refreshFavorites() async {
    await fetchFavoriteProducts();
  }

  // ---------------------------------------------------------------------------
  // ✅ Helper: clear cache if user logs out
  void clearFavorites() {
    _favoriteProductIds.clear();
    _favoriteProducts.clear();
    _isLoaded = false;
    _isLoading = false;
    notifyListeners();
  }
}
