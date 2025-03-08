// import 'dart:async';
// import 'dart:ui';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
// import 'package:lottie/lottie.dart';
// import 'package:user/qr_code_page.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:uuid/uuid.dart';
// import 'payment_service.dart';
//
// class CartPage extends StatefulWidget {
//   const CartPage({super.key});
//
//   @override
//   _CartPageState createState() => _CartPageState();
// }
//
// class _CartPageState extends State<CartPage> {
//   late DatabaseReference _databaseRef;
//   Map<String, Map<String, dynamic>> _cartItems = {};
//   late StreamSubscription<DatabaseEvent> _cartStreamSubscription;
//   late StreamSubscription<DatabaseEvent> _adminStreamSubscription;
//   Map<String, dynamic> _adminData = {};
//   late StreamSubscription<DatabaseEvent> _streamSubscription;
//   bool _isLoading = true;
//   String uniqueKey = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _databaseRef = FirebaseDatabase.instance.ref();
//     _activateListeners();
//     _fetchAdminData();
//     _updateCartWithLatestPrices();
//   }
//
//   Future<String?> getSelectedShop() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString('selectedShop');
//   }
//
//   Future<String?> getCollegeName() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString('collegeName');
//   }
//
//   Future<String?> getCurrentUserId() async{
//     User? user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       return user.uid;
//     } else {
//       print('No user is signed in');
//       return null; // Handle the case when no user is signed in
//     }
//   }
//
//
//   void _activateListeners() async{
//     String? userId = await getCurrentUserId(); // Get the userId
//     String? collegeName = await getCollegeName();
//     String? shopName = await getSelectedShop();
//
//     _cartStreamSubscription = _databaseRef
//         .child('AdminDatabase/$collegeName/UserDatabase/$userId/CartItems/$shopName/')
//         .onValue
//         .listen((event) {
//       final data = event.snapshot.value;
//
//       if (data == null || data is! Map) {
//         print('Error: Data is null or not a Map');
//         // Update the state to show an empty cart UI
//         setState(() {
//           _cartItems = {}; // Clear the cart
//           _isLoading = false; // Stop loading
//         });
//         return;
//       }
//
//       setState(() {
//         _cartItems = Map<String, Map<String, dynamic>>.from(
//           (data).map(
//                 (key, value) => MapEntry(
//               key,
//               Map<String, dynamic>.from(value),
//             ),
//           ),
//         );
//         _isLoading = false; // Stop loading
//       });
//     });
//   }
//
//   void _activateAdminListener() async {
//     String? shopName = await getSelectedShop();
//     String? collegeName = await getCollegeName();
//
//     _adminStreamSubscription = _databaseRef
//         .child('AdminDatabase/$collegeName/Shops/$shopName/Categories')
//         .onValue
//         .listen((event) {
//       final data = event.snapshot.value;
//       if (data != null && data is Map) {
//         setState(() {
//           _adminData = Map<String, dynamic>.from(data);
//         });
//         _updateCartWithLatestPrices();
//       } else {
//         setState(() {
//           _adminData = {};
//         });
//       }
//     });
//   }
//   Future<void> _fetchAdminData() async {
//     String? shopName = await getSelectedShop();
//     String? collegeName = await getCollegeName();
//     if (shopName != null) {
//       DatabaseEvent event = await _databaseRef.child('AdminDatabase/$collegeName/Shops/$shopName/Categories').once();
//       if (event.snapshot.value != null && event.snapshot.value is Map) {
//         setState(() {
//           _adminData = Map<String, dynamic>.from(event.snapshot.value as Map);
//         });
//         _activateAdminListener(); // Start listening to admin data changes
//       } else {
//         setState(() {
//           _adminData = {};
//         });
//       }
//     }
//   }
//
//   void _updateCartWithLatestPrices() async {
//     String? userId = await getCurrentUserId();
//     String? collegeName = await getCollegeName();
//     String? shopName = await getSelectedShop();
//
//     if (userId == null || collegeName == null || shopName == null) {
//       return;
//     }
//
//     // Iterate through the admin's categories to find the latest prices
//     for (var category in _adminData.values) {
//       if (category is Map) {
//         category.forEach((itemName, itemDetails) {
//           if (itemDetails is Map && _cartItems.containsKey(itemName)) {
//             final latestPrice = itemDetails['price'];
//             final currentPrice = _cartItems[itemName]?['price'];
//
//             // If the price has changed, update the cart
//             if (latestPrice != null && latestPrice != currentPrice) {
//               setState(() {
//                 _cartItems[itemName]!['price'] = latestPrice;
//               });
//
//               // Update the database with the latest price
//               _databaseRef
//                   .child('AdminDatabase/$collegeName/UserDatabase/$userId/CartItems/$shopName/$itemName')
//                   .update({
//                 'price': latestPrice,
//               });
//             }
//           }
//         });
//       }
//     }
//   }
//
//   Future<void> _loadData() async {
//     // Simulate a delay for loading animation
//     await Future.delayed(const Duration(milliseconds: 500));
//
//     setState(() {
//       _isLoading = false;
//     });
//   }
//
//   Future<void> _handleRefresh() async{
//     setState(() {
//       _isLoading = true;
//     });
//     await _loadData();
//     return await Future.delayed(const Duration(milliseconds: 800));
//     setState(() {
//       false;
//     });
//   }
//
//   Future<void> _loadOrderData(double totalAmount, List<Map<String, dynamic>> orderedItems) async {
//     String? userId = await getCurrentUserId(); // Get the userId
//     String? shopName = await getSelectedShop();
//     String? orderId = const Uuid().v4().replaceAll('-', '').substring(0,20);
//     String? uniqueKey = const Uuid().v4();
//     final timestamp = DateTime.now().toString();
//
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => PaymentService(
//           totalAmount: totalAmount,
//           orderedItems: orderedItems,
//           uniqueKey: uniqueKey,
//           orderId: orderId,
//           shopName: shopName,
//           userId: userId,
//           timestamp: timestamp,
//         ),
//       ),
//     );
//
//   }
//
//
//
//   @override
//   void dispose() {
//     _cartStreamSubscription.cancel();
//     _adminStreamSubscription.cancel();
//     super.dispose();
//   }
//
//   void _showOutOfStockAlert() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Out of Stock'),
//         content: const Text('Some items in your cart are out of stock. Please remove them to proceed.'),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     // Filter only items with quantity > 0
//     final filteredItems = _cartItems.entries
//         .where((entry) => entry.value['quantity'] != null && entry.value['quantity'] > 0)
//         .toList();
//
//     // Calculate total amount and number of items
//     double totalAmount = filteredItems.fold(
//       0.0,
//           (sum, entry) {
//         final price = entry.value['price'] ?? 0.0;
//         final quantity = entry.value['quantity'] ?? 0;
//         return sum + (price * quantity);
//       },
//     );
//
//     int totalItems = filteredItems.fold(
//       0,
//           (sum, entry) => sum + (entry.value['quantity'] ?? 0) as int,
//     );
//
//     // Prepare orderedItems list to pass to QrCodePage
//     List<Map<String, dynamic>> orderedItems = filteredItems.map((entry) {
//       final itemName = entry.key;
//       final itemDetails = entry.value;
//       return {
//         'name': itemName,
//         'price': itemDetails['price'],
//         'quantity': itemDetails['quantity'],
//       };
//     }).toList();
//
//     final isCartEmpty = filteredItems.isEmpty;
//
//     void updateItemInDatabase(String itemName, Map<String, dynamic> itemDetails) async{
//       String? userId = await getCurrentUserId(); // Get the userId
//       String? collegeName = await getCollegeName();
//       String? shopName = await getSelectedShop();
//       DatabaseReference ref = FirebaseDatabase.instance.ref('AdminDatabase/$collegeName/UserDatabase/$userId/CartItems/$shopName/$itemName');
//
//       // Update item in database
//       ref.update({
//         'quantity': itemDetails['quantity'],
//       });
//     }
//
//     void removeItemFromCart(String itemName) async{
//       String? userId = await getCurrentUserId(); // Get the userId
//       String? collegeName = await getCollegeName();
//       String? shopName = await getSelectedShop();
//       // Remove item from local cart
//       setState(() {
//         _cartItems.remove(itemName);
//       });
//
//       // Also remove item from database
//       DatabaseReference ref = FirebaseDatabase.instance.ref('AdminDatabase/$collegeName/UserDatabase/$userId/CartItems/$shopName/$itemName');
//       ref.remove();
//     }
//
//     bool isOutOfStock0(String itemName) {
//       for (var category in _adminData.values) {
//         if (category[itemName] != null && category[itemName]['quantity'] == 0) {
//           return true; // Item is out of stock
//         }
//       }
//       return false; // Item is in stock
//     }
//
//     bool hasOutOfStockItems() {
//       return filteredItems.any((entry) => isOutOfStock0(entry.key));
//     }
//
//     void removeOutOfStockItems() {
//       final outOfStockItems = filteredItems.where((entry) => isOutOfStock0(entry.key)).toList();
//       for (var entry in outOfStockItems) {
//         removeItemFromCart(entry.key);
//       }
//     }
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('My Cart'),
//         backgroundColor: Colors.white,
//         bottom: const PreferredSize(
//           preferredSize: Size.fromHeight(4.0),
//           child: Divider(
//             height: 4.0,
//             thickness: 1,
//             color: Color(0x61693BB8),
//           ),
//         ),
//       ),
//
//       body: LiquidPullToRefresh(
//         onRefresh: _handleRefresh,
//         color:Colors.deepPurple,
//         backgroundColor: Colors.deepPurple[200],
//         animSpeedFactor: 2,
//         springAnimationDurationInMilliseconds: 500,
//
//         showChildOpacityTransition: false,
//         child: Stack(
//             children: [
//               if (_isLoading)
//                 Stack(
//                   children: [
//                     const Opacity(
//                       opacity: 0.6,
//                       child: ModalBarrier(
//                         dismissible: false,
//                         color: Colors.black,
//                       ),
//                     ),
//                     Center(
//                       child: BackdropFilter(
//                         filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
//                         child: Padding(
//                           padding: const EdgeInsets.only(bottom: 300),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Lottie.asset('assets/img/DinnerLoading.json', width: 200, height: 200),
//                               const SizedBox(height: 20),
//                               const Text(
//                                 'Please wait...',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               if (!_isLoading)
//                 isCartEmpty
//                     ? Center(
//                   child: Padding(
//                     padding: const EdgeInsets.only(bottom: 40),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Lottie.asset(
//                           'assets/img/EmptyCart.json',
//                           width: 350,
//                           height: 350,
//                           fit: BoxFit.cover,
//                         ),
//                         const SizedBox(height: 20),
//                         const Text(
//                           "Your cart is empty",
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                             letterSpacing: 8,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 )
//                     : ListView.builder(
//                   itemCount: filteredItems.length,
//                   itemBuilder: (context, index) {
//                     final itemName = filteredItems[index].key;
//                     final itemDetails = filteredItems[index].value;
//                     final imagePath = itemDetails['image'] ?? 'assets/img/default_image.jpg'; // Default image path
//                     // final imagePath = 'assets/img/${itemName.replaceAll(' ', '')}.jpeg';
//                     final isOutOfStock = isOutOfStock0(itemName);
//
//                     return Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
//                       child: Container(
//                         padding: const EdgeInsets.all(10),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(10),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.grey.withOpacity(0.5),
//                               spreadRadius: 3,
//                               blurRadius: 10,
//                               offset: const Offset(0, 3),
//                             ),
//                           ],
//                         ),
//                         child: Row(
//                           children: [
//                             // Image section
//                             itemDetails['image'] != null
//                                 ? Image.asset(
//                               imagePath,
//                               height: 80,
//                               width: 80,
//                               fit: BoxFit.cover,
//                             )
//                                 : Container(
//                               height: 80,
//                               width: 80,
//                               color: Colors.grey,
//                               child: const Center(
//                                 child: Text(
//                                   'No Image',
//                                   style: TextStyle(color: Colors.white),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 10),
//                             // Details section
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     itemName ?? 'Unknown',
//                                     style: const TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 5),
//                                   Text(
//                                     'Price: ₹${itemDetails['price']?.toStringAsFixed(2) ?? '0.00'}',
//                                     style: const TextStyle(
//                                       fontSize: 16,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 5),
//                                   Text(
//                                     'Total: ₹${((itemDetails['price'] ?? 0) * (itemDetails['quantity'] ?? 0)).toStringAsFixed(2)}',
//                                     style: const TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.deepPurple,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             isOutOfStock
//                                 ? Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 const Padding(
//                                   padding: EdgeInsets.symmetric(horizontal: 0),
//                                   child: Text(
//                                     'Out of Stock',
//                                     style: TextStyle(
//                                       color: Colors.red,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ),
//                                 IconButton(
//                                   onPressed: () {
//                                     setState(() {
//                                       removeItemFromCart(itemName);
//                                     });
//                                   },
//                                   icon: const Icon(Icons.delete, color: Colors.red),
//                                 ),
//                               ],
//                             )
//                                 :Row(
//                               children: [
//                                 IconButton(
//                                   onPressed: () {
//                                     setState(() {
//                                       if (itemDetails['quantity'] != null && itemDetails['quantity'] > 1) {
//                                         itemDetails['quantity']--;
//                                         updateItemInDatabase(itemName, itemDetails);
//                                       } else {
//                                         // Remove item from cart and database
//                                         removeItemFromCart(itemName);
//                                       }
//                                     });
//                                   },
//                                   icon: const Icon(Icons.remove),
//                                   color: Colors.white,
//                                   iconSize: 18,
//                                   padding: const EdgeInsets.all(2),
//                                   constraints: const BoxConstraints(),
//                                   splashRadius: 20,
//                                   splashColor: Colors.deepPurple,
//                                   style: ButtonStyle(
//                                     backgroundColor: WidgetStateProperty.all(Colors.deepPurple),
//                                     shape: WidgetStateProperty.all(const CircleBorder()),
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                                   child: Text(
//                                     '${itemDetails['quantity'] ?? 0}',
//                                     style: const TextStyle(fontSize: 16),
//                                   ),
//                                 ),
//                                 IconButton(
//                                   onPressed: () {
//                                     setState(() {
//                                       itemDetails['quantity'] = (itemDetails['quantity'] ?? 0) + 1;
//                                       updateItemInDatabase(itemName, itemDetails);
//                                     });
//                                   },
//                                   icon: const Icon(Icons.add),
//                                   color: Colors.white,
//                                   iconSize: 18,
//                                   padding: const EdgeInsets.all(2),
//                                   constraints: const BoxConstraints(),
//                                   splashRadius: 20,
//                                   splashColor: Colors.deepPurple,
//                                   style: ButtonStyle(
//                                     backgroundColor: WidgetStateProperty.all(Colors.deepPurple),
//                                     shape: WidgetStateProperty.all(const CircleBorder()),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//             ]
//         ),
//       ),
//       bottomNavigationBar: filteredItems.isNotEmpty
//           ?BottomAppBar(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 // mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.only(top: 5),
//                     child: Text(
//                       'Total Amount: ₹${totalAmount.toStringAsFixed(0)}',
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.only(left: 1),
//                     child: Text(
//                       'Number of Items: $totalItems',
//                       style: const TextStyle(
//                         fontSize: 14,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(left: 10),
//                 child: ElevatedButton(
//                   onPressed: hasOutOfStockItems()
//                       ? () {
//                     // Show alert if there are out-of-stock items
//                     _showOutOfStockAlert();
//                   }
//                       : (isCartEmpty || totalAmount == 0)
//                       ? null
//                       : () {
//                     _loadOrderData(totalAmount, orderedItems);
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.deepPurple,
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     fixedSize: const Size(150, 50),
//                   ),
//                   child: const Text('Pay Now'),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       )
//           : const SizedBox.shrink(),
//     );
//   }
// }