import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TopHomeBar extends StatelessWidget implements PreferredSizeWidget {
  final Function(String) onMenuSelected;

  const TopHomeBar({
    super.key,
    required this.onMenuSelected,
  });

  // Fetch user first name from Firestore
  Future<String> _getUserFirstName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Get the current user's document from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      // Return the first name (assuming the field is 'firstName')
      if (userDoc.exists) {
        return userDoc['firstName'] ?? 'Guest'; // Default to 'Guest' if no firstName
      }
    }
    return 'User'; // Default fallback if user is not logged in
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.purple[600],
      title: FutureBuilder<String>(
        future: _getUserFirstName(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(); // Loading state
          }

          if (snapshot.hasError) {
            return const Text(
              'Error loading name',
              style: TextStyle(color: Colors.white),
            ); // Handle error if something goes wrong
          }

          // Display the first name fetched from Firestore
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Icon(
                Icons.card_giftcard,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                snapshot.data ?? 'Hedieaty', // Default to 'Hedieaty' if no name found
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextButton(
            onPressed: () {
              showMenu(
                context: context,
                position: const RelativeRect.fromLTRB(100, 80, 0, 0),
                items: [
                  PopupMenuItem<String>(
                    value: 'new_event',
                    child: const Text('New Event'),
                    onTap: () => onMenuSelected('new_event'),
                  ),
                  PopupMenuItem<String>(
                    value: 'edit_or_new_gift',
                    child: const Text('Edit/New Gift'),
                    onTap: () => onMenuSelected('edit_or_new_gift'),
                  ),
                ],
              );
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              backgroundColor: Colors.purple[700],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: Colors.white.withOpacity(0.6)),
            ),
            child: Row(
              children: [
                const Text(
                  'Create New',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4), // Space between text and arrow
                const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
