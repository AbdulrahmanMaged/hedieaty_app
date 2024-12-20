import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hedieaty_app/services/database/sqlite/database_helper.dart';
import 'package:hedieaty_app/mainApp/screens/friends_screen.dart';
import 'package:hedieaty_app/mainApp/screens/my_gifts.dart';
import 'package:hedieaty_app/mainApp/screens/my_profile.dart';
import 'package:hedieaty_app/mainApp/widgets/bottom_nav_bar.dart';
import 'package:hedieaty_app/mainApp/widgets/top_home_bar.dart';
import 'package:intl/intl.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../formScreens/editAddInEvents.dart';
import '../screens/all_events_screen.dart';
import '../formScreens//addEventScreen.dart';
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
  List<Map<String, dynamic>> _filteredFriends = []; // Filtered list for search
  final TextEditingController _searchController = TextEditingController(); // Controller for search input
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _fetchFriends();
    requestNotificationPermission();
    // Listen to messages when the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Message received: ${message.notification?.title}');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(message.notification?.title ?? "No Title"),
          content: Text(message.notification?.body ?? "No Body"),
        ),
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose(); // Dispose controller
    super.dispose();
  }


  Future<void> requestNotificationPermission() async {
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('user permission granted')),
      );
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('user permission granted once')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('user permission not granted')),
      );
    }
  }


  /// Fetch Friends Data
  Future<void> _fetchFriends() async {
    try {
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
            .where('status', whereIn: ["Upcoming", "Current"])
            .get();
        friend['upcomingEventsCount'] = eventsSnapshot.size;
      }

      setState(() {
        _friends = friendsData;
        _filteredFriends = friendsData; // Initially show all friends
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching friends: $e')),
      );
    }
  }

  /// Filter friends based on search query
  void _filterFriends() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredFriends = _friends; // Show all friends if search is empty
      });
      return;
    }

    setState(() {
      _filteredFriends = _friends.where((friend) {
        final firstName = friend['firstName'].toLowerCase();
        final lastName = friend['lastName'].toLowerCase();
        return firstName.contains(query) || lastName.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopHomeBar(onMenuSelected: _onMenuSelected),
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.search, color: Colors.purple),
                  onPressed: _filterFriends, // Trigger search on icon press
                ),
              ],
            ),
          ),
          // Friends List
          Expanded(
            child: _filteredFriends.isEmpty
                ? Center(child: Text("No friends found ☹️"))
                : ListView.builder(
              itemCount: _filteredFriends.length,
              itemBuilder: (context, index) {
                final friend = _filteredFriends[index];
                return Card(
                  margin:
                  EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                  child: ListTile(
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
                    trailing: Row(
                      mainAxisSize: MainAxisSize
                          .min, // Ensures the Row takes only the necessary space
                      children: [
                        Text(
                          'View events',
                          style: TextStyle(
                              fontSize: 14, color: Colors.purple),
                        ),
                        SizedBox(
                            width:
                            4), // Add spacing between the label and icon
                        Icon(Icons.arrow_forward_ios,
                            size: 16, color: Colors.purple),
                      ],
                    ),
                    onTap: () {
                      // Navigate to user_event_screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              UserEventScreen(userId: friend['id']),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
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
     //debugprintTable('Gifts');
    }
    else if (index == 6) {
      debugDeleteTable('Gifts');
      //debugprintTable('Gifts');
      //debugDeleteAll();
    }
  }
  void _showEventPicker(BuildContext context) async {
    // Fetch events for the current user
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: User not authenticated!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    List<Map<String, dynamic>> userEvents = [];

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('userId', isEqualTo: currentUserId)
          .get();

      userEvents = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'],
          'status': data['status'],
          'date': data['date'],
        };
      }).toList();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching events: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show the dialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Pick an event to add a new gift in',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
          content: userEvents.isEmpty
              ? Text(
            'No events found',
            style: TextStyle(color: Colors.grey),
          )
              : Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: userEvents.length,
              itemBuilder: (context, index) {
                final event = userEvents[index];
                return ListTile(
                  contentPadding: EdgeInsets.all(10),
                  title: Text(event['name'], style: TextStyle(fontSize: 18)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status: ${event['status']}'),
                      SizedBox(height: 2),
                      Text(
                        'Date: ${event['date'] != null ? DateFormat('dd-MMM-yyyy').format(event['date'].toDate()) : 'N/A'}',
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min, // Ensures the Row takes only the necessary space
                    children: [
                      Text(
                        'Add gift',
                        style: TextStyle(fontSize: 14, color: Colors.purple),
                      ),
                      SizedBox(width: 4), // Add spacing between the label and icon
                      Icon(Icons.arrow_forward_ios, size: 16, color: Colors.purple),
                    ],
                  ),
                  onTap: () {
                    Navigator.pop(context); // Close the dialog
                    // Navigate to user_event_giftList
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditAddInEvents(eventId: event['id']),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
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
      _showEventPicker(context);
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

  //deletes the database
  void debugDeleteAll() async {
    await DatabaseHelper.instance.deleteDatabaseFile();
  }


  void debugprintTable(String tableName) async {
    await DatabaseHelper.instance.printTableColumns(tableName);
  }

}
