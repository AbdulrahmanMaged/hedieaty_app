import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../local/database_helper.dart';
import '../../../mainApp/screens/home_page.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;



  // Sign-Up Method
  Future<void> signUp({
    required String firstName,
    required String lastName,
    required String preferences,
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      // Create a new user in Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user information in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'preferences': preferences,
        'email': email,
        'createdAt': Timestamp.now(),
      });

      // 4. Save user information in SQLite
      await _dbHelper.insertUser({
        'id': userCredential.user?.uid,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'preferences': preferences,
      });


      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Account Created Successfully!')),
      );

      // Navigate to HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred. Please try again.';

      // Handle Firebase-specific errors
      if (e.code == 'email-already-in-use') {
        errorMessage = 'The email is already in use by another account.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is not valid. it must contain @';
      } else if (e.code == 'weak-password') {
        errorMessage = 'The password is too weak.';
      } else if (e.message != null && e.message!.contains('PASSWORD_DOES_NOT_MEET_REQUIREMENTS')) {
        errorMessage = 'The password MUST be at least 6 characters';
      }
//PASSWORD_DOES_NOT_MEET_REQUIREMENTS
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      // Handle other errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: $e')),
      );
    }
  }

    // Login method
    Future<void> login({
    required String email,
    required String password,
    required BuildContext context,
    }) async {
    try {
    // Authenticate the user with Firebase
    await _auth.signInWithEmailAndPassword(
    email: email,
    password: password,
    );

    // Navigate to HomePage
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
    } on FirebaseAuthException catch (e) {
    String errorMessage = 'An error occurred. Please try again.';

    // Handle Firebase-specific error codes
    if (e.code == 'user-not-found') {
    errorMessage = 'No user found with this email.';
    } else if (e.code == 'wrong-password') {
    errorMessage = 'Incorrect password. Please try again.';
    } else if (e.code == 'invalid-email') {
    errorMessage = 'The email address is not valid.';
    }

    // Show error message
    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(errorMessage)),
    );
    } catch (e) {
    // Handle other errors
    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('An unexpected error occurred: $e')),
    );
    }
    }
}
