import 'package:flutter/material.dart';

class NavigationBottomSheet extends StatelessWidget {
  final String buildingName;
  final Stream<double> distanceStream;
  // final VoidCallback onCancelNavigation;

  const NavigationBottomSheet({
    Key? key,
    required this.buildingName,
    required this.distanceStream,
    // required this.onCancelNavigation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.25, // Initial height (25% of screen)
      minChildSize: 0.2, // Minimum height (20% of screen)
      maxChildSize: 0.5, // Maximum height (50% of screen)
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Top Header with Building Name
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Going to $buildingName",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    // Uncomment if you need the close button
                    // IconButton(
                    //   icon: Icon(Icons.close, color: Colors.grey[600]),
                    //   onPressed: onCancelNavigation,
                    // ),
                  ],
                ),
              ),

              // Distance Information
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text(
                      "Distance to Building",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // StreamBuilder to show live distance updates
                    StreamBuilder<double>(
                      stream: distanceStream,
                      builder: (context, snapshot) {
                        // When we have data
                        if (snapshot.hasData) {
                          return Text(
                            "${snapshot.data!.toStringAsFixed(1)} meters", // Show 1 decimal place
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          );
                        } 
                        // When loading
                        else {
                          return const Text(
                            "Calculating distance...",
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.grey,
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Follow the route to reach your destination.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}