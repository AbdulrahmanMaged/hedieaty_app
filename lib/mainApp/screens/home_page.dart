import 'package:flutter/material.dart';
import 'package:hedieaty_app/mainApp/widgets/home.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
 
 @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Home(),
    );
  }
}

