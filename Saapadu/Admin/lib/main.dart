import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:saapadu/create_shop.dart';
import 'package:saapadu/home_page.dart';
import 'package:saapadu/homepage.dart';
import 'package:saapadu/signin_page.dart';
import 'package:saapadu/signup_page.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'dashboard.dart';
import 'firebase_options.dart';
import 'layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final collegeName = prefs.getString('collegeName');
  final emailId = prefs.getString('emailId');
  print(collegeName);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp(collegeName: collegeName, emailId: emailId));
}

class MyApp extends StatelessWidget {
  final String? collegeName;
  final String? emailId;

  const MyApp({super.key, this.collegeName, this.emailId});

  @override
  Widget build(BuildContext context) {
    print("${collegeName} dsdsdsd");
    return MaterialApp(
      initialRoute: collegeName == null ? '/signIn' : '/dashboard',
      routes: {
        '/signIn': (context) => SignInPage(),
        '/signUp': (context) => SignUpPage(),
        '/home':
            (context) => Layout(
              collegeName: collegeName ?? "Saapadu",
              child: NewHomePage()
            ),
        '/shops':
            (context) => Layout(
              collegeName: collegeName ?? "Saapadu",
              child: CreateShop(collegeName: collegeName ?? " ")
            ),
        '/dashboard':
            (context) => Layout(
              collegeName: collegeName ?? "Saapadu",
              child: Dashboard(),
            ),
      },

      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
