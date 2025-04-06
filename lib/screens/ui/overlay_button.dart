import 'package:flutter/material.dart';

class OverlayButton extends StatelessWidget {
  final VoidCallback onPressed;

  const OverlayButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 120, // Adjust this value to position the button above the sheet
      right: 20,
      child: FloatingActionButton(
        onPressed: onPressed,
        child: Icon(Icons.add), // Customize the icon or button content
        backgroundColor: Colors.blue, // Customize the button color
      ),
    );
  }
}