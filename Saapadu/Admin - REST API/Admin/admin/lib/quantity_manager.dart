import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QuantityManage extends StatefulWidget {
  final Map<String, dynamic> foodItem;
  final String categoryName;
  final String collegeName;
  final String shopName;

  const QuantityManage({
    super.key,
    required this.foodItem,
    required this.categoryName,
    required this.collegeName,
    required this.shopName,
  });

  @override
  _QuantityManageState createState() => _QuantityManageState();
}

class _QuantityManageState extends State<QuantityManage> {
  int quantity = 0;
  bool _isClicked = false;
  late StreamSubscription<int> _quantitySubscription;
  final String _baseUrl = 'https://saapadu-groups-default-rtdb.asia-southeast1.firebasedatabase.app';

  @override
  void initState() {
    super.initState();
    _setupRealtimeListener();
  }

  void _setupRealtimeListener() {
    // Start listening to quantity changes
    _quantitySubscription = _getQuantityStream().listen((newQuantity) {
      if (mounted) {
        setState(() {
          quantity = newQuantity;
          _isClicked = newQuantity > 0;
        });
      }
    });
  }

  Stream<int> _getQuantityStream() {
    final streamController = StreamController<int>();

    // Initial fetch
    _fetchQuantity().then((value) {
      if (mounted) {
        streamController.add(value);
      }
    });

    // Set up periodic checks (simulating real-time updates)
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final newQuantity = await _fetchQuantity();
      streamController.add(newQuantity);
    });

    return streamController.stream;
  }

  Future<int> _fetchQuantity() async {
    final url = Uri.parse(
        '$_baseUrl/AdminDatabase/${Uri.encodeComponent(widget.collegeName)}'
            '/Shops/${Uri.encodeComponent(widget.shopName)}'
            '/Categories/${Uri.encodeComponent(widget.categoryName)}'
            '/${Uri.encodeComponent(widget.foodItem['name'])}'
            '/quantity.json'
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final value = jsonDecode(response.body);
        return value != null ? int.parse(value.toString()) : 0;
      }
      return 0;
    } catch (e) {
      debugPrint('Error fetching quantity: $e');
      return 0;
    }
  }

  Future<void> _updateQuantity(int newQuantity) async {
    final url = Uri.parse(
        '$_baseUrl/AdminDatabase/${Uri.encodeComponent(widget.collegeName)}'
            '/Shops/${Uri.encodeComponent(widget.shopName)}'
            '/Categories/${Uri.encodeComponent(widget.categoryName)}'
            '/${Uri.encodeComponent(widget.foodItem['name'])}'
            '/quantity.json'
    );

    try {
      await http.put(url, body: jsonEncode(newQuantity));
    } catch (e) {
      debugPrint('Error updating quantity: $e');
    }
  }

  Future<void> _deleteQuantity() async {
    final url = Uri.parse(
        '$_baseUrl/AdminDatabase/${Uri.encodeComponent(widget.collegeName)}'
            '/Shops/${Uri.encodeComponent(widget.shopName)}'
            '/Categories/${Uri.encodeComponent(widget.categoryName)}'
            '/${Uri.encodeComponent(widget.foodItem['name'])}.json'
    );

    try {
      await http.delete(url);
    } catch (e) {
      debugPrint('Error deleting quantity: $e');
    }
  }

  void _handleClick() {
    if (quantity == 0) {
      setState(() {
        quantity = 1;
        _isClicked = true;
      });
      _updateQuantity(1);
    } else {
      setState(() {
        quantity = 0;
        _isClicked = false;
      });
      _updateQuantity(0);
    }
  }

  @override
  void dispose() {
    _quantitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, right: 5),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 100,
        height: 33,
        decoration: BoxDecoration(
          color: Colors.deepPurple,
          borderRadius: BorderRadius.circular(15),
        ),
        child: quantity == 0
            ? TextButton(
          onPressed: _handleClick,
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            padding: EdgeInsets.zero,
          ),
          child: const Text('Add', style: TextStyle(fontSize: 16)),
        )
            : Row(
          children: [
            Flexible(
              child: IconButton(
                onPressed: () {
                  if (quantity > 0) {
                    final newQuantity = quantity - 1;
                    setState(() {
                      quantity = newQuantity;
                      _isClicked = newQuantity > 0;
                    });
                      _updateQuantity(newQuantity);
                  }
                },
                icon: const Icon(Icons.remove, color: Colors.white, size: 24),
                padding: EdgeInsets.zero,
              ),
            ),
            Text(
              '$quantity',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            Flexible(
              child: IconButton(
                onPressed: () {
                  final newQuantity = quantity + 1;
                  setState(() {
                    quantity = newQuantity;
                    _isClicked = true;
                  });
                  _updateQuantity(newQuantity);
                },
                icon: const Icon(Icons.add, color: Colors.white, size: 24),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}