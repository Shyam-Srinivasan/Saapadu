import 'package:flutter/material.dart';

// Custom route for slide up and down transition
class SlideUpPageRoute extends PageRouteBuilder {
  final Widget page;

  SlideUpPageRoute({required this.page})
      : super(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Define the transition animation
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween = Tween<Offset>(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      // For the reverse animation
      var reverseTween = Tween<Offset>(begin: end, end: begin).chain(CurveTween(curve: curve));
      var reverseOffsetAnimation = secondaryAnimation.drive(reverseTween);

      // Choose the correct animation based on status
      return SlideTransition(
        position: animation.status == AnimationStatus.reverse
            ? reverseOffsetAnimation
            : offsetAnimation,
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 3000), // Duration of the transition
    reverseTransitionDuration: const Duration(milliseconds: 3000), // Reverse duration
  );
}
