import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:user/select_organization.dart';
import 'package:user/shop_option.dart';
import 'package:user/sign_in_page.dart'; // Import the sign_in_page.dart
import 'package:user/sign_up_page.dart';
import 'firebase_options.dart';
import 'home_page.dart';
import 'cart.dart';
import 'orders.dart';
import 'splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Razorpay _razorpay = Razorpay();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // await FirebaseAppCheck.instance.activate(
  //   webProvider: ReCaptchaV3Provider('LfwvesqAAAAAHVnhSVU9QIF4M5EXZcyTjNF6JT1'),
  //   androidProvider: AndroidProvider.playIntegrity,
  //   appleProvider: AppleProvider.deviceCheck,
  // );
  FirebaseAuth.instance.setLanguageCode("en"); // Change "en" to your preferred language
  FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive); // Fullscreen mode
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "RMart",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/auth': (context) => const AuthGate(),
        '/orders': (context) => const OrdersPage(),
        '/cart': (context) => const CartPage(),
        '/option': (context) => const ShopOption(),
        '/home': (context) => const Homepage(),
        '/sel_clg': (context) => const CollegeSelection(),
        '/signIn': (context) => const SignIn(),
        '/signUp': (context) => const SignUp(),
      },
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  _AuthGateState createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late Future<bool> _loginCheck;

  @override
  void initState() {
    super.initState();
    _loginCheck = _checkLoginStatus();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _loginCheck,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else {
          if (snapshot.data == true) {
            return const Homepage(); // Navigate to home page
          } else {
            return const SignIn(); // Navigate to sign in page
          }
        }
      },
    );
  }

  Future<bool> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool loggedIn = prefs.getBool('loggedIn') ?? false;
    return loggedIn;
  }
}
