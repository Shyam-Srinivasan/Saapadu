import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import 'package:lottie/lottie.dart';
import 'package:saapadu/create_shop.dart';
import 'package:saapadu/signin_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _collegeName = TextEditingController();
  final TextEditingController _collegeShortName = TextEditingController();
  final TextEditingController _emailId = TextEditingController();
  final TextEditingController _domainAddress = TextEditingController();
  final TextEditingController _phoneNumber = TextEditingController();
  final TextEditingController _address = TextEditingController();

  @override
  void dispose() {
    _collegeName.dispose();
    _collegeShortName.dispose();
    _emailId.dispose();
    _domainAddress.dispose();
    _phoneNumber.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> saveCredentials() async {
    final databaseRef = FirebaseDatabase.instance.ref("AdminDatabase");
    String collegeName = _collegeName.text.trim();
    String collegeShortName = _collegeShortName.text.trim();
    String emailId = _emailId.text.trim();
    String phoneNumber = _phoneNumber.text.trim();
    String address = _address.text.trim();
    String domainAddress = _domainAddress.text.trim();

    if (collegeName.isEmpty || collegeShortName.isEmpty || emailId.isEmpty || domainAddress.isEmpty || phoneNumber.isEmpty || address.isEmpty) {
      Get.snackbar("Error", "Please fill all the fields", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.black.withOpacity(0.2)),
            ),
            Center(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Lottie.asset("img/Success.json", height: 150),
                    SizedBox(height: 20),
                    Text(
                      "Saving Credentials...",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        );
      }
    );

    final collegeRef = databaseRef.child(collegeName);
    await collegeRef.child("CollegeCredentials").set({
      "College Name": collegeName,
      "College Short Name": collegeShortName,
      "College Email ID": emailId,
      "College Phone Number": phoneNumber,
      "College Domain Address": domainAddress,
    });
    // Get.snackbar("Success", "Credentials Saved Successfully!", backgroundColor: Colors.green, colorText: Colors.white);
    await Future.delayed(Duration(milliseconds: 1500));
    Navigator.pop(context);
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
                "Welcome to Saapadu",
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
                    "Create an Organization not",
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
                        _buildTextField("College Short Name", _collegeShortName, width),
                        _buildTextField("College Email ID", _emailId, width),
                        _buildTextField("College Domain Address", _domainAddress, width),
                        _buildTextField("College Phone Number", _phoneNumber, width),
                        _buildTextField("College Address", _address, width),
                        SizedBox(height: height * 0.025),
                        Center(
                          child: ElevatedButton(
                            onPressed: saveCredentials,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              padding: EdgeInsets.symmetric(horizontal: width * 0.08, vertical: height * 0.015),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text(
                              "Sign Up",
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
                              const Text("Already have an account? "),
                              InkWell(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => SignInPage())
                                  );
                                },
                                child: const Text(
                                  "Sign In",
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
