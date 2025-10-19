import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../presentation/models/product_model.dart';

class SearchProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<ProductModel> _results = [];
  List<ProductModel> get results => _results;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Called whenever the user types a new search query
  Future<void> searchProducts(String query) async {
    if (query.trim().isEmpty) {
      _results = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('products')
          .orderBy('name')
          .startAt([query]).endAt(['${query}\uf8ff']).get();

      _results =
          snapshot.docs.map((doc) => ProductModel.fromMap(doc.data())).toList();
    } catch (e) {
      debugPrint("Search error: $e");
      _results = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearResults() {
    _results = [];
    notifyListeners();
  }
}
