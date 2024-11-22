import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: Colors.purple[600], // Set selected item color to purple[600]
      unselectedItemColor: Colors.purple[200], // Optionally, set the unselected item color
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home'
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_add),
          label: 'Add'
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.card_giftcard),
          label: 'My Gifts'
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.event),
          label: 'Events'
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile'
        ),
      ],
    );
  }
}
