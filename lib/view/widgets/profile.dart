import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import '../../services/database/local/database_helper.dart';
import '../screens/my_pledged_gifts.dart';
import '../screens/welcomeScreen.dart';

class ProfileWidget extends StatefulWidget {
  @override
  _ProfileWidgetState createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic>? userData;
  bool isEditing = false; // Tracks editing state
  bool isExpanded = false; // Tracks expanded state for the section

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  /// Fetches user data from Firestore
  Future<void> _fetchUserData() async {
    try {
      // Get the current user's UID
      final uid = _auth.currentUser?.uid;
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
      final uid = _auth.currentUser?.uid;
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
        child: SingleChildScrollView(
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

              // Empty Section Placeholder
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Upcoming Feature',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to MyPledgedScreen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WelcomeScreen()), // add pledged screen
          );
        },
        child: Icon(Icons.card_giftcard,color: Colors.white,), // Gift icon for the button
        backgroundColor: Colors.purple[600], // Match the app's theme
      ),
    );
  }
}
