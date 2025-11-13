import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/presentation/models/category_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class CategorymanagementProvider extends ChangeNotifier {
  FirebaseFirestore _db = FirebaseFirestore.instance;
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  bool _isLoadingScreen = false;

  List<CategoryModel> get categories => _categories;
  bool get isloading => _isLoading;
  bool get isloadingScreen => _isLoadingScreen;

  Future<void> fetchCategory() async {
    try {
      _isLoadingScreen = true;
      notifyListeners();
      final snapshot = await _db.collection('categories').get();
      _categories =
          snapshot.docs.map((e) => CategoryModel.fromMap(e.data())).toList();
    } catch (e, s) {
      log("[Admin Category] Error $e");
      log("[Admin Category] Error Stack $s");
    } finally {
      _isLoadingScreen = false;
      notifyListeners();
    }
  }

  Future<void> editCategory(CategoryModel updatedCategory) async {
    try {
      _isLoading = true;
      notifyListeners();

      // 🔹 Update in Firestore
      await _db
          .collection('categories')
          .doc(updatedCategory.id)
          .update(updatedCategory.toMap());

      // 🔹 Update locally in _categories list
      final index = _categories.indexWhere((c) => c.id == updatedCategory.id);
      if (index != -1) {
        _categories[index] = updatedCategory;
      }

      log("[Admin Category] [edit] Updated category locally and remotely.");
    } catch (e, s) {
      log("[Admin Category] [edit] Error: $e");
      log("[Admin Category] [edit] Stack: $s");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createCategory(CategoryModel category) async {
    try {
      _isLoading = true;
      notifyListeners();
      final docRef = _db.collection('categories').doc();

      final Finalcategory = CategoryModel(
          id: docRef.id,
          name: category.name,
          imageUrl: category.imageUrl,
          createdAt: Timestamp.now());

      await docRef.set(Finalcategory.toMap());
      _categories.add(Finalcategory);
      notifyListeners();
    } catch (e, s) {
      log("[Admin Category] [category] Error $e");
      log("[Admin Category] [category] Error Stack $s");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _db.collection('categories').doc(id).delete();
    } catch (e, s) {
      log("[Admin Category] [fetch] Error $e");
      log("[Admin Category] [fetch] Error Stack $s");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
