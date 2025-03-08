import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:user/select_organization.dart';
import 'package:user/sign_in_page.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';



class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  // Variables to track whether the passwords are visible
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void initState() {
    super.initState();
    _passwordFocusNode.addListener(() {
      setState(() {});
    });
    _confirmPasswordFocusNode.addListener(() {
      setState(() {});
    });
  }
  // Google Sign-In Function
  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        final User? user = userCredential.user;

        if (user != null) {
          _saveUserData(user.uid, user.displayName ?? '', user.email ?? '');
          Navigator.pushReplacementNamed(context, '/option');
          _showSuccess('Successfully signed in with Google');
        }
      }
    } catch (e) {
      _showError('Failed to sign in with Google: $e');
    }
  }

  @override
  void dispose() {
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 50),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.end,
            //   children: [
            //     Padding(
            //       padding: const EdgeInsets.only(right: 30, top: 20),
            //       child: Image.asset(
            //         'assets/img/Logo.jpeg',
            //         height: 70,
            //         width: 70,
            //       ),
            //     )
            //   ],
            // ),
            // CollegeSelection(),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 20.0),
                child: Text(
                  'Welcome!',
                  style: TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text('Please sign up to get started', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300)),
              ),
            ),
            const SizedBox(height: 30),
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
            const SizedBox(height: 20),
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
            SizedBox(
              width: 360,
              child: TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
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
            const SizedBox(height: 20),
            SizedBox(
              width: 360,
              child: TextField(
                controller: _confirmPasswordController,
                obscureText: !_isConfirmPasswordVisible,
                focusNode: _confirmPasswordFocusNode,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
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
                  suffixIcon: _confirmPasswordFocusNode.hasFocus
                      ? IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: 335,
              height: 50,
              child: TextButton(
                onPressed: _signUp,
                style: TextButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white
                ),
                child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Sign Up',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold
                          )
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 18)
                    ]
                ),
              ),
            ),
            const SizedBox(height: 15),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?", style: TextStyle(fontSize: 15)),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                        _createRoute(SignIn())
                      );
                    },
                    child: const Text('Sign In', style: TextStyle(color: Colors.deepPurple, fontSize: 15, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<String?> getCollegeName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('collegeName'); // Returns null if not found
  }


  void _signUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty) {
      _showError('Please enter a valid Name');
      return;
    }

    if (email.isEmpty) {
      _showError('Please enter a valid Email Address');
      return;
    }

    if (!_isValidPassword(password)) {
      _showError('Password must be at least 8 characters long, include an uppercase letter, a lowercase letter, a digit, and a special character');
      return;
    }

    if (password != confirmPassword) {
      _showError('Passwords do not match');
      return;
    }
    if (!await _isValidEmail(email)) {  // Await the email validation
      _showError('Please enter a valid College Mail ID');
      return;
    }

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update the displayName of the user
      await _registerUser(email, password, name);

      final user = userCredential.user;
      if (user != null) {
        await user.sendEmailVerification(); // Send verification email
        _saveUserData(user.uid, name, email);
        _showSuccess('Check your email for verification');
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<bool> _isValidEmail(String email) async {
    String collegeName = await getCollegeName() ?? '';
    try{
    DatabaseReference collegeRef = _database.ref("AdminDatabase").child(collegeName).child("CollegeCredentials").child("College Domain Address");
    DatabaseEvent event = await collegeRef.once();
    final collegeDomain = event.snapshot.value;
    print("College Domain Address from DB: $collegeDomain");

    if (collegeDomain != null) {
      return email.endsWith(collegeDomain.toString());
    } else {
      return false; // If domain is not found, return false
    }
  } catch (e) {
  print("Error fetching college domain: $e");
  return false;
  }
}

  bool _isValidPassword(String password) {
    if (password.isEmpty) {
      false;
    }
    final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
    return passwordRegex.hasMatch(password);
  }


  // Register user and update displayName
  Future<void> _registerUser(String email, String password, String name) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Update displayName
        await user.updateDisplayName(name);
        await user.reload();

        // Fetch the updated user
        User? updatedUser = _auth.currentUser;
        setState(() {
          // Update the state to reflect the new displayName
          user = updatedUser;
        });
      }
    } catch (e) {
      print('Error updating displayName: $e');
    }
  }

  void _saveUserData(String userId, String name, String email) async {
    final String collegeName = await getCollegeName() ?? '';
    final collegeRef = _database.ref().child('AdminDatabase').child(collegeName).child('UserDatabase').child(userId).child("UserCredentials");

    final userData = {
      'name': name,
      'email': email,
    };

    // Save user data in both the UserDatabase and AdminDatabase
    await collegeRef.set(userData);
    await collegeRef.set(userData);
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
}


Route _createRoute(Widget child) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(-1.0, 0.0);
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