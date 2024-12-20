import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hedieaty_app/mainApp/screens/user_event_giftList.dart';
import 'package:intl/intl.dart';

import '../formScreens//AddEventScreen.dart';

class EventsScreen extends StatefulWidget {
  final Function onEventAdded;
  EventsScreen({required this.onEventAdded});

  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  List<Map<String, dynamic>> _events = [];
  bool _isLoading = false;
  String _sortBy = 'Name'; // Default sorting option
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, String> _eventMakerNames = {};
  @override
  void initState() {
    fetchEvents();
  }


  /// Fetch Events from Firestore
  Future<void> fetchEvents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('events')
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

  /// Sort Events based on selected option
  void _sortEvents() {
    setState(() {
      if (_sortBy == 'Name') {
        // Ensure that 'name' is not null and sort based on the first letter of the name
        _events.sort((a, b) {
          String nameA = (a['name'] ?? '').isNotEmpty ? a['name'][0].toUpperCase() : '';
          String nameB = (b['name'] ?? '').isNotEmpty ? b['name'][0].toUpperCase() : '';

          return nameA.compareTo(nameB);
        });
      } else if (_sortBy == 'Status') {
        // Define a custom order for status if you want specific sorting (e.g., current < upcoming < past)
        List<String> statusOrder = ['Current', 'Upcoming', 'Past'];

        _events.sort((a, b) {
          String statusA = a['status'] ?? '';
          String statusB = b['status'] ?? '';

          // Compare status by predefined order
          return statusOrder.indexOf(statusA).compareTo(statusOrder.indexOf(statusB));
        });
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Events'),
        titleTextStyle: GoogleFonts.pacifico(fontSize: 24, color: Colors.white),
        backgroundColor: Colors.purple[600],
        actions: [
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert, // Default "three dots" menu icon
              color: Colors.white, // Set the icon color here
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
                value: 'Status',
                child: Text('Sort by Status'),
              ),
            ],
          ),

        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _events.isEmpty
          ? Center(child: Text('No events found'))
          : ListView.builder(
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          final eventMakerId = event['id'];

          return FutureBuilder<DocumentSnapshot>(
            future: _firestore.collection('users').doc(eventMakerId).get(),
            builder: (context, snapshot) {
              String eventMakerName = 'Unknown';
              if (snapshot.connectionState == ConnectionState.done) {
                final data = snapshot.data?.data() as Map<String, dynamic>?;
                eventMakerName = data?['firstName'] ?? 'Unknown';
              }

              return Card(
                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 8.0,
                color: Colors.grey[200],
                shadowColor: Colors.purple.withOpacity(0.8),
                child: ListTile(
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
                      SizedBox(height: 2),
                      Text('Event By: $eventMakerName'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View gift list',
                        style: TextStyle(fontSize: 14, color: Colors.purple),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios, size: 16, color: Colors.purple),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserEventGiftList(eventId: event['id']),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
