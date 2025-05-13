import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = "Loading...";
  String contact = "Loading...";
  String city = "Loading...";
  String email = "Loading...";

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userData =
      await FirebaseFirestore.instance.collection("users").doc(user.uid).get();

      setState(() {
        name = userData["name"];
        contact = userData["contact"];
        city = userData["city"];
        email = userData["email"];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("👤 Name: $name", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("📞 Contact: $contact", style: TextStyle(fontSize: 18)),
            Text("🏙️ City: $city", style: TextStyle(fontSize: 18)),
            Text("📧 Email: $email", style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
