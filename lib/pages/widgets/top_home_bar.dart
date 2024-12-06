import 'package:flutter/material.dart';

class TopHomeBar extends StatelessWidget implements PreferredSizeWidget {
  final Function(String) onMenuSelected;

  const TopHomeBar({
    super.key,
    required this.onMenuSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.purple[600],
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Gift Icon
          const Icon(
            Icons.card_giftcard, // You can change the icon as needed
            color: Colors.white,
            size: 24, // Adjust size as needed
          ),
          const SizedBox(width: 8), // Space between the icon and text
          const Text(
            'Hedieaty',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
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
