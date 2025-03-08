import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
class Stock {
  final Map<String, dynamic> foodItem;
  final String categoryName;
  final String collegeName;
  final String shopName;
  int quantity;
  late DatabaseReference _databaseRef;
  StreamSubscription<DatabaseEvent>? _streamSubscription;

  Stock({
    required this.foodItem,
    required this.categoryName,
    required this.quantity,
    required this.collegeName,
    required this.shopName,
  }) {
    _databaseRef = FirebaseDatabase.instance.ref();
    _activateListeners();
  }

  void _activateListeners() {
    _streamSubscription?.cancel();
    _streamSubscription = _databaseRef
        .child(
        'AdminDatabase/$collegeName/Shops/$shopName/Categories/$categoryName/${foodItem['name']}/quantity')
        .onValue
        .listen((event) {
      if (event.snapshot.exists) {
        quantity = (event.snapshot.value as int?) ?? 0;
      }
    });
  }

  void updateStock() {
    int newQuantity = quantity == 0 ? 1 : 0;
    _databaseRef
        .child(
        'AdminDatabase/$collegeName/Shops/$shopName/Categories/$categoryName/${foodItem['name']}/quantity')
        .set(newQuantity)
        .then((_) {
      quantity = newQuantity;
    })
        .catchError((error) {
      print("Failed to update stock: $error");
    });
  }

  void dispose() {
    _streamSubscription?.cancel();
  }
}