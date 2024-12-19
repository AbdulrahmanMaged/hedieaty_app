import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/home_screen.dart'; // Import your home page
import '../screens/welcomeScreen.dart'; // Import the Welcome Screen
import '../../services/database/services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  String? firstName;
  String? lastName;
  String? preferences;
  String? email;
  String? password;
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple[200]!, Colors.pink[300]!],
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
                      Text(
                        'Hedieaty',
                        style: GoogleFonts.pacifico(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 16),
                      Icon(
                        Icons.card_giftcard,
                        color: Colors.purple[600],
                        size: 100,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Create an Account',
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
                                // First Name
                                TextFormField(
                                  key: ValueKey('firstName'),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please enter your first name.';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    firstName = value;
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'First Name',
                                    prefixIcon: Icon(Icons.person, color: Colors.purple),
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                SizedBox(height: 16),
                                // Last Name
                                TextFormField(
                                  key: ValueKey('lastName'),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please enter your last name.';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    lastName = value;
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Last Name',
                                    prefixIcon: Icon(Icons.person, color: Colors.purple),
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                SizedBox(height: 16),
                                // Preferences
                                TextFormField(
                                  key: ValueKey('preferences'),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please enter your preferences.';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    preferences = value;
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Preferences',
                                    prefixIcon: Icon(Icons.favorite, color: Colors.purple),
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                SizedBox(height: 16),
                                // Email
                                TextFormField(
                                  key: ValueKey('email'),
                                  validator: (value) {
                                    if (value!.isEmpty || !value.contains('@')) {
                                      return 'Please enter a valid email.';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    email = value;
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    prefixIcon: Icon(Icons.email, color: Colors.purple),
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                SizedBox(height: 16),
                                // Password
                                TextFormField(
                                  key: ValueKey('password'),
                                  obscureText: !_isPasswordVisible,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please enter a password.';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    password = value;
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    prefixIcon: Icon(Icons.lock, color: Colors.purple),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isPasswordVisible
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: Colors.purple,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isPasswordVisible = !_isPasswordVisible;
                                        });
                                      },
                                    ),
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
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      _formKey.currentState!.save();
                                      final authService = AuthService();
                                      authService.signUp(
                                        firstName: firstName!,
                                        lastName: lastName!,
                                        preferences: preferences!,
                                        email: email!,
                                        password: password!,
                                        context: context,
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Please fill all fields correctly.')),
                                      );
                                    }
                                  },
                                  child: Text(
                                    'Sign Up',
                                    style: TextStyle(fontSize: 16, color: Colors.white),
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

          // Back Button on top left
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black), // Black arrow icon
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => WelcomeScreen()), // Go back to WelcomeScreen
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
