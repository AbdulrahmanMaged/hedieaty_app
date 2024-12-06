import 'package:flutter/material.dart';

class AddFriends extends StatelessWidget {
  const AddFriends({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add freinds screen'),
      ),
      body: Center(
        child: TextButton(
          onPressed: () {},
          child: const Text('add freinds here'),
        ),
      ),
    );
  }
}