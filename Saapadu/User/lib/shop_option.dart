import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShopOption extends StatefulWidget {
  const ShopOption({super.key});

  @override
  State<ShopOption> createState() => _ShopOptionState();
}

class _ShopOptionState extends State<ShopOption> {
  bool _isLoading = false;
  String? _errorMessage;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  List<String> shopNames = [];
  StreamSubscription<DatabaseEvent>? _shopSubscription;

  @override
  void initState() {
    super.initState();
    _fetchShops();
  }

  @override
  void dispose() {
    _shopSubscription?.cancel();
    super.dispose();
  }

  Future<void> _saveShopName(String shopName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedShop', shopName);
  }

  Future<String?> getCollegeName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('collegeName');
  }

  Future<void> _fetchShops() async {
    final String? collegeName = await getCollegeName();
    if (collegeName == null) {
      setState(() => _errorMessage = "College name not found. Please try again.");
      return;
    }

    DatabaseReference shopRef = _database.ref().child('AdminDatabase').child(collegeName).child('Shops');

    _shopSubscription = shopRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data is Map<dynamic, dynamic>) {
        setState(() {
          shopNames = data.keys.cast<String>().toList();
          _errorMessage = null;
        });
      } else {
        setState(() => _errorMessage = "No shops available.");
      }
    }, onError: (error) {
      setState(() => _errorMessage = "Error fetching shops. Please check your connection.");
    });
  }

  void _navigateToHome(String shopName) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    await _saveShopName(shopName);

    final String? userId = await getCollegeName();
    final String? collegeName = await getCollegeName();

    if (userId == null || collegeName == null) {
      Navigator.of(context).pushReplacementNamed('/sel_clg');
      return;
    }

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home', arguments: {'shop': shopName});
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: width * 0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (_isLoading)
                Column(
                  children: [
                    Lottie.asset(
                      'assets/img/DinnerLoading.json',
                      width: width * 0.4, // 40% of screen width
                      height: height * 0.2, // 20% of screen height
                    ),
                    const SizedBox(height: 20),
                    const Text('Please wait...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                )
              else if (_errorMessage != null)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      'assets/img/NoShops.json',
                      width: width * 0.9, // 60% of screen width
                      height: height * 0.3, // 30% of screen height
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    const Text(
                      'Select a Shop',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: height * 0.03),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 15,
                      runSpacing: 15,
                      children: shopNames.map((shop) {
                        return SizedBox(
                          width: width * 0.4,
                          child: ElevatedButton(
                            onPressed: () => _navigateToHome(shop),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              minimumSize: Size(width * 0.4, height * 0.2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              side: const BorderSide(color: Colors.deepPurple, width: 2),
                              shadowColor: Colors.black.withOpacity(0.7),
                              elevation: 10,
                            ),
                            child: Text(
                              shop,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
