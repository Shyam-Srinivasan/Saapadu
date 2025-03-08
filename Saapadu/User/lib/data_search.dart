import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:lottie/lottie.dart';
import 'package:user/add_to_cart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _query = '';
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  StreamSubscription<DatabaseEvent>? _streamSubscription;
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<String?> getSelectedShop() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('selectedShop');
  }

  Future<String?> getCollegeName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('collegeName');
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  void _fetchData() async {
    String? shopName = await getSelectedShop();
    String? collegeName = await getCollegeName();
    if (shopName == null || collegeName == null) {
      setState(() {
        _errorMessage = 'Failed to retrieve shop or college information.';
        _isLoading = false;
      });
      return;
    }

    _streamSubscription = _database
        .child('AdminDatabase/$collegeName/Shops/$shopName/Categories/')
        .onValue
        .listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) {
        setState(() {
          _items = [];
          _isLoading = false;
        });
        return;
      }

      final List<Map<String, dynamic>> items = [];

      data.forEach((_, categoryValue) {
        if (categoryValue is Map<dynamic, dynamic>) {
          categoryValue.forEach((_, itemValue) {
            if (itemValue is Map<dynamic, dynamic>) {
              items.add({
                'name': itemValue['name'] ?? 'Unknown',
                'price': (itemValue['price'] as num?)?.toDouble() ?? 0.0,
                'quantity': (itemValue['quantity'] as int?) ?? 0,
                'image': itemValue['img'] ?? '',
              });
            }
          });
        }
      });

      setState(() {
        _items = items;
        _isLoading = false;
      });
    }, onError: (error) {
      setState(() {
        _errorMessage = 'Failed to load data. Please try again later.';
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: _buildSearchBar(screenWidth),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!, style: TextStyle(color: Colors.red)))
          : _buildResults(),
    );
  }

  Widget _buildSearchBar(double screenWidth) {
    return Container(
      width: screenWidth * 0.85,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
          ),
        ],
      ),
      child: TextField(
        autofocus: true,
        onChanged: (value) => setState(() => _query = value),
        decoration: InputDecoration(
          hintText: 'Search',
          border: InputBorder.none,
          icon: const Icon(Icons.search, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildResults() {
    final filteredItems = _query.isEmpty
        ? _items
        : _items.where((item) => item['name'].toLowerCase().contains(_query.toLowerCase())).toList();

    if (filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width*0.5,
              height: MediaQuery.of(context).size.height*0.3,
              child: Lottie.asset('assets/img/EmptySearch.json'),
            ),
            const SizedBox(height: 10),
            const Text(
              'No items found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        return _buildItemCard(item);
      },
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.asset(
                item['image'],
                width: double.infinity,
                height: MediaQuery.of(context).size.height*0.25,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('₹${item['price']}', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  ),
                  AddToCartButton(foodItem: item),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}