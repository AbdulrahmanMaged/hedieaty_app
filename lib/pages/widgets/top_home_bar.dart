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
      title: const Text('Hedieaty'),
      centerTitle: true,
      actions: [
        TextButton(
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
          child: const Row(
            children: [
              Text(
                'Create Your Own Event/List',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(width: 4), // Space between text and arrow
              Icon(
                Icons.arrow_drop_down,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
