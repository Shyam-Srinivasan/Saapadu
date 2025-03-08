import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'qr_code_page.dart'; // Import the QR code page

class PaymentService extends StatefulWidget {
  final double totalAmount;
  final List<Map<String, dynamic>> orderedItems;
  final String uniqueKey;
  final String orderId;
  final String? shopName;
  final String? userId;
  final String timestamp;

  const PaymentService({
    Key? key,
    required this.totalAmount,
    required this.orderedItems,
    required this.uniqueKey,
    required this.orderId,
    required this.shopName,
    required this.userId,
    required this.timestamp,
  }) : super(key: key);

  @override
  _PaymentServiceState createState() => _PaymentServiceState();
}

class _PaymentServiceState extends State<PaymentService> {
  late Razorpay _razorpay;


  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _openCheckout();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _openCheckout() {
    var options = {
      'key': 'rzp_test_KpwjrNTYp5KW3l', // Replace with your Razorpay key
      'amount': widget.totalAmount * 100, // Amount in paise
      'name': 'RMart',
      'description': 'Payment for Order ID: ${widget.orderId}',
      'prefill': {
        'contact': '9025238389', // Replace with user's phone number
        'email': '220701508@rajalakshmi.edu.in', // Replace with user's email
      },
      'method': {
        'upi': true, // Enable UPI
        'card': true, // Enable Card Payment
        'netbanking': true, // Enable Net Banking
        'wallet': true, // Enable Wallets
      },
      'external': {
        'wallets': ['paytm', 'phonepe', 'gpay'] // Optional: External wallets
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Payment succeeded, save order data to Firebase
    _saveOrderDataToFirebase();

    // Reduce item quantity in the database
    _updateItemQuantityInDatabase();

    // Clear the cart items from user firebase
    _clearCartItems();

    // Redirect to QR Code Page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QrCodePage(
          totalAmount: widget.totalAmount,
          orderedItems: widget.orderedItems,
          uniqueKey: widget.uniqueKey,
        ),
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Handle payment failure
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text('Payment failed: ${response.message}'),
    //   ),
    // );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Failed'),
        content: Text('Payment failed: ${response.message ?? "Unknown Error"}'),
        actions: [
          TextButton(
            onPressed: (){
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          )
        ],
      )
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Handle external wallet
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External wallet selected: ${response.walletName}'),
      ),
    );
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

  void _saveOrderDataToFirebase() async{
    String? collegeName = await getCollegeName();
    String? shopName = await getCollegeName();
    String? userId = await getCurrentUserId();

    DatabaseReference databaseRef = FirebaseDatabase.instance.ref();
    // Save order data to UserDatabase
    databaseRef.child('AdminDatabase/$collegeName/UserDatabase/$userId/OrderedList/${widget.orderId}').set({
      'shop': widget.shopName,
      'isPurchased': false, // Mark as purchased
      'timestamp': widget.timestamp,
      'totalAmount': widget.totalAmount,
      'orderItems': widget.orderedItems,
      'uniqueKey': widget.uniqueKey,
    });

    // Save order data to AdminDatabase
    databaseRef.child('AdminDatabase/$collegeName/UserPurchasedItems/$userId/OrderedList/${widget.orderId}').set({
      'shop': widget.shopName,
      'isPurchased': false, // Mark as purchased
      'timestamp': widget.timestamp,
      'totalAmount': widget.totalAmount,
      'orderItems': widget.orderedItems,
    });
  }

  void _clearCartItems() async{
    DatabaseReference databaseRef = FirebaseDatabase.instance.ref();
    String? collegeName = await getCollegeName();
    String? shopName = await getSelectedShop();
    String? userId = await getCurrentUserId();

    // Clear the cart items from Firebase
    databaseRef.child('AdminDatabase/$collegeName/UserDatabase/$userId/CartItems/$shopName').remove().then((_) {
    }).catchError((error) {
    });
  }

  void _updateItemQuantityInDatabase() async {
    String? collegeName = await getCollegeName();
    String? shopName = await getSelectedShop();
    DatabaseReference databaseRef = FirebaseDatabase.instance.ref();

    for (var item in widget.orderedItems) {
      String itemName = item['name'];
      int orderedQuantity = item['quantity'];

      String categoryName = await _findCategory(itemName);
      DatabaseReference itemRef = databaseRef.child('AdminDatabase/$collegeName/Shops/$shopName/Categories/$categoryName/$itemName/quantity');

      DataSnapshot snapshot = await itemRef.get();
      if (snapshot.exists && snapshot.value != null) {
        int currentQuantity = snapshot.value as int;
        int newQuantity = (currentQuantity - orderedQuantity).clamp(0, currentQuantity); // Prevent negative values

        print("Current Quantity: $currentQuantity");
        print("New Quantity after deduction: $newQuantity");

        // Update the quantity in the database
        await itemRef.set(newQuantity);
      }
    }
  }
  // Function to find the category based on the item name
  Future<String> _findCategory(String itemName) async{
    String? collegeName = await getCollegeName();
    String? shopName = await getSelectedShop();
    DatabaseReference categoriesRef = FirebaseDatabase.instance.ref().child('AdminDatabase/$collegeName/Shops/$shopName/Categories/');
    DataSnapshot snapshot = await categoriesRef.get();

    if (snapshot.exists && snapshot.value is Map) {
      Map<dynamic, dynamic> categories = snapshot.value as Map<dynamic, dynamic>;

      for (String category in categories.keys) {
        if (categories[category] is Map && categories[category].containsKey(itemName)) {
          print("Category name is $category");
          return category;
        }
      }
    }
    return "UnknownCategory"; // Fallback
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Gateway'),
      ),
      body: const Center(
        child: CircularProgressIndicator(), // Show loading indicator
      ),
    );
  }
}