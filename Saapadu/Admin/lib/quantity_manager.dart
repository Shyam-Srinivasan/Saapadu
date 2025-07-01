import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class QuantityManage extends StatefulWidget {
  final Map<String, dynamic> foodItem;
  final String categoryName;
  final String collegeName;
  final String shopName;
  const QuantityManage({super.key, required this.foodItem, required this.categoryName, required this.collegeName, required this.shopName});

  @override
  _QuantityManageState createState() => _QuantityManageState();
}

class _QuantityManageState extends State<QuantityManage> {
  late DatabaseReference _databaseRef;
  late StreamSubscription<DatabaseEvent> _streamSubscription;
  int quantity = 0;
  bool _isClicked = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _databaseRef = FirebaseDatabase.instance.ref();
    _controller = TextEditingController(text: quantity.toString());
    _activateListeners();
  }

  // Fetch real-time data and update the quantity in the UI
  void _activateListeners() {
    _streamSubscription = _databaseRef
        .child('AdminDatabase/${widget.collegeName}/Shops/${widget.shopName}/Categories/${widget.categoryName}/${widget.foodItem['name']}/quantity')
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          quantity = int.parse(event.snapshot.value.toString());
          _controller.text = quantity.toString();
          _isClicked = quantity > 0;
        });
      } else {
        // If the item is removed from the cart, reset quantity
        setState(() {
          quantity = 0;
          _controller.text = "0";
          _isClicked = false;
        });
      }
    });
  }

  void _updateDatabase(int newQuantity) {
    _databaseRef.child('AdminDatabase/${widget.collegeName}/Shops/${widget.shopName}/Categories/${widget.categoryName}/${widget.foodItem['name']}/quantity')
        .set(newQuantity);
  }


  void _deleteDatabase(){
    _databaseRef.child('AdminDatabase/${widget.collegeName}/Shops/${widget.shopName}/Categories/${widget.categoryName}/${widget.foodItem['name']}/quantity').remove();
  }

  void _handleClick() {
    setState(() {
      if (quantity == 0) {
        quantity = 1;
        _isClicked = true;
        _updateDatabase(quantity);
      } else {
        quantity = 0;
        _isClicked = false;
        _deleteDatabase();
      }
    });
  }
  void _onQuantityChanged(String value) {
    int? newQuantity = int.tryParse(value);
    if (newQuantity != null && newQuantity >= 0) {
      setState(() {
        quantity = newQuantity;
        _updateDatabase(quantity);
      });
    } else {
      _controller.text = quantity.toString();
    }
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
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
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
                      _updateDatabase(quantity);
                    }
                  });
                },
                icon: const Icon(Icons.remove, color: Colors.white, size: 24),
                padding: EdgeInsets.zero,
              ),
            ),
            // Quantity can't be changed
            // Text(
            //   '$quantity',
            //   style: const TextStyle(color: Colors.white, fontSize: 16),
            // ),
            // Quantity can be changed
            Flexible(
              child: SizedBox(
                // width: 35,
                // height: 45,
                child: Center(
                  child: TextField(
                    controller: _controller,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.0),
                    decoration: const InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 0.0),
                    ),
                    textAlignVertical: TextAlignVertical.center,
                    onSubmitted: _onQuantityChanged,
                    onTapOutside: (event) {
                      FocusManager.instance.primaryFocus?.unfocus();
                      _onQuantityChanged(_controller.text);
                    },
                  ),
                ),
              ),
            ),
            Flexible(
              child: IconButton(
                onPressed: () {
                  setState(() {
                    quantity++;
                    _isClicked = true;
                    _updateDatabase(quantity);
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
    _streamSubscription.cancel();
    _controller.dispose();
    super.dispose();
  }
}
