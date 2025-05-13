import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("About Us")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("📌 Mini Project",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text("Flood Detection System",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Text("👨‍💻 Developers:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("• Sharad Kalathiya", style: TextStyle(fontSize: 16)),
            Text("• Jeel Sonani", style: TextStyle(fontSize: 16)),
            ///Text("• Harikrushna Sakhiya", style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
