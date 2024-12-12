import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/database/local/database_helper.dart';

class AddFriendsWidget extends StatefulWidget {
  @override
  _AddFriendsWidgetState createState() => _AddFriendsWidgetState();
}

class _AddFriendsWidgetState extends State<AddFriendsWidget> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> _friendsList = [];
  String _searchQuery = '';
  bool _isLoading = false;
  bool _noFriends = false;
  bool _userNotFound = false;

  @override
  void initState() {
    super.initState();
    _fetchFriends();
  }

  Future<void> _fetchFriends() async {
    try {
      final friends = await _dbHelper.getFriends(1); // Replace with logged-in user ID
      setState(() {
        _friendsList = friends;
        _noFriends = friends.isEmpty; // Check if no friends were found
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching friends: $e')),
      );
    }
  }

  Future<void> _searchFirestoreFriend() async {
    setState(() {
      _isLoading = true;
      _userNotFound = false;
    });

    try {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: _emailController.text.trim())
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final friendData = query.docs.first.data();
        final friendId = query.docs.first.id;

        // Add to Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc('currentUserId') // Replace with logged-in user ID
            .collection('friends')
            .doc(friendId)
            .set({'addedAt': FieldValue.serverTimestamp()});

        // Add to Local Database
        await _dbHelper.addFriend(1, int.parse(friendId)); // Replace 1 with user ID

        // Refresh Friends List
        await _fetchFriends();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Friend added successfully!')),
        );
      } else {
        setState(() {
          _userNotFound = true; // No user found
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredFriends = _friendsList
        .where((friend) =>
        friend['name'].toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Friends'),titleTextStyle: GoogleFonts.pacifico( fontSize: 24,color: Colors.white),
        backgroundColor: Colors.purple[600],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar and Button
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Search',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _searchFirestoreFriend,
                  child: _isLoading ? CircularProgressIndicator() : Text('Add by Email'),
                ),
              ],
            ),
            SizedBox(height: 16),

            // No Friends Message
            if (_noFriends)
              Text(
                "You don't have friends yet ☹️",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),

            // User Not Found Message
            if (_userNotFound)
              Text(
                "User not found.",
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),

            // Friends List
            if (!_noFriends)
              Expanded(
                child: ListView.builder(
                  itemCount: filteredFriends.length,
                  itemBuilder: (context, index) {
                    final friend = filteredFriends[index];
                    return ListTile(
                      title: Text(friend['name']),
                      subtitle: Text(friend['email']),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
