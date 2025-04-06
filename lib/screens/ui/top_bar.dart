import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  final bool isBuildingSelected;
  final String selectedBuildingName;
  final VoidCallback onBackPressed;
  final VoidCallback onImagePressed;

  const TopBar({
    required this.isBuildingSelected,
    required this.selectedBuildingName,
    required this.onBackPressed,
    required this.onImagePressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 800),
      top: isBuildingSelected ? 0 : -120,
      left: 0,
      right: 0,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: onBackPressed,
                color: Colors.blue,
              ),
              Expanded(
                child: Text(
                  selectedBuildingName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Building image button - always shown
              IconButton(
                icon: Icon(Icons.image),
                onPressed: onImagePressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
