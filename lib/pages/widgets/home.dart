import 'package:flutter/material.dart';
import 'package:hedieaty_app/pages/add_friends.dart';
import 'package:hedieaty_app/pages/my_gifts.dart';
import 'package:hedieaty_app/pages/my_profile.dart';
import 'package:hedieaty_app/pages/widgets/bottom_nav_bar.dart';
import 'package:hedieaty_app/pages/widgets/top_home_bar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: TopHomeBar(onMenuSelected: _onMenuSelected),
        body: const Center(
          child: Text('Home Page Here'),
        ),
        bottomNavigationBar: BottomNavBar(
          currentIndex: _currentIndex,
          onTap: _onNavBarTapped,
        ),
      );
    }

    // Method to handle navigation from the bottom nav bar
    int _currentIndex = 0;
    void _onNavBarTapped(int index) {
      setState(() {
        _currentIndex = index;
      });

      if (index == 1) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const AddFriends()));
      } else if (index == 4) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const MyProfile()));
      } else if (index == 2) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const MyGifts()));
      } else if (index == 3) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const MyProfile()));
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


  }

