import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // For custom fonts
import '../widgets/login.dart'; // Import your login screen
import '../widgets/signUp.dart'; // Import your sign-up screen

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  // Create an AnimationController and Animation for scaling effect
  double _scale = 1.0;

  void _onButtonPress() {
    setState(() {
      _scale = 0.9; // Scale down the button when pressed
    });
  }

  void _onButtonRelease() {
    setState(() {
      _scale = 1.0; // Return to original size
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                    'Welcome to Hedieaty app',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 40),
                  // Login Button with Scale Animation
                  GestureDetector(
                    onTapDown: (_) => _onButtonPress(), // On button press
                    onTapUp: (_) => _onButtonRelease(),  // On button release
                    onTapCancel: _onButtonRelease,  // If the user cancels the tap
                    child: AnimatedScale(
                      scale: _scale,
                      duration: Duration(milliseconds: 100), // Duration of the scaling animation
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple[600],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                        ),
                        onPressed: () {
                          // Using PageRouteBuilder to create a fade transition
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) {
                                return LoginScreen(); // here will be login
                              },
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                const begin = Offset(0.0, 1.0);
                                const end = Offset.zero;
                                const curve = Curves.easeInOut;

                                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                var offsetAnimation = animation.drive(tween);

                                return SlideTransition(position: offsetAnimation, child: child);
                              },
                            ),
                          );
                        },
                        child: Text(
                          'Login',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                          key: ValueKey('loginButton'),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Sign Up Button with Scale Animation
                  GestureDetector(
                    onTapDown: (_) => _onButtonPress(), // On button press
                    onTapUp: (_) => _onButtonRelease(),  // On button release
                    onTapCancel: _onButtonRelease,  // If the user cancels the tap
                    child: AnimatedScale(
                      scale: _scale,
                      duration: Duration(milliseconds: 100), // Duration of the scaling animation
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple[600],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                        ),
                        onPressed: () {
                          // Using PageRouteBuilder to create a fade transition
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) {
                                return SignUpScreen();
                              },
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                const begin = Offset(0.0, 1.0);
                                const end = Offset.zero;
                                const curve = Curves.easeInOut;

                                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                var offsetAnimation = animation.drive(tween);

                                return SlideTransition(position: offsetAnimation, child: child);
                              },
                            ),
                          );
                        },
                        child: Text(
                          'Sign Up',
                          style: TextStyle(fontSize: 16, color: Colors.white),
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
