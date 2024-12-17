import 'package:flutter/material.dart';
import 'package:hedieaty_app/services/database/local/database_helper.dart';
import 'package:hedieaty_app/view/screens/friends.dart';
import 'package:hedieaty_app/view/screens/my_gifts.dart';
import 'package:hedieaty_app/view/screens/my_profile.dart';
import 'package:hedieaty_app/view/widgets/bottom_nav_bar.dart';
import 'package:hedieaty_app/view/widgets/top_home_bar.dart';

import '../../services/database/local/user.dart';
import '../screens/events_screen.dart';
import '../sideScreens/AddEventScreen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final dbHelper = DatabaseHelper.instance;
  int _currentIndex = 0;
  final eventsScreen = EventsScreen(onEventAdded: () {});


  // Fetch users from the database
  Future<List<User>> _fetchUsers() async {
    final usersData = await dbHelper.getUsers();
    return usersData.map((data) => User.fromMap(data)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopHomeBar(onMenuSelected: _onMenuSelected),
      body: FutureBuilder<List<User>>(
        future: _fetchUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          final users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(user.name[0].toUpperCase()),
                ),
                title: Text(user.name),
                subtitle: Text(user.email),
                trailing: Text(user.preferences ?? 'No preferences'),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTapped,
      ),
    );
  }

  // Handle navigation from the bottom nav bar
  void _onNavBarTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 1) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) =>  AddFriends()));
    } else if (index == 4) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) =>  MyProfile()));
    } else if (index == 2) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) =>  MyGifts()));
    } else if (index == 3) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) =>  EventsScreen(onEventAdded: eventsScreen.createState().fetchEvents,)));
    }
  }

  // Handle the selection from the top bar dropdown menu
  void _onMenuSelected(String value) {
    if (value == 'new_event') {
// Navigate to AddEventScreen and pass the _fetchEvents callback
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddEventScreen(
            onEventAdded: eventsScreen.createState().fetchEvents,
          ),
        ),
      );
    } else if (value == 'edit_or_new_gift') {
      // Navigate to the new gift list page
    }
  }

}
