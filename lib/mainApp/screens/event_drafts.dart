import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/database/sqlite/database_helper.dart';
import '../formScreens/EditAddInEvents.dart';
//import '../edit_screens/edit_add_in_events.dart'; // Ensure correct import for the EditAddInEvents screen

class EventDrafts extends StatefulWidget {
  @override
  _EventDraftsState createState() => _EventDraftsState();
}

class _EventDraftsState extends State<EventDrafts> {
  List<Map<String, dynamic>> _draftEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDraftEvents();
  }

  /// Fetch draft events from the local database
  Future<void> _fetchDraftEvents() async {
    try {
      final drafts = await DatabaseHelper.instance.queryEventsByStatus("Draft");
      setState(() {
        _draftEvents = drafts;
        _isLoading = false;
      });
    } catch (e) {
      _showSnackBar('Error fetching draft events: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Show a snackbar message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// Delete a draft event by ID
  Future<void> _deleteDraft(String eventId) async {
    try {
      await DatabaseHelper.instance.deleteEventById(eventId);
      _showSnackBar('Draft deleted successfully');
      _fetchDraftEvents(); // Refresh the list
    } catch (e) {
      _showSnackBar('Error deleting draft: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Event Drafts',
          style: GoogleFonts.pacifico(fontSize: 24, color: Colors.white),
        ),
        backgroundColor: Colors.purple[600],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _draftEvents.isEmpty
          ? Center(
        child: Text(
          'No draft events found',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: _draftEvents.length,
        itemBuilder: (context, index) {
          final draft = _draftEvents[index];
          return Card(
            margin:
            EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 8,
            color: Colors.grey[200],
            shadowColor: Colors.purple.withOpacity(0.8),
            child: ListTile(
              contentPadding: EdgeInsets.all(10),
              title: Text(
                draft['name'] ?? 'Unnamed Event',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date: ${draft['date'] != null ? DateFormat('dd-MMM-yyyy').format(DateTime.parse(draft['date'])) : 'N/A'}',
                  ),
                  SizedBox(height: 2),
                  Text('Location: ${draft['location'] ?? 'N/A'}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      // Navigate to edit draft screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditAddInEvents(eventId: ''),
                        ),
                      ).then((_) => _fetchDraftEvents()); // Refresh the list on return
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDelete(draft['id']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Show confirmation dialog before deleting a draft
  void _confirmDelete(String eventId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Draft'),
        content: Text('Are you sure you want to delete this draft?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cancel
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              _deleteDraft(eventId); // Proceed with deletion
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
