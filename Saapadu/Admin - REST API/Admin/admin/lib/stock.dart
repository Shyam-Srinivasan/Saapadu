import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'RealtimeDatabaseConnection.dart';

class Stock {
  final Map<String, dynamic> foodItem;
  final String categoryName;
  final String collegeName;
  final String shopName;
  int quantity;
  Timer? _pollingTimer;

  // Your database URL
  static const String baseUrl = 'https://saapadu-groups-default-rtdb.asia-southeast1.firebasedatabase.app';

  Stock({
    required this.foodItem,
    required this.categoryName,
    required this.quantity,
    required this.collegeName,
    required this.shopName,
  }) {
    _setupRealtimeListener();
  }

  /// Returns the full URL to the quantity node
  String get quantityUrl {
    final encodedCollege = Uri.encodeComponent(collegeName);
    final encodedShop = Uri.encodeComponent(shopName);
    final encodedCategory = Uri.encodeComponent(categoryName);
    final encodedFood = Uri.encodeComponent(foodItem['name']);
    return '$baseUrl/AdminDatabase/$encodedCollege/Shops/$encodedShop/Categories/$encodedCategory/$encodedFood/quantity.json';
  }

  /// Start polling every 5 seconds to get the latest quantity
// In Stock class, change to a more reasonable interval
  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(Duration(seconds: 5), (_) {
      fetchQuantity();
    });
  }
  void _setupRealtimeListener() {
    RealtimeDatabaseService.listenToQuantity(
      collegeName: collegeName,
      shopName: shopName,
      categoryName: categoryName,
      foodName: foodItem['name'],
      onData: (newQuantity) {
        quantity = newQuantity;
      },
    );
  }
  /// Fetch current quantity from Firebase
  Future<void> fetchQuantity() async {
    try {
      final response = await http.get(Uri.parse(quantityUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null) {
          quantity = data is int ? data : int.tryParse(data.toString()) ?? 0;
        }
      } else {
        // print('Failed to fetch quantity. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching quantity: $e');
    }
  }

  /// Toggle quantity between 0 and 1 and update Firebase
  ///
  // Old code
  /*


  Future<void> updateStock() async {
    try {
      final newQuantity = quantity == 0 ? 1 : 0;
      final response = await http.put(
        Uri.parse(quantityUrl),
        body: jsonEncode(newQuantity),
      );
      if (response.statusCode == 200) {
        quantity = newQuantity;
        // print('Stock updated to $quantity');
      } else {
        // print('Failed to update stock. Status: ${response.statusCode}');
      }
    } catch (e) {
      // print('Error updating stock: $e');
    }
  }
   */

  Future<void> updateStock() async {
    final newQuantity = quantity == 0 ? 1 : 0;
    await RealtimeDatabaseService.updateQuantity(
      collegeName: collegeName,
      shopName: shopName,
      categoryName: categoryName,
      foodName: foodItem['name'],
      newQuantity: newQuantity,
    );
  }

  /// Stop polling when no longer needed
  void dispose() {
    _pollingTimer?.cancel();
  }
}
