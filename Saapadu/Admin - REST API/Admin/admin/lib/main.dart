import 'package:admin/signin_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'create_shop.dart';
import 'signup_page.dart';

void main() {
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
      home: const AuthGate(),
      // home: const CreateShop(collegeName: "Rajalakshmi Engineering College"), // Make sure you have a home screen
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

  Future<String?> _getCollegeName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('collegeName');
  }

  Future<bool> _checkLoginStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('loggedIn') ?? false;
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
            return FutureBuilder<String?>(
              future: _getCollegeName(),
              builder: (context, collegeSnapshot) {
                if (collegeSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  final collegeName = collegeSnapshot.data ?? '';
                  return CreateShop(collegeName: collegeName);
                }
              },
            );
          } else {
            return const SignUpPage();
          }
        }
      },
    );
  }
}