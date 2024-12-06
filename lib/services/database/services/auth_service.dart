import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign up method
  Future<void> signUp({
    required String firstName,
    required String lastName,
    required String phoneNum,
    required String gender,
    required String preferences,
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      // Generate user ID
      String generatedID = '${firstName.substring(0, 2).toUpperCase()}${lastName.substring(0, 2).toUpperCase()}';

      // Check Firestore for existing user IDs to append counter
      QuerySnapshot snapshot = await _firestore.collection('users').get();
      int userCount = snapshot.docs.length + 1;  // Counter logic
      generatedID += '$userCount';  // Append counter to user ID

      // Create new user
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store user data in Firestore after successful sign up
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'phoneNum': phoneNum,
        'gender': gender,
        'preferences': preferences,
        'email': email,
        'password': password, // Not recommended to store plain password
        'userID': generatedID, // Store generated ID
        'createdAt': Timestamp.now(),
      });

    } catch (e) {
      String errorMessage = 'An error occurred, please try again.';
      if (e is FirebaseAuthException) {
        if (e.code == 'email-already-in-use') {
          errorMessage = 'The email is already in use by another account.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'The email address is not valid.';
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }
}
