import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/database/services/auth_service.dart';
import '../screens/home_page.dart'; // Import your home page
import '../screens/welcomeScreen.dart'; // Import the Welcome Screen

class signUpScreen extends StatefulWidget {
  @override
  _signUpScreenState createState() => _signUpScreenState();
}

class _signUpScreenState extends State<signUpScreen> {
  bool isLoading = false; // Loading state
  final _formKey = GlobalKey<FormState>();
  String? firstName;
  String? lastName;
  String? phoneNum;
  String? gender;
  String? preferences;
  String? email;
  String? password;
  bool _isPasswordVisible = false;
  String? _phoneErrorMessage;

  // Instance of AuthService to handle Firebase logic
  final AuthService _authService = AuthService();

// Method to handle form submission
  void _submitAuthForm() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState!.save();

      setState(() {
        isLoading = true; // Show loading indicator
      });

      // Call signUp from AuthService to handle Firebase Authentication and Firestore logic
      try {
        await _authService.signUp(
          firstName: firstName!,
          lastName: lastName!,
          phoneNum: phoneNum!,
          gender: gender!,
          preferences: preferences!,
          email: email!,
          password: password!,
          context: context,
        );

        setState(() {
          isLoading = false; // Hide loading indicator
        });

        // Success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Account Created Successfully!')),
        );

        // Delay navigation until the snack bar is shown
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        });
      } catch (e) {
        setState(() {
          isLoading = false; // Hide loading indicator in case of error
        });
        // Show error message if the sign-up fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } else {
      // Show message if the form is invalid
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Check the invalid fields and try again')),
      );
    }
  }


  // Method to check phone number validity
  void _onPhoneNumberChanged(String phoneNumber) {
    setState(() {
      _phoneErrorMessage = null; // Reset the error message
    });

    if (phoneNumber.isNotEmpty) {
      // Perform custom validation if needed
      bool isValid = _validatePhoneNumber(phoneNumber);
      if (!isValid) {
        setState(() {
          _phoneErrorMessage = 'Invalid phone number. Please enter a valid number.';
        });
      } else {
        setState(() {
          phoneNum = phoneNumber;
        });
      }
    }
  }

  // Custom validation for phone number
  bool _validatePhoneNumber(String phoneNumber) {
    // You can use any validation logic here. For example:
    return phoneNumber.length > 9; // Example validation for phone number length
  }

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
                                // Phone Number (without country code)
                                TextFormField(
                                  key: ValueKey('phoneNumber'),
                                  keyboardType: TextInputType.phone,
                                  onChanged: _onPhoneNumberChanged,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please enter your phone number.';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Phone Number',
                                    prefixIcon: Icon(Icons.phone, color: Colors.purple),
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                // Error message for invalid phone number
                                if (_phoneErrorMessage != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      _phoneErrorMessage!,
                                      style: TextStyle(color: Colors.red, fontSize: 12),
                                    ),
                                  ),
                                SizedBox(height: 16),
                                // Gender
                                DropdownButtonFormField<String>(
                                  value: gender,
                                  onChanged: (newValue) {
                                    setState(() {
                                      gender = newValue;
                                    });
                                  },
                                  items: ['Male', 'Female', 'Rather not say']
                                      .map((gender) {
                                    return DropdownMenuItem<String>(
                                      value: gender,
                                      child: Text(gender),
                                    );
                                  }).toList(),
                                  decoration: InputDecoration(
                                    labelText: 'Gender',
                                    prefixIcon: Icon(Icons.transgender, color: Colors.purple),
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
                                  onPressed: _submitAuthForm,
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
