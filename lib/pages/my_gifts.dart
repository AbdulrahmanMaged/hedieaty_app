import 'package:flutter/material.dart';

class MyGifts extends StatelessWidget {
  const MyGifts({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Gifts'),
      ),
      body: Center(
        child: TextButton(
          onPressed: () {},
          child: const Text('Gifts here'),
        ),
      ),
    );
  }
}
