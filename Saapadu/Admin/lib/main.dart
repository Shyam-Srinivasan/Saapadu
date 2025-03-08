import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:saapadu/create_shop.dart';
import 'package:saapadu/signup_page.dart';

import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData( // Fix: Provide ThemeData
        primarySwatch: Colors.purple, // Example theme color
        scaffoldBackgroundColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
      home: const SignUpPage(),
      // home: const CreateShop(collegeName: "Rajalakshmi Engineering College"), // Make sure you have a home screen
    );
  }
}
