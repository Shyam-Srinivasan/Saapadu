import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:saapadu/home_page.dart';

class CreateShop extends StatefulWidget {
  final String collegeName;
  const CreateShop({super.key, required this.collegeName});

  @override
  State<CreateShop> createState() => _CreateShopState();
}

class _CreateShopState extends State<CreateShop> {
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final databaseRef = FirebaseDatabase.instance.ref("AdminDatabase");
  List<Map<String, dynamic>> shopsList = [];

  @override
  void initState() {
    super.initState();
    fetchShops();
  }

  Future<void> fetchShops() async {
    DatabaseReference collegeRef = databaseRef.child(widget.collegeName).child("Shops");
    collegeRef.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        setState(() {
          shopsList = data.entries
              .map((e) => {"name": e.key, "password": e.value["password"]})
              .toList();
        });
      }
    });
  }

  Future<void> addShop() async {
    String shopName = _shopNameController.text.trim();
    String password = _passwordController.text.trim();

    if (shopName.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Please fill all fields", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    DatabaseReference shopRef = databaseRef.child(widget.collegeName).child("Shops").child(shopName);
    await shopRef.set({"password": password});

    Get.snackbar("Success", "Shop Added!", backgroundColor: Colors.green, colorText: Colors.white);
    _shopNameController.clear();
    _passwordController.clear();
    Navigator.of(context).pop();
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
