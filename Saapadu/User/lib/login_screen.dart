import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Future<FirebaseApp> get _fApp => Firebase.initializeApp();
  bool isLoading = false;
  bool _isVisible = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  String? _verificationId;
  bool _isOtpSent = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/option');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.white,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(4.0),
          child: Divider(
            height: 4.0,
            thickness: 1,
            color: Color(0x61693BB8),
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Lottie Animation for branding
                  Container(
                    alignment: Alignment.center,
                    height: 200,
                    child: Image.asset('assets/img/Logo.jpeg', height: 180, width: 180,),
                  ),
                  const SizedBox(height: 20),
                  const Text('Name'),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('College Email ID'),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Phone Number'),
                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        _sendOtp();
                        setState(() {
                          _isVisible = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        fixedSize: const Size(150, 50),
                      ),
                      child: const Text('Generate OTP'),
                    ),
                  ),
                  const SizedBox(height: 50),
                  Visibility(
                    visible: _isVisible,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Text('OTP', style: TextStyle(fontSize: 18),),
                            ),
                            const SizedBox(width: 12),
                            Center(
                              child: SizedBox(
                                width: 250,
                                height: 50,
                                child: TextField(
                                  controller: _otpController,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _verifyOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            fixedSize: const Size(150, 50),
                          ),
                          child: const Text('Verify'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (isLoading)
            Stack(
              children: [
                const Opacity(
                  opacity: 0.6,
                  child: ModalBarrier(
                    dismissible: false,
                    color: Colors.black,
                  ),
                ),
                Center(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset('assets/img/DinnerLoading.json', width: 200, height: 200),
                        const SizedBox(height: 20),
                        const Text(
                          'Please wait...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _sendOtp() async {
    final phoneNumber = _phoneController.text.trim();
    final email = _emailController.text.trim();

    if (!_isValidEmail(email)) {
      _showError('Please enter a valid College Mail ID');
      return;
    }

    if (phoneNumber.isEmpty) {
      _showError('Please enter a valid Phone Number');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: '+91$phoneNumber', // Use your country's code if needed
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          _showError(e.message ?? 'Verification failed');
          setState(() {
            isLoading = false;
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _isOtpSent = true;
            isLoading = false;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      _showError('An error occurred while sending OTP');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _verifyOtp() async {
    final otp = _otpController.text.trim();

    if (_verificationId == null || otp.isEmpty) {
      _showError('Invalid OTP or Verification ID');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      // Save login status in shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      // Save user data to Realtime Database
      _saveUserData(userCredential.user);

      // Navigate to the next page after successful login
      Navigator.pushReplacementNamed(
        context,
        '/option',
        arguments: {
          'email': _emailController.text.trim(),
          'name': _nameController.text.trim(),
        },
      );
    } catch (e) {
      _showError('Invalid OTP');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _saveUserData(User? user){
    if (user == null) return;

    // 5 digits user ID
    final shortUserId = user.uid.length >= 6 ? user.uid.substring(0, 6) : user.uid;

    final userRef = _database.ref().child('UserDatabase').child(shortUserId);
    final adminUserRef = _database.ref().child('AdminDatabase').child('UsersCredentials').child(shortUserId);

    // User data to save
    final userData = {
      'UserCredentials' :{
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
      },
    };


    // Save data in UserDatabase
    userRef.set(userData);


    // Save user credentials in AdminDatabase
    adminUserRef.set(userData['UserCredentials']);

    /* userRef.child('UserCredentials').set({
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
    }); */
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@rajalakshmi\.edu\.in$');
    return emailRegex.hasMatch(email);
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
