import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/presentation/models/cartItem_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  final Map<String, CartItemModel> _items = {};
  String? _userId;
  bool _isLoading = false;

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

    // Local save
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(
      _items.map((key, item) => MapEntry(key, item.toMap())),
    );
    await prefs.setString('cartItems_${_userId!}', encoded);
    try {
      // Firestore sync (✅ merged to avoid overwriting)
      await _firestore.collection('carts').doc(_userId).set({
        'items': _items.map((key, value) => MapEntry(key, value.toMap())),
        'total': totalAmount,
        'updatedAt': Timestamp.now(),
      }, SetOptions(merge: true));
    } catch (e) {
      log("[Cart error] $e");
    }
  }

  void addToCart(CartItemModel item) {
    final productId = item.product.id!; // ✅ product id inside ProductModel

    if (_items.containsKey(productId)) {
      final existingItem = _items[productId]!;

      // create new item with updated quantity
      _items[productId] = CartItemModel(
        id: existingItem.id,
        product: existingItem.product,
        userId: existingItem.userId,
        quantity: existingItem.quantity + item.quantity,
        priceAtPurchase: existingItem.priceAtPurchase,
        addedAt: existingItem.addedAt,
      );
    } else {
      _items[productId] = item;
    }

    _saveCart();
    notifyListeners();
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
