import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:hedieaty_app/services/database/sqlite/database_helper.dart';
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

  // Gift Section
  bool _isAddingGift = false; // Tracks if the gift section is open
  List<Map<String, dynamic>> _gifts = []; // Stores the list of gifts
  TextEditingController _giftNameController = TextEditingController();
  TextEditingController _giftDescriptionController = TextEditingController();
  TextEditingController _giftPriceFromController = TextEditingController();
  TextEditingController _giftPriceToController = TextEditingController();
  String _giftCategory = 'Electronic'; // Default category
  String _giftStatus = 'Available'; // Default status
  final currentUserID = FirebaseAuth.instance.currentUser?.uid;


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

  // Add Gift to the List
  void _addGift() {
    if (_giftNameController.text.isEmpty || _giftPriceFromController.text.isEmpty || _giftPriceToController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required gift fields.')),
      );
      return;
    }

    setState(() {
      _gifts.add({
        'name': _giftNameController.text,
        'description': _giftDescriptionController.text,
        'category': _giftCategory,
        'status': _giftStatus,
        'priceRange': '${_giftPriceFromController.text} - ${_giftPriceToController.text}',
        'pledgedBy':"" ,
      });

      // Clear the gift fields and close the subsection
      _giftNameController.clear();
      _giftDescriptionController.clear();
      _giftPriceFromController.clear();
      _giftPriceToController.clear();
      _giftCategory = 'Electronic';
      _giftStatus = 'Available';
      _isAddingGift = false;
    });
  }

  // Add Event to Firestore with Gifts
  Future<void> _addEvent() async {
    if (_nameController.text.isEmpty || _selectedDate == null || _gifts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields and add at least one gift.')),
      );
      return;
    }

    setState(() {
    });

    try {
      // Get the current date (without time) to compare with event date
      final DateNotFinal = DateTime.now();
      final CurrentDate = DateTime(DateNotFinal.year, DateNotFinal.month, DateNotFinal.day); // Set time to 00:00:00.000
      final eventDate = _selectedDate!;

      // Determine the event status based on the event date
      String eventStatus = 'Upcoming'; // Default value

      if (eventDate.isBefore(CurrentDate)) {
        eventStatus = 'Past'; // Event is in the past
      } else if (eventDate.isAtSameMomentAs(CurrentDate)) {
        eventStatus = 'Current'; // Event is today
      }

      // Save event
      final eventRef = await FirebaseFirestore.instance.collection('events').add({
        'name': _nameController.text,
        'status': eventStatus,
        'date': Timestamp.fromDate(_selectedDate!),
        'location': _locationController.text,
        'description': _descriptionController.text,
        'userId': currentUserID,
      });
      // Retrieve the event ID
      final eventId = eventRef.id;

      List<String> giftIds = []; // List to store gift IDs

// Save gifts as a subcollection
      for (var gift in _gifts) {
        final giftRef = await eventRef.collection('gifts').add({
          'name': gift['name'],
          'description': gift['description'],
          'category': gift['category'],
          'status': gift['status'],
          'priceRange': gift['priceRange'],
          'eventId': eventRef.id,
        });
        // Add the gift ID to the list
        giftIds.add(giftRef.id);
      }


      ///Saving locally
      saveEventAndGiftsLocally(eventId,currentUserID!, eventStatus,giftIds);


      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Event added successfully!',style: TextStyle(color: Colors.white),),
            backgroundColor: Colors.green),
      );

      widget.onEventAdded(); // Notify parent widget
      Navigator.pop(context); // Close screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding event: $e',style: TextStyle(color: Colors.white),),
            backgroundColor: Colors.red),
      );
    }finally {
      setState(() {
      });
    }
  }


  Future<void> saveEventAndGiftsLocally(String eventId,String currentUserID, String eventStatus,List<String> giftIds ) async {
    try {
      // Save event to the Events table
      await DatabaseHelper.instance.insertEvent({
        'id': eventId,
        'name': _nameController.text,
        'status': eventStatus,
        'date': _selectedDate!.toIso8601String(),
        'location': _locationController.text,
        'description': _descriptionController.text,
        'user_id': currentUserID, // Foreign key for the user
      });

      // Save gifts associated with the event to the Gifts table
      for (int i = 0; i < _gifts.length; i++) {
        final gift = _gifts[i];
        final giftId = giftIds[i]; // Get the corresponding gift ID

        await DatabaseHelper.instance.insertGift({
          'id': giftId, // Assign the correct gift ID
          'name': gift['name'],
          'description': gift['description'],
          'category': gift['category'],
          'priceRange': gift['priceRange'],
          'status': gift['status'],
          'event_id': eventId, // Foreign key for the event
        });
      }


      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Event and gifts saved')),
      );
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving event and gifts: $e')),
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
        child: SingleChildScrollView(
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
                  // Event Name Field
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
                        borderSide: BorderSide(color: Colors.purple[300]!, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.purple[600]!, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

                  // Event Location Field
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
                        borderSide: BorderSide(color: Colors.purple[300]!, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.purple[600]!, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

                  // Event Description Field
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
                        borderSide: BorderSide(color: Colors.purple[300]!, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.purple[600]!, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

                  // Event Date Picker
                  Text('Event Date', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple)),
                  SizedBox(height: 5),
                  GestureDetector(
                    onTap: () => _selectDate(context), // Show DatePicker when tapped
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: TextEditingController(
                          text: _selectedDate != null
                              ? DateFormat('dd-MM-yyyy').format(_selectedDate!)
                              : 'Select Date',
                        ),
                        decoration: InputDecoration(
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
                          suffixIcon: Icon(
                            Icons.calendar_today,
                            color: Colors.purple,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Add Gift Section
                  if (_isAddingGift)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Gift Name', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple)),
                          SizedBox(height: 5),
                          TextFormField(
                            controller: _giftNameController,
                            decoration: InputDecoration(
                              labelText: 'Enter Gift Name',
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
                          //
                          SizedBox(height: 10),

                          Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple)),
                          SizedBox(height: 5),
                          TextField(
                            controller: _giftDescriptionController,
                            decoration: InputDecoration(labelText: 'Gift Description',
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
                          //
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _giftPriceFromController,
                                  decoration: InputDecoration(labelText: 'Price Starts From'),
                                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                                  ),
                              ),
                          SizedBox(height: 10),
                              Expanded(
                                child: TextField(
                            controller: _giftPriceToController,
                            decoration: InputDecoration(labelText: 'Max price'),
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                          ),
                          ),
                            ],
                          ),
                          SizedBox(height: 10),
                          DropdownButton<String>(
                            value: _giftCategory,
                            onChanged: (value) {
                              setState(() {
                                _giftCategory = value!;
                              });
                            },
                            items: ['Electronic', 'Games','Fashion','Books','Personal Care']
                                .map((category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ))
                                .toList(),
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: _addGift,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,

                            ),
                            child: Text('Submit Gift',style: TextStyle(color: Colors.white,)),
                          ),
                        ],
                      ),
                    ),

                  // Display Added Gifts
                  ..._gifts.map((gift) {
                    return ListTile(
                      title: Text(gift['name']),
                      subtitle: Text('${gift['priceRange']} - ${gift['category']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              // Edit logic here
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                _gifts.remove(gift);
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  SizedBox(height: 20),

                  // Add Gift Button
                  if (!_isAddingGift)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isAddingGift = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],

                      ),
                      child: Text('Add Gift',style: TextStyle(color: Colors.purple),),
                    ),

                  // Buttons Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: _gifts.isNotEmpty ? () =>saveEventAndGiftsLocally("",currentUserID!,"Draft",[]) : null,

                        style: ElevatedButton.styleFrom(
                          backgroundColor: _gifts.isNotEmpty ? Colors.green : Colors.grey,),
                        child: Text('Save as Draft',
                        style: TextStyle(fontSize: 16,
                          fontWeight: FontWeight.bold,color: _gifts.isNotEmpty ? Colors.black : Colors.white,),),
                      ),
                      ElevatedButton(
                        onPressed: _gifts.isNotEmpty ? _addEvent : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _gifts.isNotEmpty ? Colors.green : Colors.grey,
                        ),
                        child: Text('Post Event',
                        style: TextStyle(fontSize: 16,
                          fontWeight: FontWeight.bold,color: _gifts.isNotEmpty ? Colors.black : Colors.white,),),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}
