import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ProductPlug/presentation/models/category_model.dart';
import 'package:ProductPlug/presentation/models/product_model.dart';
import 'package:flutter/foundation.dart';

class ProductProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  int category = 0;
  int product = 0;

  List<ProductModel> _products = [];
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ProductModel> get products => _products;
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool _initialized = false;

  void init() {
    if (_initialized) return;
    listenToProducts();
    listenToCategory();
    _initialized = true;
  }

  /// 🔄 Fetch products (real-time stream)
  void listenToProducts() {
    _db
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _products =
          snapshot.docs.map((doc) => ProductModel.fromMap(doc.data())).toList();
      notifyListeners();
    }, onError: (error) {
      _errorMessage = error.toString();
      notifyListeners();
    });
  }

  /// 🔄 Fetch categories (real-time stream)
  Future<void> listenToCategory() async {
    try {
      final snapshot = await _db.collection('categories').get();
      _categories =
          snapshot.docs.map((e) => CategoryModel.fromMap(e.data())).toList();
    } catch (e, s) {
      log("[Category] error $e");
      log("[Category] stack $s");
    }
    // _db
    //     .collection('categories')
    //     .orderBy('createdAt', descending: true)
    //     .snapshots()
    //     .listen((snapshot) {
    //   _categories = snapshot.docs
    //       .map((doc) => CategoryModel.fromMap(doc.data()))
    //       .toList();
    //   notifyListeners();
    // }, onError: (error) {
    //   _errorMessage = error.toString();
    //   notifyListeners();
    // });
  }

  /// ➕ Add a product
  Future<String> addProduct(ProductModel product) async {
    try {
      _isLoading = true;
      notifyListeners();

      final ref = _db.collection('products').doc(); // auto ID
      final newProduct = product.copyWith(id: ref.id);
      await ref.set(newProduct.toMap());

      _isLoading = false;
      notifyListeners();

      return 'Product added successfully';
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      if (kDebugMode) {
        print('❌ Add product failed: $e');
      }
      return "Something went wrong";
    }
  }

  /// ✏️ Update product
  Future<void> updateProduct(ProductModel product) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _db.collection('products').doc(product.id).update(product.toMap());

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// 🗑️ Delete product
  Future<void> deleteProduct(String id) async {
    try {
      await _db.collection('products').doc(id).delete();
      _products.removeWhere((p) => p.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// 🔍 Get single product by ID
  ProductModel? getById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  // Future<String?> sampleProductAdd() async {
  //   final List<ProductModel> products = [
  //     // FRUITS
  //     ProductModel(
  //       name: 'Banana',
  //       description:
  //           'Sweet and ripe bananas, perfect for breakfast and snacks.',
  //       price: 40.0,
  //       discountPrice: 35.0,
  //       categoryId: 'fruits',
  //       imageUrls: [
  //         'https://img.freepik.com/free-vector/vector-ripe-yellow-banana-bunch-isolated-white-background_1284-45456.jpg?semt=ais_hybrid&w=740&q=80'
  //       ],
  //       stock: 50,
  //       isFeatured: true,
  //       createdAt: Timestamp.now(),
  //     ),
  //     ProductModel(
  //       name: 'Apple',
  //       description: 'Fresh and juicy red apples rich in fiber and nutrients.',
  //       price: 120.0,
  //       discountPrice: null,
  //       categoryId: 'fruits',
  //       imageUrls: [
  //         'https://img.freepik.com/premium-photo/close-up-apple-red-apple-fruit_106006-15.jpg'
  //       ],
  //       stock: 30,
  //       isFeatured: false,
  //       createdAt: Timestamp.now(),
  //     ),
  //     ProductModel(
  //       name: 'Orange',
  //       description: 'Tangy oranges full of Vitamin C and antioxidants.',
  //       price: 80.0,
  //       discountPrice: 70.0,
  //       categoryId: 'fruits',
  //       imageUrls: [
  //         'https://img.freepik.com/free-photo/fresh-orange-isolated-white-background_93675-131671.jpg'
  //       ],
  //       stock: 25,
  //       isFeatured: false,
  //       createdAt: Timestamp.now(),
  //     ),

  //     // VEGETABLES
  //     ProductModel(
  //       name: 'Potato',
  //       description: 'Farm-fresh potatoes ideal for cooking and frying.',
  //       price: 25.0,
  //       discountPrice: 22.0,
  //       categoryId: 'vegetables',
  //       imageUrls: [
  //         'https://img.freepik.com/free-photo/raw-potatoes-woven-wicker-basket-with-natural-rosemary-leaves-wooden-rustic-table_181624-47259.jpg'
  //       ],
  //       stock: 60,
  //       isFeatured: false,
  //       createdAt: Timestamp.now(),
  //     ),
  //     ProductModel(
  //       name: 'Tomato',
  //       description: 'Juicy and ripe tomatoes, perfect for sauces and salads.',
  //       price: 30.0,
  //       discountPrice: null,
  //       categoryId: 'vegetables',
  //       imageUrls: [
  //         'https://img.freepik.com/free-photo/fresh-red-tomatoes_2829-13449.jpg'
  //       ],
  //       stock: 40,
  //       isFeatured: false,
  //       createdAt: Timestamp.now(),
  //     ),

  //     // LEAFY GREENS
  //     ProductModel(
  //       name: 'Spinach',
  //       description: 'Fresh spinach leaves, rich in iron and vitamins.',
  //       price: 15.0,
  //       discountPrice: null,
  //       categoryId: 'leafy-greens',
  //       imageUrls: [
  //         'https://img.freepik.com/premium-photo/spinach-salad-leaves-white-backgrounds_183352-3193.jpg'
  //       ],
  //       stock: 20,
  //       isFeatured: false,
  //       createdAt: Timestamp.now(),
  //     ),
  //     ProductModel(
  //       name: 'Fenugreek (Methi)',
  //       description: 'Fresh fenugreek leaves, great for Indian dishes.',
  //       price: 10.0,
  //       discountPrice: null,
  //       categoryId: 'leafy-greens',
  //       imageUrls: [
  //         'https://img.freepik.com/premium-photo/fenugreek-seeds-bowl-with-leaves-isolated-white-background-from_423299-1442.jpg'
  //       ],
  //       stock: 15,
  //       isFeatured: false,
  //       createdAt: Timestamp.now(),
  //     ),

  //     // HERBS & SPICES
  //     ProductModel(
  //       name: 'Ginger',
  //       description: 'Aromatic ginger root, used for cooking and healing.',
  //       price: 20.0,
  //       discountPrice: null,
  //       categoryId: 'herbs-spices',
  //       imageUrls: [
  //         'https://img.freepik.com/premium-photo/ginger-white-background-depth-field_253984-2729.jpg'
  //       ],
  //       stock: 35,
  //       isFeatured: false,
  //       createdAt: Timestamp.now(),
  //     ),
  //     ProductModel(
  //       name: 'Garlic',
  //       description: 'Fresh garlic bulbs for everyday cooking.',
  //       price: 30.0,
  //       discountPrice: null,
  //       categoryId: 'herbs-spices',
  //       imageUrls: [
  //         'https://img.freepik.com/premium-photo/garlic-white-background_9555-721.jpg'
  //       ],
  //       stock: 30,
  //       isFeatured: false,
  //       createdAt: Timestamp.now(),
  //     ),

  //     // DAIRY & EGGS
  //     ProductModel(
  //       name: 'Milk (Full Cream)',
  //       description: 'Pure full-cream milk, rich in calcium and protein.',
  //       price: 60.0,
  //       discountPrice: 55.0,
  //       categoryId: 'dairy-eggs',
  //       imageUrls: [
  //         'https://img.freepik.com/free-vector/realistic-vector-icon-illustration-milk-jug-splash-fresh-milk-isolated-white-backgro_134830-2400.jpg'
  //       ],
  //       stock: 40,
  //       isFeatured: true,
  //       createdAt: Timestamp.now(),
  //     ),
  //     ProductModel(
  //       name: 'Eggs (Regular)',
  //       description: 'Farm-fresh eggs, high in protein and nutrition.',
  //       price: 40.0,
  //       discountPrice: null,
  //       categoryId: 'dairy-eggs',
  //       imageUrls: [
  //         'https://img.freepik.com/free-photo/three-fresh-organic-raw-eggs-isolated-white-surface_114579-43677.jpg'
  //       ],
  //       stock: 60,
  //       isFeatured: false,
  //       createdAt: Timestamp.now(),
  //     ),

  //     // BEVERAGES
  //     ProductModel(
  //       name: 'Orange Juice',
  //       description: 'Refreshing orange juice made from fresh oranges.',
  //       price: 50.0,
  //       discountPrice: 45.0,
  //       categoryId: 'beverages',
  //       imageUrls: [
  //         'https://img.freepik.com/free-vector/orange-juice_1284-825.jpg'
  //       ],
  //       stock: 20,
  //       isFeatured: true,
  //       createdAt: Timestamp.now(),
  //     ),
  //     ProductModel(
  //       name: 'Coconut Water',
  //       description: 'Naturally sweet and hydrating coconut water.',
  //       price: 30.0,
  //       discountPrice: null,
  //       categoryId: 'beverages',
  //       imageUrls: [
  //         'https://img.freepik.com/free-photo/bottle-coconut-water-put-dark-background_1150-28239.jpg'
  //       ],
  //       stock: 25,
  //       isFeatured: false,
  //       createdAt: Timestamp.now(),
  //     ),
  //   ];

  //   try {
  //     _isLoading = true;
  //     notifyListeners();

  //     // ✅ Create a new doc with auto-generated ID
  //     final ref = _db.collection('products').doc();

  //     await ref.set(products[product].toMap());

  //     _isLoading = false;

  //     product = product + 1;
  //     notifyListeners();

  //     return '✅ Sample product added successfully!';
  //   } catch (e) {
  //     _isLoading = false;
  //     _errorMessage = e.toString();
  //     notifyListeners();

  //     if (kDebugMode) {
  //       print('❌ Failed to add sample product: $e');
  //     }

  //     return null;
  //   }
  // }

  // Future<String> addCategories() async {
  //   final List<CategoryModel> categories = [
  //     CategoryModel(
  //       id: "fruits",
  //       name: 'Fruits',
  //       imageUrl:
  //           "https://img.freepik.com/free-photo/grapes-strawberries-pineapple-kiwi-apricot-banana-whole-pineapple_23-2147968680.jpg",
  //       createdAt: Timestamp.now(),
  //     ),
  //     CategoryModel(
  //       id: "vegetables",
  //       name: 'Vegetables',
  //       imageUrl:
  //           "https://img.freepik.com/premium-photo/vegetables-fruits-white_55883-1004.jpg",
  //       createdAt: Timestamp.now(),
  //     ),
  //     CategoryModel(
  //       id: "leafy-greens",
  //       name: 'Leafy Greens',
  //       imageUrl:
  //           "https://img.freepik.com/premium-photo/high-angle-view-green-vegetables-market_1048944-6183961.jpg?semt=ais_hybrid&w=740&q=80",
  //       createdAt: Timestamp.now(),
  //     ),
  //     CategoryModel(
  //       id: "herbs-spices",
  //       name: 'Herbs & Spices',
  //       imageUrl:
  //           "https://img.freepik.com/premium-photo/assortment-natural-spices-dark-rustic-stone-background-healthy-spice-concept_372197-3367.jpg",
  //       createdAt: Timestamp.now(),
  //     ),
  //     CategoryModel(
  //       id: "dairy-eggs",
  //       name: 'Dairy & Eggs',
  //       imageUrl:
  //           "https://img.freepik.com/premium-photo/tasty-dairy-products-with-bread-table-fabric-surface_392895-24332.jpg?semt=ais_hybrid&w=740&q=80",
  //       createdAt: Timestamp.now(),
  //     ),
  //     CategoryModel(
  //       id: "beverages",
  //       name: 'Beverages',
  //       imageUrl:
  //           "https://img.freepik.com/premium-photo/colorful-cocktails-with-fresh-fruits-herbs_1104203-61.jpg",
  //       createdAt: Timestamp.now(),
  //     ),
  //   ];

  //   final ref = _db.collection('categories').doc();

  //   await ref.set(categories[category].toMap());

  //   category = category + 1;
  //   notifyListeners();
  //   return "Succesful";
  // }
}
