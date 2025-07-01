import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saapadu/create_shop.dart';
import 'package:saapadu/signup_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _collegeName = TextEditingController();
  final TextEditingController _emailId = TextEditingController();

  @override
  void dispose() {
    _collegeName.dispose();
    _emailId.dispose();
    super.dispose();
  }

  void signIn() async{
    String collegeName = _collegeName.text.trim();
    String emailId = _emailId.text.trim();

    if (collegeName.isEmpty || emailId.isEmpty) {
      Get.snackbar("Error", "Please fill all the fields", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    // Save session info
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('collegeName', collegeName);
    await prefs.setString('emailId', emailId);

    // Get.snackbar("Success", "Signed in Successfully!", backgroundColor: Colors.green, colorText: Colors.white);
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CreateShop(collegeName: collegeName,))
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        return Scaffold(
          appBar: AppBar(
            title: const Center(
              child: Text(
                "Welcome Back!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            backgroundColor: Colors.deepPurple,
          ),
          body: SingleChildScrollView(
            child: Container(
              width: width,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? width * 0.05 : width * 0.2, vertical: height * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Sign In to Your Account",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: isSmallScreen ? 24 : 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: height * 0.03),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 0.5),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 3,
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTextField("College Name", _collegeName, width),
                        _buildTextField("College Email ID", _emailId, width),
                        SizedBox(height: height * 0.025),
                        Center(
                          child: ElevatedButton(
                            onPressed: signIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              padding: EdgeInsets.symmetric(horizontal: width * 0.08, vertical: height * 0.015),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text(
                              "Sign In",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isSmallScreen ? 16 : 18,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: height * 0.025),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Don't have an account? "),
                              InkWell(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => SignUpPage())
                                  );
                                },
                                child: const Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    color: Colors.deepPurple,
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, double width) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          SizedBox(height: 5),
          SizedBox(
            width: width * 0.9,
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0x61693BB8),
                    width: 1.0,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepPurple, width: 1.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
