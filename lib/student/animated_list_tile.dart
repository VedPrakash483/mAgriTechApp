import 'package:flutter/material.dart';

class AnimatedListTile extends StatefulWidget {
  final String title;
  final IconData icon;

  const AnimatedListTile({
    required this.title,
    required this.icon,
  });

  @override
  _AnimatedListTileState createState() => _AnimatedListTileState();
}

class _AnimatedListTileState extends State<AnimatedListTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      color: _isHovered ? Colors.blue.withOpacity(0.1) : Colors.transparent,
      child: InkWell(
        onTap: () {
          // Implement navigation based on the tile tapped
        },
        onHover: (isHovered) => setState(() => _isHovered = isHovered),
        child: ListTile(
          leading: Icon(widget.icon,
              color: _isHovered ? Colors.blueAccent : Colors.grey),
          title: Text(widget.title),
        ),
      ),
    );
  }
}
