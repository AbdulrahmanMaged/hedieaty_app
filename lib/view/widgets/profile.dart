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
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  Map<String, dynamic>? userData;
  bool isEditing = false; // Tracks editing state

  @override
  void initState() {
    super.initState();
    _fetchUserData;

  }

  Future<void> _fetchUserData() async {
    try {
      // Step 1: Get the current user's UID
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No logged-in user found.')),
        );
        return;
      }

      // Step 2: Fetch userID from Firestore
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (!userDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No user data found in Firestore.')),
        );
        return;
      }

      final userId = userDoc.data()?['userID'];
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User ID not found in Firestore.')),
        );
        return;
      }

      // Step 3: Fetch user data from SQLite using the userID
      final users = await _dbHelper.getUsersById(userId);
      if (users.isNotEmpty) {
        setState(() {
          userData = users.first;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No user data found locally.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user data: $e')),
      );
    }
  }



  Future<void> _updateUserData() async {
    if (userData != null) {
      await _dbHelper.insertUser(userData!); // Replace existing data
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully!')),
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
        title: Text('Profile'),titleTextStyle: GoogleFonts.pacifico( fontSize: 24,color: Colors.white),
        backgroundColor: Colors.purple[600],
        actions: [
          IconButton(
            icon: Icon(Icons.logout,color: Colors.white),
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
              // My Personal Info Section Title
              Text(
                'My Personal Info',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[800],
                ),
              ),
              SizedBox(height: 10),

              // Personal Information Section
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        initialValue: userData!['firstName'],
                        readOnly: !isEditing,
                        decoration: InputDecoration(labelText: 'First Name'),
                        onChanged: (value) {
                          userData!['firstName'] = value;
                        },
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        initialValue: userData!['lastName'],
                        readOnly: !isEditing,
                        decoration: InputDecoration(labelText: 'Last Name'),
                        onChanged: (value) {
                          userData!['lastName'] = value;
                        },
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        initialValue: userData!['email'],
                        readOnly: true, // Email is not editable
                        decoration: InputDecoration(labelText: 'Email'),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        initialValue: userData!['preferences'],
                        readOnly: !isEditing,
                        decoration: InputDecoration(labelText: 'Preferences'),
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
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          if (isEditing) {
                            // Save changes locally
                            _updateUserData();
                          }
                          setState(() {
                            isEditing = !isEditing; // Toggle editing state
                          });
                        },
                        child: Text(isEditing ? 'Save Changes' : 'Edit',style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),

              // My Pledged Gifts Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WelcomeScreen()), // e3ml pledged page
                  );
                },
                child: Text('My Pledged Gifts',style: TextStyle(fontSize: 16, color: Colors.white)),
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
    );
  }
}


