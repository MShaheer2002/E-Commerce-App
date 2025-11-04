import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class SingleProductProvider extends ChangeNotifier {
  int _quantity = 1;
  int _currentImageIndex = 0;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _userId;

  String get userId => _userId ?? '';

  int get quantity => _quantity;
  int get currentImageIndex => _currentImageIndex;

  SingleProductProvider() {
    _userId = _auth.currentUser?.uid;
  }

  void increaseQuantity() {
    _quantity++;
    notifyListeners();
  }

  void decreaseQuantity() {
    if (_quantity > 1) {
      _quantity--;
      notifyListeners();
    }
  }

  void setImageIndex(int index) {
    _currentImageIndex = index;
    notifyListeners();
  }
}
