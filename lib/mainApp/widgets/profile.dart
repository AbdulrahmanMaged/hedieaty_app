import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/database/local/database_helper.dart';
import '../formScreens/EditAddInEvents.dart';
import '../screens/my_pledged_gifts.dart';
import '../screens/welcomeScreen.dart';

class ProfileWidget extends StatefulWidget {
  @override
  _ProfileWidgetState createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? userData;
  bool isEditing = false; // Tracks editing state
  bool isExpanded = false; // Tracks expanded state for the section
  bool _isLoading = false;
  List<Map<String, dynamic>> _events = [];
  // Get the current user's UID
  final uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    fetchEvents();
  }

  /// Fetches user data from Firestore
  Future<void> _fetchUserData() async {
    try {
      // Get the current user's UID
      if (uid == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No logged-in user found.')),
        );
        return;
      }

      // Fetch user data from Firestore
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        setState(() {
          userData = userDoc.data();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User data not found in Firestore.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user data: $e')),
      );
    }
  }

  /// Updates user data in Firestore
  Future<void> _updateUserData() async {
    if (userData == null) return;

    try {
      // Get the current user's UID
      if (uid == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('user not-found')),
        );
        return;
      }

      // Update user data in Firestore
      await _firestore.collection('users').doc(uid).update(userData!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile data: $e')),
      );
    }
  }

  void _logOut() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => WelcomeScreen()),
    );
  }

  /// Fetch My Events from Firestore
  Future<void> fetchEvents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('userId', isEqualTo: uid) // Fetch events for current user
          .get();

      setState(() {
        _events = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['name'],
            'status': data['status'],
            'date': data['date'],
          };
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching events: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  ///Delete event
  Future<void> _deleteEvent(String eventId) async {
    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId) // Navigate to the correct event
          .delete();

      setState(() {
        _events.removeWhere((event) => event['id'] == eventId); // Remove from local list
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Event deleted successfully!', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting Event: $e', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        titleTextStyle: GoogleFonts.pacifico(fontSize: 24, color: Colors.white),
        backgroundColor: Colors.purple[600],
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white), // Settings icon
            onPressed: () {
              // Navigate to the Settings screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WelcomeScreen()), // add notification settings here
              );
            },
            tooltip: 'Settings',
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: _logOut,
            tooltip: 'Log Out',
          ),
        ],
      ),
      body: userData == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // My Personal Info Section with Arrow and Glow
              GestureDetector(
                onTap: () {
                  setState(() {
                    isExpanded = !isExpanded; // Toggle expansion
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.5),
                        spreadRadius: 3,
                        blurRadius: 8,
                        offset: Offset(0, 3), // Shadow position
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'My Personal Info',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple[800],
                              ),
                            ),
                            Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: Colors.purple,
                              size: 24,
                            ),
                          ],
                        ),
                        if (isExpanded)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 10),
                              // Personal Information Fields
                              TextFormField(
                                initialValue: userData!['firstName'],
                                readOnly: !isEditing,
                                decoration: InputDecoration(
                                  labelText: 'First Name',
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.purple[300]!,
                                        width: 2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.purple[600]!,
                                        width: 2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onChanged: (value) {
                                  userData!['firstName'] = value;
                                },
                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                initialValue: userData!['lastName'],
                                readOnly: !isEditing,
                                decoration: InputDecoration(
                                  labelText: 'Last Name',
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.purple[300]!,
                                        width: 2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.purple[600]!,
                                        width: 2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onChanged: (value) {
                                  userData!['lastName'] = value;
                                },
                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                initialValue: userData!['preferences'],
                                readOnly: !isEditing,
                                decoration: InputDecoration(
                                  labelText: 'Preferences',
                                  prefixIcon:
                                  Icon(Icons.abc, color: Colors.purple),
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.purple[300]!,
                                        width: 2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.purple[600]!,
                                        width: 2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                maxLines: 3,
                                onChanged: (value) {
                                  userData!['preferences'] = value;
                                },
                              ),
                              SizedBox(height: 20),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple[600],
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  if (isEditing) {
                                    // Save changes in Firestore
                                    _updateUserData();
                                  }
                                  setState(() {
                                    isEditing =
                                    !isEditing; // Toggle editing state
                                  });
                                },
                                child: Text(
                                  isEditing
                                      ? 'Save Changes'
                                      : 'Edit',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _events.isEmpty
                  ? Center(child: Text('No events found'))
                  : ListView.builder(
                itemCount: _events.length,
                itemBuilder: (context, index) {
                  final event = _events[index];
                  return  Card(
                    margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 8.0, // Box shadow effect
                    color: Colors.grey[200], // Background color
                    shadowColor: Colors.purple.withOpacity(0.8), // Shadow color with opacity
                    child:ListTile(
                      contentPadding: EdgeInsets.all(10),
                      isThreeLine: true,
                      title: Text(event['name'], style: TextStyle(fontSize: 18)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Status: ${event['status']}'),
                          SizedBox(height: 2),  // Add spacing between the status and date
                          Text(
                            'Date: ${event['date'] != null ? DateFormat('dd-MMM-yyyy').format(event['date'].toDate()) : 'N/A'}',
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'Edit') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditAddInEvents(eventId: event['id']),
                              ),
                            );
                          } else if (value == 'Delete') {
                            _deleteEvent(event['id']);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'Edit',
                            child: Text('Edit'),
                          ),
                          PopupMenuItem(
                            value: 'Delete',
                            child: Text('Delete'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),)
            ],
          ),


      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to MyPledgedScreen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyPledgedGifts()), //
          );
        },
        backgroundColor: Colors.purple[600],
        icon: Icon(Icons.card_giftcard, color: Colors.white),
        label: Text(
          'Pledged Gifts',
          style: TextStyle(color: Colors.white),
        ), // Add your label here
      ),

    );
  }
}
