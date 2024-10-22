import 'package:flutter/material.dart';
import 'package:hedieaty_app/pages/new/newEvent.dart';
import 'package:hedieaty_app/pages/new/newGiftList.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Method to handle the selection from the dropdown menu
  void _onMenuSelected(String value) {
    if (value == 'new_event') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else if (value == 'new_list') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Home Page'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              showMenu(
                context: context,
                position: const RelativeRect.fromLTRB(
                    100, 80, 0, 0), // Adjust position if needed
                items: [
                  PopupMenuItem<String>(
                    value: 'new_event',
                    child: const Text('New Event'),
                    onTap: () => _onMenuSelected('new_event'),
                  ),
                  PopupMenuItem<String>(
                    value: 'new_list',
                    child: const Text('New Gift List'),
                    onTap: () => _onMenuSelected('new_list'),
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
      ),
      body: Center(
        child: TextButton(
          onPressed: () {},
          child: const Text('Next'),
        ),
      ),
    );
  }
}
