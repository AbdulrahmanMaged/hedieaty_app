import 'package:flutter/material.dart';
import 'package:hedieaty_app/pages/sidePages/newEvent.dart';
import 'package:hedieaty_app/pages/sidePages/edit_or_new_gift.dart';
import 'package:hedieaty_app/pages/widgets/bottom_nav_bar.dart';
import 'package:hedieaty_app/pages/widgets/top_home_bar.dart'; // Import the top bar file

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // Method to handle navigation from the bottom nav bar
  void _onNavBarTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 1) {
      //Navigator.push(context, MaterialPageRoute(builder: (context) => const AddFriendPage()));
    } else if (index == 4) {
      //Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
    } else if (index == 2) {
      //Navigator.push(context, MaterialPageRoute(builder: (context) => const MyGiftsPage()));
    } else if (index == 3) {
      //Navigator.push(context, MaterialPageRoute(builder: (context) => const EventListPage()));
    }

  }

  // Method to handle the selection from the top bar dropdown menu
  void _onMenuSelected(String value) {
    if (value == 'new_event') {
      //Navigator.push(context, MaterialPageRoute(builder: (context) => const NewEventPage()));
    } else if (value == 'edit_or_new_gift') {
      //Navigator.push(context, MaterialPageRoute(builder: (context) => const NewGiftListPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopHomeBar(onMenuSelected: _onMenuSelected),
      body: const Center(
        child: Text('Home Page Content Here'),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTapped,
      ),
    );
  }
}
