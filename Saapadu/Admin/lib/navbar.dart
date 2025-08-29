import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TopNavbar extends StatelessWidget {
  final String collegeName;

  const TopNavbar({super.key, required this.collegeName});

  void logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/signIn');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            collegeName,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
                child: Text('Home', style: TextStyle(color: Colors.white)),
              ),
              TextButton(
                onPressed: () {
                  // Navigator.popAndPushNamed(context, '/shops');
                  Navigator.pushReplacementNamed(context, '/shops');
                  
                },
                child: Text('Shops', style: TextStyle(color: Colors.white)),
              ),
              TextButton(
                onPressed: () {},
                child: Text('Orders', style: TextStyle(color: Colors.white)),
              ),
              TextButton(
                onPressed: () {},
                child: Text('Payment', style: TextStyle(color: Colors.white)),
              ),
              TextButton(
                onPressed: (){logout(context);},
                child: Text('Logout', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
