import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:hedieaty_app/services/database/sqlite/database_helper.dart';
import '../formScreens/editAddInEvents.dart';
import '../screens/event_drafts.dart';
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
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController preferencesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    //_fetchUserDataFirestore();
    fetchUserDataLocal(uid!);
    fetchEvents();

  }
  @override
  void dispose() {
    // Dispose controllers to free resources
    firstNameController.dispose();
    lastNameController.dispose();
    preferencesController.dispose();
    super.dispose();
  }

  /// Fetches user data from Firestore
/*
  Future<void> _fetchUserDataFirestore() async {
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
*/

  ///Fetches data from local
  Future<void> fetchUserDataLocal(String userId) async {
    final userDataLocal = await DatabaseHelper.instance.fetchUserData(userId);

    if (userDataLocal != null) {
      userData = userDataLocal;
      /*print('User Data:');
      print('ID: ${userData?['id']}');
      print('First Name: ${userData?['firstName']}');
      print('Last Name: ${userData?['lastName']}');
      print('Email: ${userData?['email']}');
      print('Preferences: ${userData?['preferences']}');*/
      // Initialize controllers with existing user data
      firstNameController.text = userData?['firstName'] ?? '';
      lastNameController.text = userData?['lastName'] ?? '';
      preferencesController.text = userData?['preferences'] ?? '';

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('user not-found')),
      );
    }
  }

///Updates data in local as draft
  void _updateUserLocally(String userId) async {
    final updatedUserData = {
      'firstName': firstNameController.text,
      'lastName': lastNameController.text,
      'email': userData?['email'],
      'preferences': preferencesController.text,
    };

    try {
      await DatabaseHelper.instance.updateUserDataLocally(userId, updatedUserData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User data updated successfully locally.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating user data locally: $e')),
      );
    }
  }


  /// Updates user data in Firestore
  Future<void> _updateUserData() async {
    try {
      // Ensure the current user is logged in
      if (uid == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not found')),
        );
        return;
      }

      // Prepare updated data from controllers
      final updatedUserData = {
        'id': uid,
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
        'email': userData?['email'], // Email is not editable here
        'preferences': preferencesController.text,
      };

      // Update user data in Firestore
      await _firestore.collection('users').doc(uid).update(updatedUserData);

      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );

      // Update local `userData` map
        await DatabaseHelper.instance.updateUserDataLocally(uid!, updatedUserData);


    } catch (e) {
      // Handle errors
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
                                controller: firstNameController,
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

                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                controller: lastNameController,
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

                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                controller: preferencesController,
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

                              ),
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between buttons
                                children: [
                                  // Existing button
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.purple[600],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () {
                                      if (isEditing) {
                                        // Save changes in Firestore
                                        _updateUserData();
                                      }
                                      setState(() {
                                        isEditing = !isEditing; // Toggle editing state
                                      });
                                    },
                                    child: Text(
                                      isEditing ? 'Save Changes' : 'Edit',
                                      style: TextStyle(fontSize: 16, color: Colors.white),
                                    ),
                                  ),
                                  // Save on local DB
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.purple[400], // Example color for draft button
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () {
                                      // Implement draft save logic here
                                      _updateUserLocally(userData?['id']);
                                    },
                                    child: Text(
                                      'Save as Draft',
                                      style: TextStyle(fontSize: 16, color: Colors.white),
                                    ),
                                  ),
                                ],
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
      floatingActionButton: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            bottom: 80, // Position slightly above the second button
            right: 16, // Align to the right
            child: FloatingActionButton.extended(
              onPressed: () {
                // Navigate to Event Drafts
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EventDrafts()), //EventDrafts widget
                );
              },
              backgroundColor: Colors.orange[600], // Different color for differentiation
              icon: Icon(Icons.drafts, color: Colors.white), // Icon for drafts
              label: Text(
                'Event Drafts',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          Positioned(
            bottom: 16, // Default floating button position
            right: 16, // Align to the right
            child: FloatingActionButton.extended(
              onPressed: () {
                // Navigate to My Pledged Gifts
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyPledgedGifts()), // Existing navigation
                );
              },
              backgroundColor: Colors.purple[600],
              icon: Icon(Icons.card_giftcard, color: Colors.white),
              label: Text(
                'Pledged Gifts',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),


    );
  }
}
