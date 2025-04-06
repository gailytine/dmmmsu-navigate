import 'package:flutter/material.dart';

class NavigationButtons extends StatelessWidget {
  final VoidCallback onStart;
  final VoidCallback onCancel;

  const NavigationButtons({
    Key? key,
    required this.onStart,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Background color of the container
        borderRadius: BorderRadius.circular(30), // Match button border radius
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2), // Shadow color
            blurRadius: 10, // Blur intensity
            spreadRadius: 2, // Spread of the shadow
            offset: Offset(0, 4), // Shadow position (x, y)
          ),
        ],
      ),
      padding: const EdgeInsets.all(8), // Add padding around the buttons
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Cancel Button (White with Grey Text and Border)
          OutlinedButton(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white, // White background
              foregroundColor: Colors.grey[600], // Grey text color
              side: BorderSide(
                color: Colors.grey[400]!, // Border color
                width: 1, // Border thickness
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              "Cancel",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          // Start Button (Blue with White Text)
          ElevatedButton(
            onPressed: onStart,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, // Blue background
              foregroundColor: Colors.white, // Text color
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0, // Remove default button shadow
            ),
            child: const Text(
              "Start",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}