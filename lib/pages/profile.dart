import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  const Profile({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: TextButton(
          onPressed: () {},
          child: const Text('Next'),
        ),
      ),
    );
  }
}