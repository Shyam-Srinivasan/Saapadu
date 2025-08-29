import 'package:flutter/material.dart';
import 'navbar.dart';

class Layout extends StatelessWidget {
  final Widget child;
  final String collegeName;
  final bool hideNavbar;

  const Layout({
    super.key,
    required this.child,
    required this.collegeName,
    this.hideNavbar = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!hideNavbar) TopNavbar(collegeName: collegeName),
        Expanded(child: child),
      ],
    );
  }
}
