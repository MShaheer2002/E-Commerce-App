import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../presentation/models/product_model.dart';

class CategoryProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool isloading = false;
  final int _limit = 10;
  bool _isLoadingMore = false;
  bool hasMore = false;
  DocumentSnapshot? _lastDocument;

  List<ProductModel> _productsByCategory = [];
  List<ProductModel> get productsByCategory => _productsByCategory;

  /// Optimized fetch with caching & minimal reads
  Future<void> fetchProductsByCategory(
      {required String categoryId, bool isInitalFetch = false}) async {
    if (_isLoadingMore || (isInitalFetch && isloading)) return;
    if (isInitalFetch) {
      isloading = true;
      _productsByCategory.clear();
      hasMore = true;
      _lastDocument = null;
      notifyListeners();
    } else {
      if (!hasMore) return;
      _isLoadingMore = true;
    }
    try {
      Query querySnapshot = _db
          .collection('products')
          .where('categoryId', isEqualTo: categoryId)
          .orderBy('createdAt', descending: true)
          .limit(_limit);

      if (_lastDocument != null) {
        querySnapshot = querySnapshot.startAfterDocument(_lastDocument!);
      }

      final snapshot = await querySnapshot.get();

      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;

        final newProducts = snapshot.docs.map((docs) {
          final data = docs.data() as Map<String, dynamic>;
          return ProductModel.fromMap(data);
        }).toList();

        if (isInitalFetch) {
          _productsByCategory = newProducts;
        } else {
          for (var prod in newProducts) {
            if (!(_productsByCategory.any(
              (element) => element.id == prod.id,
            ))) {
              _productsByCategory.add(prod);
            }
          }
        }

        if (snapshot.docs.length < _limit) {
          hasMore = false;
        }
      } else {
        if (isInitalFetch) {
          _productsByCategory = [];
        }
        hasMore = false;
      }
    } catch (e, s) {
      log('Error fetching products by category: $e');
      if (isInitalFetch) {
        _productsByCategory = [];
      }
    } finally {
      isloading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
    // try {
    //   isloading = true;
    //   notifyListeners();
    //   debugPrint('Fetching products for $categoryId from Firestore 🔥');

    //   final querySnapshot = await _db
    //       .collection('products')
    //       .where('categoryId', isEqualTo: categoryId)
    //       .orderBy('createdAt', descending: true)
    //       .get();

    //   final products = querySnapshot.docs.map((doc) {
    //     final data = doc.data();
    //     return ProductModel.fromMap(data);
    //   }).toList();
    //   _productsByCategory = products;
    //   isloading = false;

    //   notifyListeners();
    // } catch (e) {
    //   debugPrint('❌ Error fetching products by category: $e');
    //   _productsByCategory = [];
    //   isloading = false;
    //   notifyListeners();
    // }
  }
}
