import 'package:e_agritech_app/models/user_model.dart';
import 'package:e_agritech_app/student/animated_list_tile.dart';
import 'package:e_agritech_app/student/home_page_student.dart';
import 'package:flutter/material.dart';

class Sidebar extends StatefulWidget {
  final UserModel userModel;

  const Sidebar({super.key, required this.userModel});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blueAccent,
              image: DecorationImage(
                image: NetworkImage('https://placeholder.com/background'),
                fit: BoxFit.cover,
                opacity: 0.2,
              ),
            ),
            accountName: Text(
              widget.userModel.name, // Use the name from userModel
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(
              "Specialization: ${widget.userModel.specialization ?? 'Not Provided'}", // Use specialization from userModel
            ),
            currentAccountPicture: Hero(
              tag: 'profile',
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    widget.userModel.name.isNotEmpty
                        ? widget.userModel.name[0]
                            .toUpperCase() // Display first letter of name
                        : '',
                    style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: _buildAnimatedListTiles(),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAnimatedListTiles() {
    final items = [
      {'title': 'Settings', 'icon': Icons.settings},
      {'title': 'Achievements', 'icon': Icons.emoji_events},
      {'title': 'Feedback', 'icon': Icons.feedback},
    ];

    return items
        .map((item) => AnimatedListTile(
              title: item['title'] as String,
              icon: item['icon'] as IconData,
            ))
        .toList();
  }
}
