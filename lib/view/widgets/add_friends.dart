import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class AddFriendsWidget extends StatefulWidget {
  @override
  _AddFriendsWidgetState createState() => _AddFriendsWidgetState();
}

class _AddFriendsWidgetState extends State<AddFriendsWidget> {
  final TextEditingController _emailController = TextEditingController();
  List<Map<String, dynamic>> _friendsList = [];
  List<Map<String, dynamic>> _friendRequests = [];
  bool _isLoading = false;
  bool _noFriends = false;
  bool _userNotFound = false;
  final currentUserID = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _fetchFriends();
    _fetchPendingRequests();
  }

  /// Fetch Friends from Firestore
  Future<void> _fetchFriends() async {
    try {
      if (currentUserID == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserID)
          .collection('friends')
          .get();

      setState(() {
        _friendsList = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'firstName': data['firstName'],
            'lastName': data['lastName'],
            'email': data['email'],
          };
        }).toList();

        _noFriends = _friendsList.isEmpty; // Check if no friends
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching friends: $e')),
      );
    }
  }

  /// Fetch Pending Friend Requests
  Future<void> _fetchPendingRequests() async {
    try {
      if (currentUserID == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserID)
          .collection('friendRequests')
          .where('status', isEqualTo: 'pending')
          .get();

      setState(() {
        _friendRequests = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'requestedUserID': doc.id,
            'firstName': data['firstName'],
            'lastName': data['lastName'],
            'email': data['email'],
            'sentAt': (data['sentAt'] as Timestamp).toDate(),
          };
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching friend requests: $e')),
      );
    }
  }

  /// Send Friend Request
  Future<void> _sendFriendRequest() async {
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

        final userDataSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserID)
            .get();
        final userData = userDataSnapshot.data();

        if (currentUserID != null && userData != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(friendId)
              .collection('friendRequests')
              .doc(currentUserID)
              .set({
            'firstName': userData['firstName'],
            'lastName': userData['lastName'],
            'email': userData['email'],
            'sentAt': FieldValue.serverTimestamp(),
            'status': 'pending',
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Friend request sent!')),
          );
        }
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

  /// Handle Friend Request (Accept/Reject)
  Future<void> _handleFriendRequest(String requestedUserID, String status) async {
    if (currentUserID == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserID)
        .collection('friendRequests')
        .doc(requestedUserID)
        .update({'status': status});

    if (status == 'accepted') {
      // Fetch current user's data
      final userDataSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserID)
          .get();
      final userData = userDataSnapshot.data();

      // Fetch requested user's data
      final requestedUserDataSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(requestedUserID)
          .get();
      final requestedUserData = requestedUserDataSnapshot.data();

      if (userData != null && requestedUserData != null) { // Add the requested user to the current user's 'friends' collection with first, last name, and email
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserID)
            .collection('friends')
            .doc(requestedUserID)
            .set({
          'firstName': requestedUserData['firstName'],
          'lastName': requestedUserData['lastName'],
          'email': requestedUserData['email'],
        });

        // Add the current user to the requested user's 'friends' collection with first, last name, and email
        await FirebaseFirestore.instance
            .collection('users')
            .doc(requestedUserID)
            .collection('friends')
            .doc(currentUserID)
            .set({
          'firstName': userData['firstName'],
          'lastName': userData['lastName'],
          'email': userData['email'],
        });
      }
    }
    setState(() {
      _friendRequests.removeWhere((request) => request['requestedUserID'] == requestedUserID);
    });
    // refresh the pending requests
    _fetchPendingRequests();

    //fetch freinds
    _fetchFriends();

    // colorful SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Friend request ${status == 'accepted' ? 'accepted' : 'rejected'}!',
          style: TextStyle(color: Colors.white), // Change text color
        ),
        backgroundColor: status == 'accepted' ? Colors.green : Colors.red, // Green for success, Red for rejection
        behavior: SnackBarBehavior.floating, // Makes the SnackBar float on top
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Rounded corners
        ),
        margin: EdgeInsets.all(16), // Add some margin around the SnackBar
        duration: Duration(seconds: 2), // SnackBar stays for 2 seconds
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white, // Action text color
          onPressed: () {},
        ),
      ),
    );
  }

  /// Format Time Difference
  String _formatTimeDifference(Duration difference) {
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  /// Show Friend Requests Dialog
  void _showFriendRequestsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Friend Requests'),
        content: _friendRequests.isEmpty
            ? Text('No pending friend requests.')
            : SingleChildScrollView(
          child: Column(
            children: _friendRequests.map((request) {
              final timeDifference =
              DateTime.now().difference(request['sentAt']);
              final timeAgo = _formatTimeDifference(timeDifference);

              return ListTile(
                title: Text(
                    '${request['firstName']} ${request['lastName']}'),
                subtitle: Text('${request['email']} • $timeAgo'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.check, color: Colors.green),
                      onPressed: () =>
                          _handleFriendRequest(request['requestedUserID'], 'accepted'),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.red),
                      onPressed: () =>
                          _handleFriendRequest(request['requestedUserID'], 'rejected'),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            child: Text('Close'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Friends'),
        titleTextStyle: GoogleFonts.pacifico(fontSize: 24, color: Colors.white),
        backgroundColor: Colors.purple[600],
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications, color: Colors.white),
                onPressed: _showFriendRequestsDialog,
              ),
              if (_friendRequests.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${_friendRequests.length}',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Enter Friend\'s Email',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[200],
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.purple[300]!, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.purple[600]!, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: _isLoading
                    ? CircularProgressIndicator()  // Show a loading spinner when _isLoading is true
                    : IconButton(
                  icon: Icon(Icons.person_add, color: Colors.purple),
                  onPressed: _sendFriendRequest,
                ),
              ),
            ),
            SizedBox(height: 16),
            if (_noFriends)
              Text(
                "You don't have friends yet ☹️",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            if (_userNotFound)
              Text(
                "User not found.",
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: _friendsList.length,
                itemBuilder: (context, index) {
                  final friend = _friendsList[index];
                  return ListTile(
                    title: Text('${friend['firstName']} ${friend['lastName']}'),
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
