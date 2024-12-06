import 'package:flutter/material.dart';
import 'package:hedieaty_app/database/database_helper.dart';
import 'package:hedieaty_app/pages/home_page.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final dbHelper = DatabaseHelper.instance;
  //await dbHelper.insertDummyUsers(); // Add dummy data
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hedieaty App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}


