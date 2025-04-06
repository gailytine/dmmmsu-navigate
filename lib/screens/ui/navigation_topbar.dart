// navigation_top_bar.dart
import 'package:flutter/material.dart';

class NavigationTopBar extends StatelessWidget {
  final bool isNavigationVisible;
  final String buildingName;
  final VoidCallback onCancelNavigation;

  const NavigationTopBar({
    Key? key,
    required this.isNavigationVisible,
    required this.buildingName,
    required this.onCancelNavigation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 800),
      top: isNavigationVisible ? 0 : -120, // Slide in/out animation
      left: 0,
      right: 0,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20), // Increased vertical padding
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center, // Center the content
            children: [
              IconButton(
                icon: Icon(Icons.close), // Use a close icon instead of back arrow
                onPressed: onCancelNavigation,
                color: Colors.blue,
              ),
              Expanded(
                child: Text(
                  "Going to $buildingName", // Display "Going to [building name]"
                  textAlign: TextAlign.center, // Center the text
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), // Bigger text
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 48), // Adds spacing for balance (same width as the close button)
            ],
          ),
        ),
      ),
    );
  }
}