import 'package:flutter/material.dart';

class MapButtons extends StatelessWidget {
  final VoidCallback onRefresh;
  final Future<void> Function() onRecenter;

  const MapButtons({
    Key? key,
    required this.onRefresh,
    required this.onRecenter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 🔄 Refresh Button (Circular)
        Container(
          decoration: BoxDecoration(
            color: Colors.white, // White background
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(66, 32, 35, 110),
                blurRadius: 4,
                spreadRadius: 2,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            onPressed: onRefresh,
            icon: Icon(Icons.refresh, color: Colors.blue), // Grey icon
            splashRadius: 30,
          ),
        ),

        SizedBox(height: 10),

        // 📍 Recenter Button (Circular)
        Container(
          decoration: BoxDecoration(
            color: Colors.white, // White background
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(66, 32, 35, 110),
                blurRadius: 4,
                spreadRadius: 2,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () async {
              await onRecenter();
            },
            icon: Icon(Icons.my_location, color: Colors.blue), // Grey icon
            splashRadius: 30,
          ),
        ),
      ],
    );
  }
}
