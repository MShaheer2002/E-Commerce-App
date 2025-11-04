import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/core/providers/product_analytics_provider.dart';
import 'package:e_commerce_app/presentation/models/cartItem_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Map<String, CartItemModel> _items = {};
  String? _userId;
  bool _isLoading = false;
  final ProductAnalyticsProvider _analyticsProvider;

  CartProvider(this._analyticsProvider);

  String get userId => _userId ?? '';
  bool get isLoading => _isLoading;
  Map<String, CartItemModel> get items => {..._items};

  double get totalAmount => _items.values
      .fold(0, (sum, item) => sum + (item.quantity * item.product.price));

  void setUser() {
    // _userId = userId;
    _userId = _auth.currentUser?.uid;
    if (_userId != null) {
      loadCart();
    } else {
      clearCart();
    }
  }

  List<CartItemModel> _selectedItems = [];
  List<CartItemModel> get selectedItems => _selectedItems;

  void setSelectedItems(List<CartItemModel> items) {
    _selectedItems = items;
    notifyListeners();
  }

  void clearSelectedItems() {
    _selectedItems.clear();
    notifyListeners();
  }

  Future<void> loadCart() async {
    if (_userId == null) return;
    _isLoading = true;
    notifyListeners();

    // Try Firestore first
    final doc = await _firestore.collection('carts').doc(_userId).get();
    if (doc.exists) {
      final data = doc.data()!;
      final cartItems = Map<String, dynamic>.from(data['items']);
      _items.clear();
      cartItems.forEach((key, value) {
        _items[key] = CartItemModel.fromMap(value);
      });
    } else {
      // Load from SharedPreferences fallback
      final prefs = await SharedPreferences.getInstance();
      final cartData = prefs.getString('cartItems_${_userId!}');
      if (cartData != null) {
        final decoded = json.decode(cartData) as Map<String, dynamic>;
        decoded.forEach((key, value) {
          _items[key] = CartItemModel.fromMap(value);
        });
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveCart() async {
    if (_userId == null) return;

    final prefs = await SharedPreferences.getInstance();

    // ✅ Convert to JSON-safe map
    final jsonSafeItems = _items.map((key, item) {
      final itemMap = item.toMap();
      return MapEntry(key, _convertTimestamps(itemMap));
    });

    final encoded = json.encode(jsonSafeItems);

    await prefs.setString('cartItems_${_userId!}', encoded);

    try {
      await _firestore.collection('carts').doc(_userId).set({
        'items': _items.map((key, value) => MapEntry(key, value.toMap())),
        'total': totalAmount,
        'updatedAt': Timestamp.now(),
      }, SetOptions(merge: true));
    } catch (e) {
      log("[Cart error] $e");
    }
  }

// 🔧 Helper function to recursively handle Timestamp → String
  dynamic _convertTimestamps(dynamic value) {
    if (value is Timestamp) {
      return value.toDate().toIso8601String();
    } else if (value is Map) {
      return value.map((k, v) => MapEntry(k, _convertTimestamps(v)));
    } else if (value is List) {
      return value.map((e) => _convertTimestamps(e)).toList();
    } else {
      return value;
    }
  }

  void addToCart(CartItemModel item) {
    final productId = item.product.id!; // ✅ product id inside ProductModel

    if (_items.containsKey(productId)) {
      final existingItem = _items[productId]!;
      final qnt = existingItem.quantity + item.quantity;
      log("[Cart] quantity $qnt");
      // create new item with updated quantity
      _items[productId] = CartItemModel(
        id: existingItem.id,
        product: existingItem.product,
        userId: existingItem.userId,
        quantity: qnt,
        priceAtPurchase: existingItem.priceAtPurchase,
        addedAt: existingItem.addedAt,
      );
    } else {
      _items[productId] = item;
    }

    _saveCart();
    notifyListeners();

    unawaited(_analyticsProvider.incrementAddToCart(productId));
  }

  void removeFromCart(String productId) {
    _items.remove(productId);
    _saveCart();
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    if (_userId != null) _saveCart();
    notifyListeners();
  }

  void increaseQuantity(String productId) {
    if (_items.containsKey(productId)) {
      _items[productId]?.quantity++;
      _saveCart();
      notifyListeners();
    }
  }

  void decreaseQuantity(String productId) {
    if (_items.containsKey(productId)) {
      if (_items[productId]!.quantity > 1) {
        _items[productId]!.quantity--;
      } else {
        _items.remove(productId);
      }
      _saveCart();
      notifyListeners();
    }
  }



}
