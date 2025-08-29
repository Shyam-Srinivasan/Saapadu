import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewHomePage extends StatelessWidget {
  const NewHomePage({super.key});
  
  // void getCollegeName() async{
  //   final preferences = SharedPreferences.getInstance();
  //   final String collegeName = preferences.getString("collegeName");
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              margin: const EdgeInsets.symmetric(vertical: 25, horizontal: 0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    StatsTile(name: 'Total Orders', data: '123'),
                    SizedBox(width: 16),
                    StatsTile(name: 'Pending Orders', data: '12'),
                    SizedBox(width: 16),
                    StatsTile(name: 'Completed Orders', data: '111'),
                    SizedBox(width: 16),
                    StatsTile(name: 'Total Revenue', data: '1,23,456'),
                  ],
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Orders',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const RecentOrdersTable(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatsTile extends StatelessWidget {
  final String name;
  final String data;

  const StatsTile({Key? key, required this.name, required this.data})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isRevenue = name == 'Total Revenue';
    return Container(
      width: MediaQuery.of(context).size.width > 992 ? 160 : 96,
      height: MediaQuery.of(context).size.width > 992 ? 208 : 128,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF29292c),
        borderRadius: BorderRadius.circular(
          MediaQuery.of(context).size.width > 992 ? 16 : 5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Glow and border effects (simplified)
          Positioned(
            top: -40,
            left: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Colors.white.withOpacity(0.1), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            right: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Colors.white.withOpacity(0.1), Colors.transparent],
                ),
              ),
            ),
          ),
          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
                child: Text(
                  name,
                  style: TextStyle(
                    color: const Color(0xFF32a6ff),
                    fontWeight: FontWeight.w500,
                    fontSize: MediaQuery.of(context).size.width > 992 ? 18 : 12,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    isRevenue ? '₹ $data' : data,
                    style: TextStyle(
                      color: const Color(0xFFc2c2c6),
                      fontWeight: FontWeight.w700,
                      fontSize:
                          MediaQuery.of(context).size.width > 992 ? 22 : 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RecentOrdersTable extends StatelessWidget {
  const RecentOrdersTable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Placeholder for the recent orders table
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Text('Recent orders table goes here'),
    );
  }
}
