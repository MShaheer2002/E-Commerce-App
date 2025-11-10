import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/core/providers/product_analytics_provider.dart';
import 'package:e_commerce_app/presentation/models/category_model.dart';
import 'package:e_commerce_app/presentation/models/product_model.dart';
import 'package:flutter/material.dart';

class ProductmanagementProvider with ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;

  List<ProductModel> _products = [];
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  bool _isMoreLoading = false;
  bool _hasMore = true;
  final ProductAnalyticsProvider _analyticsProvider;

  DocumentSnapshot? _lastDocument;

  static const int _limit = 10; // Number of items per page

  List<ProductModel> get products => _products;
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  bool get isMoreLoading => _isMoreLoading;
  bool get hasMore => _hasMore;

  ProductmanagementProvider(this._analyticsProvider) {
    fetchCategories();
    fetchProducts(initialLoad: true);
  }

  /// 🔄 Fetch products (with pagination)
  Future<void> fetchProducts({bool initialLoad = false}) async {
    // --- Reset state on refresh ---
    if (initialLoad) {
      _isLoading = true;
      _products.clear();
      _lastDocument = null;
      _hasMore = true;
      notifyListeners();
    } else {
      if (!_hasMore || _isMoreLoading) return;
      _isMoreLoading = true;
      notifyListeners();
    }

    try {
      Query query = _firestore
          .collection('products')
          .orderBy('createdAt', descending: true)
          .limit(_limit);

      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;

        final newProducts = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return ProductModel.fromMap(data);
        }).toList();

        if (initialLoad) {
          _products = newProducts;
        } else {
          _products.addAll(newProducts);
        }
      }

      // If fewer items than limit → no more data
      if (snapshot.docs.length < _limit) _hasMore = false;
    } catch (e) {
      log("Error fetching products: $e");
    } finally {
      _isLoading = false;
      _isMoreLoading = false;
      notifyListeners();
    }
  }

  // 📦 Fetch all categories
  Future<void> fetchCategories() async {
    try {
      final snapshot = await _firestore.collection('categories').get();
      _categories = snapshot.docs
          .map((doc) => CategoryModel.fromMap(doc.data()))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching categories: $e");
    }
  }

  // ➕ Add product
  Future<void> addProduct(ProductModel product) async {
    try {
      final docRef =
          await _firestore.collection('products').add(product.toMap());

      // ✅ Add product ID to Firestore document
      await _firestore.collection('products').doc(docRef.id).update({
        'id': docRef.id,
      });

      await fetchProducts(initialLoad: true);
    } catch (e) {
      debugPrint("Error adding product: $e");
    }
  }

  // ✏️ Update product
  Future<void> updateProduct(String id, ProductModel updatedProduct) async {
    try {
      await _firestore
          .collection('products')
          .doc(id)
          .update(updatedProduct.toMap());
      await fetchProducts(initialLoad: true);
    } catch (e) {
      debugPrint("Error updating product: $e");
    }
  }

  // ❌ Delete product
  Future<void> deleteProduct(String id) async {
    try {
      await _firestore.collection('products').doc(id).delete();
      _products.removeWhere((product) => product.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint("Error deleting product: $e");
    }
  }

  // 🔍 Get Category name by ID
  String getCategoryName(String categoryId) {
    final category = _categories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => CategoryModel(
        id: '',
        name: 'Unknown',
        imageUrl: '',
        createdAt: Timestamp.now(),
      ),
    );
    return category.name;
  }

  // Add New Product (moved from screen)
  Future<void> addNewProduct({
    required String name,
    required String description,
    required double price,
    required String categoryId,
    required double retailPrice,
    required int stock,
    required String? productLink,
    required List<String> imageUrls,
  }) async {
    try {
      final docRef = _firestore.collection('products').doc();
      // Create product with the ID included
      final product = ProductModel(
        id: docRef.id,
        productLink: productLink,
        isSoldout: false,
        retailPrice: retailPrice,
        name: name,
        description: description,
        price: price,
        categoryId: categoryId,
        imageUrls: imageUrls,
        stock: stock,
        createdAt: Timestamp.now(),
      );

      // Save to Firestore
      await docRef.set(product.toMap());
      // Refresh product list after adding
      await fetchProducts(initialLoad: true);

      final productId = docRef.id;
      await _analyticsProvider.createAnalyticsForNewProduct(productId);
    } catch (e) {
      debugPrint("Error adding new product: $e");
    }
  }
}
