import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddToCartButton extends StatefulWidget {
  final Map<String, dynamic> foodItem;

  const AddToCartButton({super.key, required this.foodItem});

  @override
  _AddToCartButtonState createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends State<AddToCartButton> {
  late DatabaseReference _databaseRef;
  StreamSubscription<DatabaseEvent>? _streamSubscription;
  int quantity = 0;
  bool _isClicked = false;

  @override
  void initState() {
    super.initState();
    _databaseRef = FirebaseDatabase.instance.ref();
    _activateListeners();
  }

  Future<String?> getCurrentUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  Future<String?> getSelectedShop() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('selectedShop');
  }

  Future<String?> getCollegeName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('collegeName');
  }

  // Fetch real-time data and update the quantity in the UI
  void _activateListeners() async {
    String? userId = await getCurrentUserId();
    String shopName = await getSelectedShop() ?? '';
    String collegeName = await getCollegeName() ?? '';
    String foodItemName = widget.foodItem['name'];

    if (userId != null && shopName.isNotEmpty && collegeName.isNotEmpty) {
      _streamSubscription = _databaseRef
          .child('AdminDatabase/$collegeName/UserDatabase/$userId/CartItems/$shopName/$foodItemName')
          .onValue
          .listen((event) {
        if (event.snapshot.value != null && event.snapshot.value is Map) {
          Map<dynamic, dynamic> itemData = event.snapshot.value as Map<dynamic, dynamic>;
          setState(() {
            quantity = itemData['quantity'] ?? 0;
            _isClicked = quantity > 0;
          });
        } else {
          setState(() {
            quantity = 0;
            _isClicked = false;
          });
        }
      });
    }
  }

  void _updateDatabase() async {
    String? userId = await getCurrentUserId();
    String shopName = await getSelectedShop() ?? '';
    String collegeName = await getCollegeName() ?? '';
    String foodItemName = widget.foodItem['name'];


    if (userId != null && shopName.isNotEmpty && collegeName.isNotEmpty) {
      _databaseRef.child('AdminDatabase/$collegeName/UserDatabase/$userId/CartItems/$shopName/$foodItemName').set({
        // 'name': widget.foodItem['name'],
        // 'price': widget.foodItem['price'],
        'quantity': quantity,
        // 'image': widget.foodItem['image'],
      });
    }
  }

  void _deleteDatabase() async {
    String? userId = await getCurrentUserId();
    String shopName = await getSelectedShop() ?? '';
    String collegeName = await getCollegeName() ?? '';
    String foodItemName = widget.foodItem['name'];

    if (userId != null && shopName.isNotEmpty && collegeName.isNotEmpty) {
      DatabaseReference itemRef = _databaseRef.child(
          'AdminDatabase/$collegeName/UserDatabase/$userId/CartItems/$shopName/$foodItemName');

      await itemRef.remove();

      // Check if shop node is empty, if yes, remove the shop itself
      DatabaseReference shopRef = _databaseRef.child(
          'AdminDatabase/$collegeName/UserDatabase/$userId/CartItems/$shopName');

      DatabaseEvent event = await shopRef.once();
      if (event.snapshot.value == null) {
        await shopRef.remove();
      }
    }
  }

  void _handleClick() {
    setState(() {
      if (quantity == 0) {
        quantity = 1;
        _isClicked = true;
        _updateDatabase();
      } else {
        quantity = 0;
        _isClicked = false;
        _deleteDatabase();
      }
    });
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
                  setState(() {
                    if (quantity > 0) {
                      quantity--;
                      if (quantity == 0) {
                        _isClicked = false;
                        _deleteDatabase();
                      }
                      _updateDatabase();
                    }
                  });
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
                  setState(() {
                    quantity++;
                    _isClicked = true;
                    _updateDatabase();
                  });
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

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }
}
