import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user/models/order_item.dart';
import 'package:user/qr_code_page.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  late final PageController _pageController;
  late final DatabaseReference _databaseRef;
  late final StreamSubscription<DatabaseEvent> _streamSubscription;
  bool _isLoading = true;
  List<Map<String, dynamic>> _pendingOrders = [];
  List<Map<String, dynamic>> _purchasedOrders = [];
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _databaseRef = FirebaseDatabase.instance.ref();
    _pageController = PageController();
    _pageController.addListener(_onPageChanged);
    _activateListeners();
  }


  Future<void> _loadData() async {
    // Simulate a delay for loading animation
    await Future.delayed(const Duration(milliseconds: 500));


    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _handleRefresh() async{
    setState(() {
      _isLoading = true;
    });
    await _loadData();
    return await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      false;
    });
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    super.dispose();
  }

  Future<String?> getSelectedShop() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('selectedShop');
  }

  Future<String?> getCollegeName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('collegeName');
  }

  Future<String?> getCurrentUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  void _activateListeners() async{
    String? collegeName = await getCollegeName();
    String? shopName = await getCollegeName();
    String? userId = await getCurrentUserId();

    if (userId == null) {
      // Handle the case when no user is signed in
      setState(() {
        _isLoading = false;
      });
      return;
    }
    _streamSubscription = _databaseRef
        .child('AdminDatabase/$collegeName/UserDatabase/$userId/OrderedList')
        .onValue
        .listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      // print('Fetched data: $data');

      if (data == null) {
        setState(() {
          _isLoading = false;
          _pendingOrders = [];
          _purchasedOrders = [];
        });
        return;
      }

      final List<Map<String, dynamic>> pendingOrders = [];
      final List<Map<String, dynamic>> purchasedOrders = [];

      data.forEach((key, value) {
        final order = value as Map<dynamic, dynamic>;
        final orderItems = (order['orderItems'] as List<dynamic>? ?? []).map((item) {
          return OrderItem(
            name: item['name'] as String,
            price: (item['price'] as num).toDouble(),
            quantity: item['quantity'] as int,
            isPurchased: order['isPurchased'] as bool,
          );
        }).toList();

        final Map<String, dynamic> orderData = {
          'orderId': key,
          'shop': order['shop'],
          'totalAmount': order['totalAmount'],
          'isPurchased': order['isPurchased'],
          'orderItems': orderItems,
          'uniqueKey': order['uniqueKey']
        };

        if (order['isPurchased'] as bool) {
          purchasedOrders.add(orderData);
        } else {
          pendingOrders.add(orderData);
        }
      });

      setState(() {
        _isLoading = false;
        _pendingOrders = pendingOrders;
        _purchasedOrders = purchasedOrders;
      });
    });
  }

  void _onPageChanged() {
    setState(() {
      _currentPage = _pageController.page?.round() ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTabIndicator('Pending', 0),
              _buildTabIndicator('Purchased', 1),
            ],
          ),
        ),
      ),
      body: LiquidPullToRefresh(
        onRefresh: _handleRefresh,
        color:Colors.deepPurple,
        backgroundColor: Colors.deepPurple[200],
        animSpeedFactor: 2,
        springAnimationDurationInMilliseconds: 500,

        showChildOpacityTransition: false,

        child: Stack(
          children: [
            if (_isLoading)
              Stack(
                children: [
                  const Opacity(
                    opacity: 0.6,
                    child: ModalBarrier(
                      dismissible: false,
                      color: Colors.black,
                    ),
                  ),
                  Center(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 300),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Lottie.asset('assets/img/DinnerLoading.json', width: 200, height: 200),
                            const SizedBox(height: 20),
                            const Text(
                              'Please wait...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            if (!_isLoading)
              PageView(
                controller: _pageController,
                children: [
                  OrdersView(title: 'Pending', orders: _pendingOrders),
                  OrdersView(title: 'Purchased', orders: _purchasedOrders),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabIndicator(String label, int index) {
    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _currentPage == index ? Colors.deepPurple : Colors.black,
              ),
            ),
            if (_currentPage == index)
              Container(
                height: 3,
                width: 50,
                color: Colors.deepPurple,
                margin: const EdgeInsets.only(top: 4),
              ),
          ],
        ),
      ),
    );
  }
}

class OrdersView extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> orders;

  const OrdersView({super.key, required this.title, required this.orders});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return _buildOrderCard(context,order);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Map<String, dynamic> order) {
    return GestureDetector(
        onTap: () {
          // Convert List<OrderItem> to List<Map<String, dynamic>>
          List<Map<String, dynamic>> orderedItems = (order['orderItems'] as List<OrderItem>).map((item) {
            return {
              'name': item.name,
              'price': item.price,
              'quantity': item.quantity,
            };
          }).toList();

          if (!order['isPurchased']){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QrCodePage(
                  totalAmount: (order['totalAmount']).toDouble(),
                  orderedItems: orderedItems,  // Pass converted List<Map<String, dynamic>>
                  uniqueKey: order['uniqueKey'].toString(),
                ),
              ),
            );
          }else{
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: const Center(child: Text("can't open QR for purchased food")), backgroundColor: Colors.red[500]),
            );
          }


        },
    child:  Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order ID: ${order['orderId']}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Icon(
                  order['isPurchased'] ? Icons.check_circle : Icons.pending,
                  color: order['isPurchased'] ? Colors.green : Colors.orange,
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Shop: ${order['shop']}', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            Text('Total Amount: ₹${order['totalAmount']}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const Divider(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: (order['orderItems'] as List<OrderItem>).map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item.name, style: const TextStyle(fontSize: 14)),
                      Text('x${item.quantity} - ₹${item.price}', style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    )
    );
  }
}
