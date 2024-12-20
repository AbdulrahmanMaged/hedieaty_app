import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class MyPledgedGifts extends StatefulWidget {
  @override
  _MyPledgedGiftsState createState() => _MyPledgedGiftsState();
}

class _MyPledgedGiftsState extends State<MyPledgedGifts> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _pledgedGifts = [];
  bool _isLoading = true;
  final uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _fetchPledgedGifts();
  }

  Future<void> _fetchPledgedGifts() async {
    try {
      // Fetch pledged gifts
      final giftsSnapshot = await _firestore
          .collectionGroup('gifts') // Access all gifts subcollection
          .where('pledgedBy', isEqualTo: uid) // Filter by pledgedBy field
          .where('status', isEqualTo: 'Pledged') // Ensure status is pledged
          .get();

      // Parse gift data
      List<Map<String, dynamic>> giftsData = [];
      for (var doc in giftsSnapshot.docs) {
        final giftData = doc.data();
        final eventDoc = await doc.reference.parent.parent!.get(); // Fetch parent event
        final eventData = eventDoc.data();

        // Fetch the friend's name using their userId
        String giftOwnerName = 'Unknown';
        if (eventData != null) {
          final giftOwnerId = eventData['userId'] ?? ''; // Check for null userId
          if (giftOwnerId.isNotEmpty) {
            final giftOwnerDoc = await _firestore.collection('users').doc(giftOwnerId).get();
            final giftOwnerData = giftOwnerDoc.data();
            giftOwnerName = giftOwnerData?['firstName'] ?? 'Unknown'; // Default to 'Unknown' if name is null
          }
        }

        giftsData.add({
          'id': doc.id,
          'name': giftData['name'] ?? 'Unnamed Gift', // Default if gift name is null
          'friendName': giftOwnerName, // Friend's name from user collection
          'dueDate': eventData?['date']?.toDate(), // Event date, can be null
        });
        print('Gift Added: ${giftsData.last}');
      }

      setState(() {
        _pledgedGifts = giftsData;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user data: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Pledged Gifts'),
        titleTextStyle: GoogleFonts.pacifico(fontSize: 24, color: Colors.white),
        backgroundColor: Colors.purple[600],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _pledgedGifts.isEmpty
          ? Center(child: Text('No pledged gifts found'))
          : ListView.builder(
        itemCount: _pledgedGifts.length,
        itemBuilder: (context, index) {
          final gift = _pledgedGifts[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 8,
            color: Colors.grey[200],
            shadowColor: Colors.purple.withOpacity(0.8),
            child: ListTile(
              contentPadding: EdgeInsets.all(10),
              title: Text(
                gift['name'],
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Friend Name: ${gift['friendName']}'),
                  Text(
                    'Due Date: ${gift['dueDate'] != null ? DateFormat('dd-MMM-yyyy').format(gift['dueDate']) : 'N/A'}',
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
