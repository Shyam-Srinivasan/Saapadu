import 'dart:async';
import 'package:user/shimmer_effect.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:user/add_to_cart.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import the add_to_cart.dart

class PopularItemsWidget extends StatefulWidget {
  const PopularItemsWidget({super.key});

  @override
  _PopularItemsWidgetState createState() => _PopularItemsWidgetState();
}

class _PopularItemsWidgetState extends State<PopularItemsWidget> {
  List<Map<String, dynamic>> popularItems = [];
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  late StreamSubscription<DatabaseEvent> _streamSubscription;
  bool _isLoading = true;


  @override
  void initState() {
    super.initState();
    _activateListeners();
  }

  Future<String?> getSelectedShop() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('selectedShop');
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  void _activateListeners() async{
    String? shopName = await getSelectedShop();
    _streamSubscription = _database
        .child('AdminDatabase/$shopName/Popular')
        .onValue
        .listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      final List<Map<String, dynamic>> items = [];
      data.forEach((key, value) {
        items.add({
          'name': value['name'] ?? key,
          'price': value['price'] ?? 0.0,
          'quantity': value['quantity'] ?? 0,
          'image': value['image'] ?? 'assets/img/default.jpeg', // Provide a default image if not available
        });
      });
      setState(() {
        popularItems = items;
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        child: _isLoading
          ? const ShimmerEffect(width: 170, height: 225)
        : Row(
          children: popularItems.map((item) {
            final imagePath = item['image'];
            final foodName = item['name'];
            final price = item['price'];
            final quantity = item['quantity'];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7),
              child: Container(
                width: 170,
                height: 225,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 3,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(5),
                              topLeft: Radius.circular(5)
                            ),
                            child: Image.asset(
                              imagePath,
                              height: 150,
                              width: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            " $foodName",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10, left: 10),
                            child: Text(
                              "₹${price.toInt()}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: AddToCartButton(
                                foodItem: {
                                  'name': foodName,
                                  'price': price,
                                  'quantity': quantity,
                                  'image': imagePath,
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
