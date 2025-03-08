import 'package:flutter/material.dart';

class CartModel with ChangeNotifier {
  final Map<String, int> _items = {};

  int getQuantity(String item) => _items[item] ?? 0;

  void updateQuantity(String item, int quantity) {
    _items[item] = quantity;
    notifyListeners();
  }
}
