import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(
      'assets/img/Logo.mp4',
    )
    ..initialize().then((_){
      setState(() {});
    })
    ..setVolume(0.0);
    _playVideo();

  }

  void _checkAuthentication() async{
    User? user = FirebaseAuth.instance.currentUser;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? collegeName = prefs.getString('collegeName'); // Retrieve from SharedPreferences
    if (user != null && user.emailVerified && collegeName != null) {
      // If user is authenticated and email is verified, navigate to home page
      Navigator.of(context).pushReplacementNamed('/option');
    } else {
      // If user is not authenticated, redirect to SignIn page
      Navigator.of(context).pushReplacementNamed('/sel_clg');
    }
  }

  void _playVideo() async{
    _controller.play();
    await Future.delayed(const Duration(seconds: 4));
    // Navigator.pushNamed(context, '/option');
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _checkAuthentication();

  }

  @override
  void dispose(){
    _controller.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: _controller.value.isInitialized
        ? AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(
            _controller,
          ),
        )
        : Container(),
      ),
    );
  }
}
