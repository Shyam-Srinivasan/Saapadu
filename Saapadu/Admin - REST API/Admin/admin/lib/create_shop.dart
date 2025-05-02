import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'RealtimeDatabaseConnection.dart';
import 'home_page.dart';
// import 'package:saapadu/home_page.dart';

class CreateShop extends StatefulWidget {
  final String collegeName;
  const CreateShop({super.key, required this.collegeName});

  @override
  State<CreateShop> createState() => _CreateShopState();
}

class _CreateShopState extends State<CreateShop> {
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  List<Map<String, dynamic>> shopsList = [];
  String? _currentListenerPath;

  @override
  void initState() {
    super.initState();
    // fetchShops();
    _setupRealtimeListener();
  }

  @override
  void dispose() {
    if (_currentListenerPath != null) {
      RealtimeDatabaseService.cancelListener(_currentListenerPath!);
    }
    _shopNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

void startPolling() {
  Timer.periodic(Duration(seconds: 5), (timer) => fetchShops());
}

  void _setupRealtimeListener() {
    _currentListenerPath = 'AdminDatabase/${Uri.encodeComponent(widget.collegeName)}/Shops';

    RealtimeDatabaseService.listenToShopList(
      collegeName: widget.collegeName,
      onData: (shops) {
        if (mounted) {
          setState(() {
            shopsList = shops;
          });
        }
      },
    );
  }
Future<void> fetchShops() async {
  final url = Uri.parse(
      "https://saapadu-groups-default-rtdb.asia-southeast1.firebasedatabase.app/AdminDatabase/${Uri.encodeComponent(widget.collegeName)}/Shops.json");

  try {
    final response = await http.get(
      Uri.parse("$url?shallow=true"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map?;
      if (data != null) {
        setState(() {
          shopsList = data.entries
              .map((e) => {"name": e.key, "password": e.value["password"]})
              .toList();
        });
      }
    } else {
      debugPrint("Error: Failed to fetch shops. Status code: ${response.statusCode}");
    }
  } catch (e) {
    debugPrint("Error: An exception occurred while fetching shops: $e");
  }
}
  Future<void> addShop() async {
    final shopName = _shopNameController.text.trim();
    final password = _passwordController.text.trim();

    if (shopName.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Please fill all fields",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      final url = Uri.parse(
          'https://saapadu-groups-default-rtdb.asia-southeast1.firebasedatabase.app/AdminDatabase/${Uri.encodeComponent(widget.collegeName)}/Shops/${Uri.encodeComponent(shopName)}.json');

      final response = await http.put(
        url,
        body: jsonEncode({"password": password}),
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        _shopNameController.clear();
        _passwordController.clear();
        Navigator.of(context).pop();
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to add shop: ${e.toString()}",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }


  void showAddShopDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Shop"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _shopNameController,
                decoration: InputDecoration(labelText: "Shop Name"),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: addShop,
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
                widget.collegeName,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),

            )
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: height * 0.05),
              Text(
                "Create Shops",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: height * 0.03),

              // Shops Grid
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 20,
                runSpacing: 20,
                children: [
                  for (var shop in shopsList)
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          // Navigate to shop
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => HomePage(collegeName: widget.collegeName, shopName: shop['name']))
                          );
                        },
                        child: Container(
                          width: width * 0.35,
                          height: height * 0.15,
                          decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(color: Colors.black26, blurRadius: 5, spreadRadius: 2)
                            ],
                          ),
                          child: Center(
                            child: Text(
                              shop['name'],
                              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Add Shop Button
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: showAddShopDialog,
                      child: Container(
                        width: width * 0.35,
                        height: height * 0.15,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.black54),
                        ),
                        child: Center(
                          child: Text("+ Add Shop", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: height * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}
