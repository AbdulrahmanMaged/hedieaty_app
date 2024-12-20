import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/database/notification/notification_helper.dart';

class UserEventGiftList extends StatefulWidget {
  final String eventId; // The ID of the event whose gifts will be displayed

  UserEventGiftList({required this.eventId});

  @override
  _UserEventGiftListState createState() => _UserEventGiftListState();
}

class _UserEventGiftListState extends State<UserEventGiftList> {
  List<Map<String, dynamic>> _gifts = [];
  bool _isLoading = false;
  String _eventName = ''; // Store the event's  name
  String _sortBy = 'Name'; // Default sorting option


  @override
  void initState() {
    super.initState();
    _fetchGifts();
    _fetchEventName();
  }


  /// Fetch event's  name based on eventId
  Future<void> _fetchEventName() async {
    try {
      final eventDoc = await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .get();

      if (eventDoc.exists) {
        setState(() {
          _eventName = eventDoc.data()?['name'] ?? 'event'; // Default to 'event' if name is null
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching event name: $e')),
      );
    }
  }

  /// Fetch gifts for the specific event
  Future<void> _fetchGifts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('events') // Parent collection
          .doc(widget.eventId)
          .collection('gifts') // Subcollection
          .get();

      setState(() {
        _gifts = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['name'],
            'description': data['description'],
            'status': data['status'],
            'category': data['category'],
            'priceRange': data['priceRange'],
          };
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching gifts: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Sort gifts based on selected option
  void _sortEvents() {
    setState(() {
      if (_sortBy == 'Name') {
        // Ensure that 'name' is not null and sort based on the first letter of the name
        _gifts.sort((a, b) {
          String nameA = (a['name'] ?? '').isNotEmpty ? a['name'][0].toUpperCase() : '';
          String nameB = (b['name'] ?? '').isNotEmpty ? b['name'][0].toUpperCase() : '';

          return nameA.compareTo(nameB);
        });
      } else if (_sortBy == 'Category') {
        // Ensure that 'name' is not null and sort based on the first letter of the name
        _gifts.sort((a, b) {
          String nameA = (a['category'] ?? '').isNotEmpty ? a['category'][0].toUpperCase() : '';
          String nameB = (b['category'] ?? '').isNotEmpty ? b['category'][0].toUpperCase() : '';

          return nameA.compareTo(nameB);
        });
      } else if (_sortBy == 'Status') {
        // Define a custom order for status if you want specific sorting (e.g., current < upcoming < past)
        List<String> statusOrder = ['Current', 'Upcoming', 'Past'];

        _gifts.sort((a, b) {
          String statusA = a['status'] ?? '';
          String statusB = b['status'] ?? '';

          // Compare status by predefined order
          return statusOrder.indexOf(statusA).compareTo(statusOrder.indexOf(statusB));
        });
      }
    });
  }

  Future<void> _updateGiftPledgeStatus(String giftId) async {
    try {
      // Get the current user's ID
      final currentUserID = FirebaseAuth.instance.currentUser?.uid;

      if (currentUserID == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: User not authenticated!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final giftRef = FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId) // Navigate to the event document
          .collection('gifts') // Access the gifts subcollection
          .doc(giftId);

      // Update the gift document
      await giftRef.update({
        'status': 'Pledged',
        'pledgedBy': currentUserID,
      });

      // Fetch the updated gift data
      final giftSnapshot = await giftRef.get();
      final giftData = giftSnapshot.data();

      if (giftData == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: Gift data not found!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Send notification to the gift owner
      final giftOwnerId = giftRef.id;
      await NotificationsHelper().sendNotifications(
        topic: giftOwnerId.toString(),
        title: 'A gift is pledged',
        body: 'Your ${giftData['name'] ?? 'gift'} is pledged',
        userId: currentUserID,
      );

      // Show a green snackbar for successful status change
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gift status updated to Pledged!'),
          backgroundColor: Colors.green,
        ),
      );

      // Refresh the UI after updating
      _fetchGifts();
    } catch (e) {
      // Show a red snackbar if there’s an error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating gift status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$_eventName Gift list"),
        titleTextStyle: GoogleFonts.pacifico(fontSize: 24, color: Colors.white),
        backgroundColor: Colors.purple[600],
        actions: [
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
                _sortEvents(); // Apply sorting after selection
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'Name',
                child: Text('Sort by Name'),
              ),
              PopupMenuItem(
                value: 'Category',
                child: Text('Sort by Category'),
              ),
              PopupMenuItem(
                value: 'Status',
                child: Text('Sort by Status'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _gifts.isEmpty
          ? Center(child: Text('No gifts are found'))
          : ListView.builder(
        itemCount: _gifts.length,
        itemBuilder: (context, index) {
          final gift = _gifts[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 8.0,
            color: (gift['status'] == 'Available' ? Colors.green[100] : Colors.red[100]),
            shadowColor: (gift['status'] == 'Available' ? Colors.green : Colors.red)
                .withOpacity(0.8), // Dynamic glow color
            child: ListTile(
              contentPadding: EdgeInsets.all(10),
              title: Text(
                gift['name'],
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Description: ${gift['description']}'),
                  Text('Category: ${gift['category']}'),
                  Text('Price range: ${gift['priceRange']}'),
                  Text('Status: ${gift['status']}'),
                ],
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  if (gift['status'] == 'Available') {
                    _updateGiftPledgeStatus(gift['id']); // Call function to update status
                  } else {
                    // Show a red snackbar if the gift is already pledged
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gift is already pledged!'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  gift['status'] == 'Available' ? Colors.green : Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 5,
                  shadowColor: Colors.black.withOpacity(0.2),
                ),
                key: ValueKey('pledge'),
                child: Text(
                  gift['status'] == 'Available' ? 'Pledge' : 'Pledged',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
