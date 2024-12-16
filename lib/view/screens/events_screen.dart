import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../sideScreens/AddEventScreen.dart';

class EventsScreen extends StatefulWidget {
  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  List<Map<String, dynamic>> _events = [];
  bool _isLoading = false;
  String _sortBy = 'Name'; // Default sorting option


  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  // Navigate to AddEventScreen and pass _fetchEvents callback
  void _navigateToAddEventScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEventScreen(onEventAdded: _fetchEvents), // Passing the callback
      ),
    );
    // When the user returns, fetch the updated list of events
    _fetchEvents();
  }

  /// Fetch Events from Firestore
  Future<void> _fetchEvents() async {
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
            'category': data['category'],
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
        _events.sort((a, b) => a['name'].compareTo(b['name']));
      } else if (_sortBy == 'Category') {
        _events.sort((a, b) => a['category'].compareTo(b['category']));
      } else if (_sortBy == 'Status') {
        _events.sort((a, b) => a['status'].compareTo(b['status']));
      }
    });
  }

  /// Show the event details for editing
  void _editEvent(String eventId) {
    // Navigate to an edit screen or show a dialog
  }

  /// Delete an event
  Future<void> _deleteEvent(String eventId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Event'),
        content: Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance.collection('events').doc(eventId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Event deleted successfully!')),
        );
        _fetchEvents(); // Refresh the list
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting event: $e')),
        );
      }
    }
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
      : _events.isEmpty
      ? Center(child: Text('No events found'))
          : ListView.builder(
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          return Card(
            elevation: 5,
            margin: EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(10),
              title: Text(event['name'], style: TextStyle(fontSize: 18)),
              subtitle: Text('Category: ${event['category']}'),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'Edit') {
                    _editEvent(event['id']);
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddEventScreen,
        child: Icon(Icons.add),
        tooltip: 'Add Event',
      ),
    );
  }
}
