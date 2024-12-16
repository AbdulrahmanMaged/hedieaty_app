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
      type: BottomNavigationBarType.fixed, // Ensures fixed icons and labels
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Theme.of(context).colorScheme.secondary.withOpacity(0.6),
      selectedFontSize: 14,
      unselectedFontSize: 12,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
          tooltip: 'Go to Home Screen',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_add_alt_1),
          label: 'Friends',
          tooltip: 'View/Add Friends',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.card_giftcard_outlined),
          label: 'My Gifts',
          tooltip: 'View Pledged Gifts',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.event_note),
          label: 'Events',
          tooltip: 'View Events',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
          tooltip: 'View Profile',
        ),
      ],
    );
  }
}