import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hedieaty_app/services/database/local/database_helper.dart';
import 'package:hedieaty_app/mainApp/screens/friends_screen.dart';
import 'package:hedieaty_app/mainApp/screens/my_gifts.dart';
import 'package:hedieaty_app/mainApp/screens/my_profile.dart';
import 'package:hedieaty_app/mainApp/widgets/bottom_nav_bar.dart';
import 'package:hedieaty_app/mainApp/widgets/top_home_bar.dart';

import '../screens/all_events_screen.dart';
import '../formScreens//AddEventScreen.dart';
import '../screens/user_event_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final dbHelper = DatabaseHelper.instance;
  int _currentIndex = 0;
  final eventsScreen = EventsScreen(onEventAdded: () {});
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _friends = [];

  @override
  void initState() {
    super.initState();
    _fetchFriends();
  }

  /// Fetch Friends Data
  Future<void> _fetchFriends() async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) {
        throw Exception("No user logged in");
      }
      final friendsSnapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('friends')
          .get();

      final friendsData = friendsSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'firstName': data['firstName'],
          'lastName': data['lastName'],
          'upcomingEventsCount': 0, // Will calculate separately
        };
      }).toList();

      // Fetch upcoming events count for each friend
      for (var friend in friendsData) {
        final eventsSnapshot = await _firestore
            .collection('events')
            .where('userId', isEqualTo: friend['id'])
            .where('status', whereIn: ["Upcoming","Current"])
            .get();
        friend['upcomingEventsCount'] = eventsSnapshot.size;
      }

      setState(() {
        _friends = friendsData;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching friends: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopHomeBar(onMenuSelected: _onMenuSelected),
      body: _friends.isEmpty
          ? Center(child: Text("You don't have friends yet ☹️"))
          : ListView.builder(
        itemCount: _friends.length,
        itemBuilder: (context, index) {
          final friend = _friends[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 5,
            child: ListTile(
              ///Profile picture here
              title: Text(
                '${friend['firstName']} ${friend['lastName']}',
                style: GoogleFonts.roboto(fontSize: 18),
              ),
              subtitle: Text(
                friend['upcomingEventsCount'] > 0
                    ? "Upcoming Events: ${friend['upcomingEventsCount']}"
                    : "No Upcoming Events",
                style: TextStyle(color: Colors.grey[700]),
              ),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navigate to user_event_screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserEventScreen(userId: friend['id']),
                  ),
                );
              },
            ),
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

    if (index == 0) {
      ///Refreshing the home page
      _fetchFriends();
    }else if (index == 1) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) =>  AddFriends()));
    } else if (index == 2) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) =>  MyGifts()));
    } else if (index == 3) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) =>  eventsScreen));
    }else if (index == 4) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) =>  MyProfile()));
    } else if (index == 5) {
      debugDatabase();
    }
    else if (index == 6) {
      debugDeleteTable('nothing');
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

  //calls print local db tables
  void debugDatabase() async {
    await DatabaseHelper.instance.printAllTables();
  }

  //deletes a table from given name
  void debugDeleteTable(String tableName) async {
    await DatabaseHelper.instance.deleteTable(tableName);
  }



}
