import 'package:flutter/foundation.dart';

class SingleProductProvider extends ChangeNotifier {
  int _quantity = 1;
  int _currentImageIndex = 0;

  int get quantity => _quantity;
  int get currentImageIndex => _currentImageIndex;

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
