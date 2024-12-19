import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class UserEventScreen extends StatefulWidget {
  final String userId; // The ID of the user whose events will be displayed

  UserEventScreen({required this.userId});

  @override
  _UserEventScreenState createState() => _UserEventScreenState();
}

class _UserEventScreenState extends State<UserEventScreen> {
  List<Map<String, dynamic>> _events = [];
  bool _isLoading = false;
  String _sortBy = 'Status'; // Default sorting option
  String _userName = ''; // Store the user's first name

  @override
  void initState() {
    super.initState();
    _fetchUserEvents();
    _fetchUserName(); // Fetch user details
  }

  /// Fetch user's first name based on userId
  Future<void> _fetchUserName() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users') // Ensure your collection path is correct
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        setState(() {
          _userName = userDoc.data()?['firstName'] ?? 'User'; // Default to 'User' if firstName is null
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user details: $e')),
      );
    }
  }


  /// Fetch events for the specific user
  Future<void> _fetchUserEvents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('userId', isEqualTo: widget.userId) // Filter by userId
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
        title: Text("$_userName's Events"),
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
            margin:
            EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 8.0,
            color: Colors.grey[200],
            shadowColor: Colors.purple.withOpacity(0.8),
            child: ListTile(
              contentPadding: EdgeInsets.all(10),
              isThreeLine: true,
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
            ),
          );
        },
      ),
    );
  }
}
