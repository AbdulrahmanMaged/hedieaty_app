import 'package:flutter/material.dart';
import 'package:hedieaty_app/view/screens/welcomeScreen.dart';


class MyPledgedGiftsPage {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hedieaty App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WelcomeScreen(),
    );
  }
}