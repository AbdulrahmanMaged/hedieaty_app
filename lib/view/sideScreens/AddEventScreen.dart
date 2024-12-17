import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AddEventScreen extends StatefulWidget {
   final Function onEventAdded; // Callback function
  AddEventScreen({required this.onEventAdded}); // Constructor to accept the callback

  @override
  _AddEventScreenState createState() => _AddEventScreenState();

}

class _AddEventScreenState extends State<AddEventScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate;


  // Show DatePicker for selecting event date
  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// Add Event to Firestore
  Future<void> _addEvent() async {
    if (_nameController.text.isEmpty || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields.',style: TextStyle(color: Colors.white),),
            backgroundColor: Colors.red),
      );
      return;
    }

    try {
      final currentUserID = FirebaseAuth.instance.currentUser?.uid;

      await FirebaseFirestore.instance.collection('events').add({
        'name': _nameController.text,
        'category': 'General', // You can modify this field based on your needs
        'status': 'Upcoming', // You can modify this field based on your needs
        'date': Timestamp.fromDate(_selectedDate!),
        'location': _locationController.text,
        'description': _descriptionController.text,
        'userId': currentUserID,
      });

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Event added successfully!',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.green),
      );

      // After saving the event, trigger the callback to refresh events on the main screen
      widget.onEventAdded();  // Call the callback to refresh the event list

      Navigator.pop(context); // Close the screen after saving

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding event: $e',style: TextStyle(color: Colors.white),),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Event"),
        titleTextStyle: GoogleFonts.pacifico(fontSize: 24, color: Colors.white),
        backgroundColor: Colors.purple[600], // Same theme as Events screen
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(0.8),
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
                // Label and Event Name Field
                Text('Event Name', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple)),
                SizedBox(height: 5),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Enter Event Name - short name please',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey[200],
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.purple[300]!, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.purple[600]!, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 10),

                // Label and Event Location Field
                Text('Location', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple)),
                SizedBox(height: 5),
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: 'Enter Location - Attach a Link/Name of place',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey[200],
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.purple[300]!, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.purple[600]!, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 10),

                // Label and Event Description Field
                Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple)),
                SizedBox(height: 5),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Enter Description - no more than 250 words',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey[200],
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.purple[300]!, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.purple[600]!, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 10),

                // Label and Event Date Picker
                Text('Event Date', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple)),
                SizedBox(height: 5),
                GestureDetector(
                  onTap: () => _selectDate(context), // Show DatePicker when tapped
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: TextEditingController(
                        text: _selectedDate != null
                            ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                            : 'Select Date',
                      ),
                      decoration: InputDecoration(
                        //labelText: 'Event Date',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[200],
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.purple[300]!, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.purple[600]!, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIcon: Icon(
                          Icons.calendar_today,
                          color: Colors.purple,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Save Event Button
            Center(
              child:
                // Save Event Button
                ElevatedButton(
                  onPressed: _addEvent, // Call the _addEvent function
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple, // Button color
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                    shadowColor: Colors.purple.withOpacity(0.5),
                  ),
                  child: Text(
                    'Post Event',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
            ),
              ],
            ),
          ),

        ),
      ),
    );
  }
}
