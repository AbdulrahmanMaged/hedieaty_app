import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class EditAddInEvents extends StatefulWidget {
  final String eventId;

  EditAddInEvents({required this.eventId});

  @override
  _EditAddInEventsState createState() => _EditAddInEventsState();
}

class _EditAddInEventsState extends State<EditAddInEvents> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _giftNameController = TextEditingController();
  TextEditingController _giftDescriptionController = TextEditingController();
  TextEditingController _giftPriceFromController = TextEditingController();
  TextEditingController _giftPriceToController = TextEditingController();
  String _giftCategory = 'Electronic';
  String _giftStatus = 'Available';
  bool _isEditingGift = false;

  bool _isAddingGift = false; // Tracks if the gift section is open
  DateTime? _selectedDate;
  List<Map<String, dynamic>> _gifts = [];
  bool _isLoading = true;
  String giftForEditId="";

  @override
  void initState() {
    super.initState();
    _loadEventData();
    _fetchGifts();
  }

  /// Load event data from Firestore using eventId
  Future<void> _loadEventData() async {
    try {
      final eventDoc = await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .get();

      if (eventDoc.exists) {
        final eventData = eventDoc.data();
        setState(() {
          _nameController.text = eventData?['name'] ?? '';
          _locationController.text = eventData?['location'] ?? '';
          _descriptionController.text = eventData?['description'] ?? '';
          _selectedDate = eventData?['date']?.toDate();
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Event not found'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context); // Navigate back if event doesn't exist
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading event: $e'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context); // Navigate back on error
    }
  }

  /// Fetch gifts for this event
  Future<void> _fetchGifts() async {
    try {
      final giftSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .collection('gifts')
          .get();

      setState(() {
        _gifts = giftSnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['name'],
            'description': data['description'],
            'category': data['category'],
            'status': data['status'],
            'priceRange': data['priceRange'],
          };
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching gifts: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Add a new gift to Firestore
  Future<void> _addGift() async {
    if (_giftNameController.text.isEmpty || _giftPriceFromController.text.isEmpty || _giftPriceToController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all gift details!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final giftData = {
        'name': _giftNameController.text,
        'description': _giftDescriptionController.text,
        'category': _giftCategory,
        'status': _giftStatus,
        'priceRange': '${_giftPriceFromController.text} - ${_giftPriceToController.text}',
      };

      await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .collection('gifts')
          .add(giftData);

      // Refresh gifts and reset gift form
      _fetchGifts();
      _giftNameController.clear();
      _giftDescriptionController.clear();
      _giftPriceFromController.clear();
      _giftPriceToController.clear();
      _giftCategory = 'Electronic';
      _giftStatus = 'Available';
      _isAddingGift = false;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gift added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding gift: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
      _isLoading = true;
    });

    try {
      final currentUserID = FirebaseAuth.instance.currentUser?.uid;
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

      // Save gifts as a subcollection
      for (var gift in _gifts) {
        await eventRef.collection('gifts').add({
          'name': gift['name'],
          'description': gift['description'],
          'category': gift['category'],
          'status': gift['status'],
          'priceRange': gift['priceRange'],
          'eventId': eventRef.id,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Event added successfully!',style: TextStyle(color: Colors.white),),
            backgroundColor: Colors.green),
      );

      Navigator.pop(context); // Close screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding event: $e',style: TextStyle(color: Colors.white),),
            backgroundColor: Colors.red),
      );
    }finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Event & Gifts'),
        titleTextStyle: GoogleFonts.pacifico(fontSize: 24, color: Colors.white),
        backgroundColor: Colors.purple[600],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Details
              _buildEventDetailsSection(),

              SizedBox(height: 20),
              Divider(color: Colors.purple, thickness: 1, height: 20),
              Text(
                'Gifts previously added',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple),
              ),

              // Display Added Gifts
              _gifts.isEmpty
                  ? Text('No gifts added yet.', style: TextStyle(color: Colors.grey))
                  : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _gifts.length,
                itemBuilder: (context, index) {
                  final gift = _gifts[index];
                  return ListTile(
                    title: Text(gift['name']),
                    subtitle: RichText(
                      text: TextSpan(
                        text: '${gift['description']} - ', // Description part
                        style: DefaultTextStyle.of(context).style, // Default text style
                        children: [
                          TextSpan(
                            text: gift['status'], // Status part
                            style: TextStyle(
                              color: gift['status'] == 'Available' ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: gift['status'] == 'Pledged'
                        ? null // Hide buttons if status is 'Pledged'
                        : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            giftForEditId=gift['id'];
                            _editGift(gift);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              _deleteGift(gift['id']);
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
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

              // Gift Section
            if (_isAddingGift || _isEditingGift)
              _buildGiftSection(giftForEditId),

              SizedBox(height: 20),

              // Save as Draft Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: _gifts.isNotEmpty ? null : () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: _gifts.isNotEmpty ? Colors.green : Colors.grey,
                ),
                child: Text(
                  'Save as Draft',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _gifts.isNotEmpty ? Colors.black : Colors.white,
                  ),
                ),
              ),
              // Post Event Button
              ElevatedButton(
                onPressed: _gifts.isNotEmpty ? _addEvent : null, // Adjust function call as needed
                style: ElevatedButton.styleFrom(
                  backgroundColor: _gifts.isNotEmpty ? Colors.green : Colors.grey,
                ),
                child: Text(
                  'Post Event',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _gifts.isNotEmpty ? Colors.black : Colors.white,
                  ),
                ),
              ),
            ],
          )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteGift(String giftId) async {
    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId) // Navigate to the correct event
          .collection('gifts') // Access the gifts subcollection
          .doc(giftId) // Locate the specific gift document
          .delete();

      setState(() {
        _gifts.removeWhere((gift) => gift['id'] == giftId); // Remove from local list
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gift deleted successfully!', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting gift: $e', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
      );
    }
  }

  void _editGift(Map<String, dynamic> gift) {
    setState(() {
      _isEditingGift = true; // Mark that the user is editing a gift
      _giftNameController.text = gift['name'];
      _giftDescriptionController.text = gift['description'];
      _giftPriceFromController.text = gift['priceRange'].split('-')[0].trim();
      _giftPriceToController.text = gift['priceRange'].split('-')[1].trim();
      _giftCategory = gift['category'];
      //_selectedGiftId = gift['id']; // Save the gift ID to identify it for updating

    });
  }

  Future<void> _saveEditedGift(String giftId) async {
    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .collection('gifts')
          .doc(giftId) // Update the specific gift
          .update({
        'name': _giftNameController.text,
        'description': _giftDescriptionController.text,
        'priceRange': '${_giftPriceFromController.text} - ${_giftPriceToController.text}',
        'category': _giftCategory,
      });

      setState(() {
        // Update the local list with the edited gift data
        final index = _gifts.indexWhere((gift) => gift['id'] == giftId);
        if (index != -1) {
          _gifts[index] = {
            'id': giftId,
            'name': _giftNameController.text,
            'description': _giftDescriptionController.text,
            'priceRange': '${_giftPriceFromController.text} - ${_giftPriceToController.text}',
            'category': _giftCategory,
          };
        }
        _isEditingGift = false; // Reset editing state
        // Refresh gifts and reset gift form
        _fetchGifts();
        _giftNameController.clear();
        _giftDescriptionController.clear();
        _giftPriceFromController.clear();
        _giftPriceToController.clear();
        _giftCategory = 'Electronic';
        _giftStatus = 'Available';
        _isAddingGift = false;


      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gift updated successfully!', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating gift: $e', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
      );
    }
  }


  Widget _buildEventDetailsSection() {
    return Padding(
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
              // Event Name Field
              Text(
                'Event Name',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              SizedBox(height: 5),
              TextField(
                controller: _nameController,
                decoration: _inputDecoration('Enter Event Name'),
              ),
              SizedBox(height: 10),

              // Location Field
              Text(
                'Location',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              SizedBox(height: 5),
              TextField(
                controller: _locationController,
                decoration: _inputDecoration('Enter Location'),
              ),
              SizedBox(height: 10),

              // Description Field
              Text(
                'Description',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              SizedBox(height: 5),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: _inputDecoration('Enter Description'),
              ),
              SizedBox(height: 10),

              // Event Date Picker
              Text(
                'Event Date',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              SizedBox(height: 5),
              GestureDetector(
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2024),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
                child: AbsorbPointer(
                  child: TextField(
                    controller: TextEditingController(
                      text: _selectedDate != null
                          ? DateFormat('dd-MM-yyyy').format(_selectedDate!)
                          : '',
                    ),
                    decoration: _inputDecoration('Select Date').copyWith(
                      suffixIcon: Icon(
                        Icons.calendar_today,
                        color: Colors.purple,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGiftSection(String giftId) {
    return Padding(
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
                // Add Gift Section
                TextField(
                  controller: _giftNameController,
                  decoration: _inputDecoration('Gift Name'),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _giftDescriptionController,
                  decoration: _inputDecoration('Gift Description'),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _giftPriceFromController,
                        decoration: _inputDecoration('Price from'),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _giftPriceToController,
                        decoration: _inputDecoration('Max Price'),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _giftCategory,
                  items: ['Electronic', 'Games']
                      .map((category) => DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _giftCategory = value!;
                    });
                  },
                  decoration: _inputDecoration('Category'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _isEditingGift
                      ? () => _saveEditedGift(giftId) // Pass the ID dynamically
                      : _addGift,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                  ),
                  child: Text(
                    _isEditingGift ? 'Save Changes' : 'Submit Gift',
                    style: TextStyle(color: Colors.white),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
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
    );
  }
}
