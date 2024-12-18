import 'package:flutter/material.dart';
import '../widgets/profile.dart'; // Import the ProfilePage widget

class MyProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ProfileWidget(), // Use the ProfilePage widget directly
    );
  }
}
