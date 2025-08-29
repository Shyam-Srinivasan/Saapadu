import 'package:flutter/material.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sample Navbar"),

      ),
      body: Center(
        child: Text("Welcome to Dashboard Page"),
      ),
    );
  }
}
