import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RealtimeDatabaseService {
  static final Map<String, Timer> _pollingTimers = {};
  static final Map<String, Function> _callbacks = {};

  // For listening to shop list changes
  static void listenToShopList({
    required String collegeName,
    required Function(List<Map<String, dynamic>>) onData,
  }) {
    final path = 'AdminDatabase/${Uri.encodeComponent(collegeName)}/Shops';
    _cancelExistingTimer(path);

    _callbacks[path] = onData;

    // Implement polling with a reasonable interval (5 seconds)
    _pollingTimers[path] = Timer.periodic(Duration(seconds: 5), (_) async {

      try {
        final url = Uri.parse(
          'https://saapadu-groups-default-rtdb.asia-southeast1.firebasedatabase.app/$path.json?shallow=true');

        final response = await http.get(url).timeout(Duration(seconds: 10));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>?;
          if (data != null) {
            // Now fetch full data for each shop that exists
            final shops = <Map<String, dynamic>>[];

            for (final shopEntry in data.entries) {
              if (shopEntry.value == true) { // Only for existing shops
                final shopUrl = Uri.parse(
                    'https://saapadu-groups-default-rtdb.asia-southeast1.firebasedatabase.app/$path/${Uri.encodeComponent(shopEntry.key)}.json');

                final shopResponse = await http.get(shopUrl).timeout(Duration(seconds: 10));

                if (shopResponse.statusCode == 200) {
                  final shopData = jsonDecode(shopResponse.body);
                  if (shopData != null) {
                    shops.add({
                      'name': shopEntry.key,
                      'password': shopData['password'] ?? '',
                    });
                  }
                }
              }
            }

            if (_callbacks[path] != null) {
              _callbacks[path]!(shops);
            }
          }
        }
      } catch (e) {
        print('Error fetching shop list: $e');
      }
    });
  }


  // For listening to shop data changes (categories and items)
  static void listenToShopData({
    required String collegeName,
    required String shopName,
    required Function(Map<String, dynamic>) onData,
  }) {
    final path = 'AdminDatabase/${Uri.encodeComponent(collegeName)}/Shops/${Uri.encodeComponent(shopName)}/Categories';
    _cancelExistingTimer(path);

    // Implement polling with a reasonable interval (5 seconds)
    _pollingTimers[path] = Timer.periodic(Duration(seconds: 5), (_) async {
      final url = Uri.parse(
          'https://saapadu-groups-default-rtdb.asia-southeast1.firebasedatabase.app/$path.json');

      try {
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data != null) {
            onData(Map<String, dynamic>.from(data));
          }
        }
      } catch (e) {
        print('Error fetching shop data: $e');
      }
    });
  }

  // For listening to quantity changes
  static void listenToQuantity({
    required String collegeName,
    required String shopName,
    required String categoryName,
    required String foodName,
    required Function(int) onData,
  }) {
    final path = 'AdminDatabase/${Uri.encodeComponent(collegeName)}/Shops/${Uri.encodeComponent(shopName)}/Categories/${Uri.encodeComponent(categoryName)}/${Uri.encodeComponent(foodName)}/quantity';
    _cancelExistingTimer(path);

    // Implement polling with a reasonable interval (5 seconds)
    _pollingTimers[path] = Timer.periodic(Duration(seconds: 5), (_) async {
      final url = Uri.parse(
          'https://saapadu-groups-default-rtdb.asia-southeast1.firebasedatabase.app/$path.json');

      try {
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data != null) {
            onData(data is int ? data : int.tryParse(data.toString()) ?? 0);
          }
        }
      } catch (e) {
        print('Error fetching quantity: $e');
      }
    });
  }

  static Future<void> updateQuantity({
    required String collegeName,
    required String shopName,
    required String categoryName,
    required String foodName,
    required int newQuantity,
  }) async {
    final url = Uri.parse(
        'https://saapadu-groups-default-rtdb.asia-southeast1.firebasedatabase.app/AdminDatabase/${Uri.encodeComponent(collegeName)}/Shops/${Uri.encodeComponent(shopName)}/Categories/${Uri.encodeComponent(categoryName)}/${Uri.encodeComponent(foodName)}/quantity.json');

    try {
      await http.put(url, body: jsonEncode(newQuantity));
    } catch (e) {
      print('Error updating quantity: $e');
    }
  }

  static Future<void> addShop({
    required String collegeName,
    required String shopName,
    required String password,
  }) async {
    final url = Uri.parse(
        'https://saapadu-groups-default-rtdb.asia-southeast1.firebasedatabase.app/AdminDatabase/${Uri.encodeComponent(collegeName)}/Shops/${Uri.encodeComponent(shopName)}.json');

    try {
      await http.put(url, body: jsonEncode({"password": password}));
    } catch (e) {
      print('Error adding shop: $e');
    }
  }

  static void _cancelExistingTimer(String path) {
    _pollingTimers[path]?.cancel();
    _pollingTimers.remove(path);
    _callbacks.remove(path);
  }

  static void cancelListener(String path) {
    _cancelExistingTimer(path);
  }

  static void cancelAllListeners() {
    _pollingTimers.values.forEach((timer) => timer.cancel());
    _pollingTimers.clear();
    _callbacks.clear();
  }
}