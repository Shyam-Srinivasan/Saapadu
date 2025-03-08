import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:user/sign_up_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  Future<FirebaseApp> get _fApp => Firebase.initializeApp();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  // final GoogleSignIn _googleSignIn = GoogleSignIn(
  //   clientId: "507312397854-bodt3fpcrl3p4n69au6f62c465jb5oql.apps.googleusercontent.com", // Use Web Client ID
  // );

  bool isLoading = false;
  bool _isPasswordVisible = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _initializeFirebase();
    _passwordFocusNode.addListener(() {
      setState(() {});
    });
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/option');
    }
  }
  Future<String?> getCollegeName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('collegeName'); // Returns null if not found
  }


  Future<void> _signInWithGoogle() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Attempt to sign in with Google
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        // Get Google credentials for Firebase
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Sign in with Firebase using Google credentials
        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        final User? user = userCredential.user;
        String collegeName = await getCollegeName() ?? '';

        if (user != null) {
          // Check if user exists in the database
          DatabaseReference userRef = _database.ref().child('AdminDatabase').child(collegeName).child('UserDatabase').child(user.uid).child("UserCredentials");
          DatabaseEvent event = await userRef.once();
          DataSnapshot snapshot = event.snapshot;

          if (snapshot.value != null) {
            Navigator.pushReplacementNamed(context, '/option');
          } else {
            // User is not in the database, show an error
            _showError('User data not found.');
          }
        } else {
          _showError('Sign-in failed.');
        }
      }
    } catch (error) {
      _showError('Google Sign-In failed: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _initializeFirebase() async {
    await Firebase.initializeApp();
  }

  @override
  void dispose() {
    _passwordFocusNode.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSuccess(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
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



  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showError('Please enter your email address.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await _auth.sendPasswordResetEmail(email: email);
      _showSuccess('Password reset email sent. Please check your inbox.');
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          _showError('Invalid email address.');
          break;
        case 'user-not-found':
          _showError('No user found with this email.');
          break;
        default:
          _showError('An error occurred: ${e.message}');
      }
    } catch (e) {
      _showError('An unexpected error occurred.');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Image.asset(
                  'assets/img/Img.jpeg',
                  width: size.width,
                  height: 300,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 40,
                  left: 80,
                  child: Lottie.asset(
                    'assets/img/LoginAnimation.json',
                    height: 220,
                    width: 250,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 172, top: 262),
                  child: Image.asset(
                    'assets/img/LogoCircle.jpeg',
                    height: 70,
                    width: 70,
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                'Connect With Us!',
                style: TextStyle(fontSize: 28),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 360,
              child: TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'College Email Address',
                  border: UnderlineInputBorder(),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0x61693BB8),
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.deepPurple,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 360,
              child: TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                focusNode: _passwordFocusNode,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const UnderlineInputBorder(),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0x61693BB8),
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.deepPurple,
                      width: 1.5,
                    ),
                  ),
                  suffixIcon: _passwordFocusNode.hasFocus
                      ? IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: _resetPassword,
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
              width: 335,
              height: 50,
              child: TextButton(
                onPressed: _signIn,
                style: TextButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Sign In',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 18)
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            // Your existing "or continue with" section and Google button


            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 70,
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFB39DDB),
                  ),
                ),
                SizedBox(width: 10),
                Text('or continue with', style: TextStyle(color: Colors.black26)),
                SizedBox(width: 10),
                SizedBox(
                  width: 70,
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFB39DDB),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Google Sign-In Button (optional)
            SizedBox(
              width: 200,
              child: TextButton(
                onPressed: _signInWithGoogle,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                      color: Colors.black12,
                      width: 1.0
                  ),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/img/Google.jpeg', width: 35, height: 35),
                    const SizedBox(width: 10),
                    const Text('Google')
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?", style: TextStyle(fontSize: 15)),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          _createRoute(SignUp()),
                      );
                    },
                    child: const Text('Sign Up',
                        style: TextStyle(
                            color: Colors.deepPurple,
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _signIn() async {
    setState(() {
      isLoading = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      String collegeName = await getCollegeName() ?? '';
      if (user != null) {
        if (user.emailVerified) {
          // Once the user signs in, fetch their info from Firebase Database
          DatabaseReference userRef = _database.ref().child('AdminDatabase').child(collegeName).child('UserDatabase').child(user.uid).child("UserCredentials");

          DatabaseEvent event = await userRef.once();
          DataSnapshot snapshot = event.snapshot;

          if (snapshot.value != null) {
            // User exists, navigate to home
            Navigator.pushReplacementNamed(context, '/option');
          } else {
            _showError('User data not found.');
          }
        } else {
          _showError('Please verify your email.');
          await _auth.signOut(); // Sign out if email is not verified
        }
      } else {
        _showError('No user found with this email.');
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          _showError('No user found with this email.');
          break;
        case 'wrong-password':
          _showError('Incorrect password.');
          break;
        case 'invalid-email':
          _showError('Invalid email address.');
          break;
        case 'user-disabled':
          _showError('This user account has been disabled.');
          break;
        case 'too-many-requests':
          _showError('Too many requests. Please try again later.');
          break;
        default:
          _showError('An error occurred: ${e.message}');
      }
    } catch (e) {
      _showError('An unexpected error occurred.');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }



  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}

Route _createRoute(Widget child) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      // const curve = Curves.ease;
      const curve = Curves.ease;


      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 800)
  );
}

