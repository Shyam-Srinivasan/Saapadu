import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:saapadu/signup_page.dart';
import 'create_shop.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final collegeName = prefs.getString('collegeName');
  final emailId = prefs.getString('emailId');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp(collegeName: collegeName, emailId: emailId));
}

class MyApp extends StatelessWidget {
  final String? collegeName;
  final String? emailId;
  const MyApp({super.key, this.collegeName, this.emailId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData( // Fix: Provide ThemeData
        primarySwatch: Colors.purple, // Example theme color
        scaffoldBackgroundColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
      home: collegeName != null ? CreateShop(collegeName: collegeName!) : const SignUpPage(),
      // home: const SignUpPage(),
      // home: const CreateShop(collegeName: "Rajalakshmi Engineering College"), // Make sure you have a home screen
    );
  }
}
