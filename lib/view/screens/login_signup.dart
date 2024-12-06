import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';  // Import google_fonts package
import 'home_page.dart'; // Import your home page

class LoginSignupScreen extends StatefulWidget {
  @override
  _LoginSignupScreenState createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  bool isLoginScreen = true;
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String? email;
  String? password;

  // Method to handle form submission
  void _submitAuthForm() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState!.save();
      try {
        if (isLoginScreen) {
          // Login user
          await _auth.signInWithEmailAndPassword(
            email: email!,
            password: password!,
          );

          // Navigate to HomePage after successful login
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        } else {
          // Create new user
          UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
            email: email!,
            password: password!,
          );

          // Store user data in Firestore after successful sign up
          await _firestore.collection('users').doc(userCredential.user!.uid).set({
            'email': email!,
            'createdAt': Timestamp.now(),
          });

          // Navigate to HomePage after successful signup
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication Successful!')),
        );
      } catch (e) {
        String errorMessage = 'An error occurred, please try again.';

        if (e is FirebaseAuthException) {
          if (e.code == 'email-already-in-use') {
            errorMessage = 'The email is already in use by another account.';
          } else if (e.code == 'invalid-email') {
            errorMessage = 'The email address is not valid.';
          } else if (e.code == 'wrong-password') {
            errorMessage = 'The password is incorrect.';
          } else if (e.code == 'user-not-found') {
            errorMessage = 'No user found with this email.';
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }
  }

  // Method to validate email domain
  String? _validateEmailDomain(String? value) {
    if (value == null || value.isEmpty || !value.contains('@')) {
      return 'Please enter a valid email.';
    }
    return null; // No errors
  }
  String? _validatePassword(String? value) {
    // Check if the password is empty
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty.';
    }

    // Check if the password length is at least 6 characters
    if (value.length < 6) {
      return 'Password must be at least 6 characters long.';
    }

    // Check if the password contains at least one uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter.';
    }

    // Check if the password contains at least one numeric character
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number.';
    }

    return null; // No validation errors
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background gradient for celebration theme
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple[200]!, Colors.pink[300]!], // Celebration colors
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App name with a cool Google font
                  Text(
                    'Hedieaty',
                    style: GoogleFonts.pacifico(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // White text color
                    ),
                  ),
                  SizedBox(height: 16),
                  // Gift icon
                  Icon(
                    Icons.card_giftcard,
                    color: Colors.purple[600],
                    size: 100,
                  ),
                  SizedBox(height: 16),
                  Text(
                    isLoginScreen ? 'Welcome Back!' : 'Create an Account',
                    style: TextStyle(
                      color: Colors.purple[800],
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              key: ValueKey('email'),
                              validator: _validateEmailDomain,
                              onSaved: (value) {
                                email = value;
                              },
                              decoration: InputDecoration(
                                labelText: 'Email Address',
                                prefixIcon: Icon(Icons.email, color: Colors.purple),
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              key: ValueKey('password'),
                              validator: _validatePassword,  // Use the updated password validator
                              onSaved: (value) {
                                password = value;
                              },
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: Icon(Icons.lock, color: Colors.purple),
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple[600],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: _submitAuthForm,
                              child: Text(
                                isLoginScreen ? 'Login' : 'Sign Up',
                                style: TextStyle(fontSize: 16, color: Colors.white), // Button text color set to white
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  isLoginScreen = !isLoginScreen;
                                });
                              },
                              child: Text(
                                isLoginScreen
                                    ? "Don't have an account? Sign Up"
                                    : "Already have an account? Login",
                                style: TextStyle(color: Colors.purple[800]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
