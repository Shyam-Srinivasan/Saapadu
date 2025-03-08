import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user/sign_up_page.dart';

class CollegeSelection extends StatefulWidget {
  const CollegeSelection({super.key});

  @override
  _CollegeSelectionState createState() => _CollegeSelectionState();
}

class _CollegeSelectionState extends State<CollegeSelection> {
  final TextEditingController _searchController = TextEditingController();
  final DatabaseReference _databaseRef =
  FirebaseDatabase.instance.ref().child("AdminDatabase");
  List<String> _collegeList = [];
  List<String> _filteredColleges = [];

  @override
  void initState() {
    super.initState();
    _fetchColleges();
    _searchController.addListener(_filterColleges);
  }

  void _fetchColleges() {
    _databaseRef.once().then((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> colleges =
        Map<dynamic, dynamic>.from(event.snapshot.value as Map);
        List<String> fetchedColleges = colleges.keys.cast<String>().toList();
        setState(() {
          _collegeList = fetchedColleges;
          _filteredColleges = fetchedColleges;
        });
      }
    });
  }

  void _filterColleges() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredColleges = _collegeList
          .where((college) => college.toLowerCase().contains(query))
          .toList();
    });
  }

  void saveCollegeName(String collegeName) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('collegeName', collegeName);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints){
        double width = constraints.maxWidth;
        double height = constraints.maxHeight;
        return Scaffold(
          appBar: AppBar(
            title: Center(
                child: Text(
                    "Select Your College",
                  style: TextStyle(
                    letterSpacing: 1.5,
                  ),
                )
            ),
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: "Search College",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: _filteredColleges.isEmpty
                      ? Center(child: Text("No colleges found"))
                      : ListView.builder(
                    itemCount: _filteredColleges.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_filteredColleges[index]),
                        onTap: () {
                          // Navigator.pop(context, _filteredColleges[index]);
                          saveCollegeName(_filteredColleges[index]);

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignUp()

                          )
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}
