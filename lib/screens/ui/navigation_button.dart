import 'package:flutter/material.dart';

class FloatingNavigationButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isVisible;
  final bool isInCampus; // Add this parameter

  const FloatingNavigationButton({
    Key? key,
    required this.onPressed,
    this.isVisible = true,
    required this.isInCampus, // Add this parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("Button visibility: $isVisible"); // Debug print
    return AnimatedPositioned(
      duration: Duration(milliseconds: 300),
      bottom: isVisible ? 20 : -100, // Moves out of view when not visible
      left: 20,
      right: 20,
      child: Visibility(
        visible: isVisible,
        child: FloatingActionButton.extended(
          onPressed: isInCampus
              ? onPressed // Enable button if user is in campus
              : () {
                  // Show a SnackBar if user is outside campus
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Navigation is only available within the campus.",
                        style: TextStyle(fontSize: 16),
                      ),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
          label: Text(
            "Navigate!",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          icon: Icon(Icons.navigation),
          backgroundColor: isInCampus ? Colors.blue : Colors.grey, // Change color based on campus status
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}