import 'package:flutter/material.dart';

class FloorToggle extends StatefulWidget {
  final int floors;
  final Function(int) onFloorSelected;

  const FloorToggle(
      {required this.floors, required this.onFloorSelected, Key? key})
      : super(key: key);

  @override
  _FloorToggleState createState() => _FloorToggleState();
}

class _FloorToggleState extends State<FloorToggle> {
  int selectedFloor = 1;

  void handleFloorChange(int floorNum) {
    setState(() {
      selectedFloor = floorNum;
    });

    // Call the parent callback
    widget.onFloorSelected(floorNum);

    // ✅ Additional actions when floor changes
    // onFloorChanged(floorNum);
  }

  void onFloorChanged(int floor) {
    // Add your logic here
    print("Floor changed to: F$floor");

    // Example: Fetch office data for the new floor
    fetchOfficesForFloor(floor);

    // Example: Adjust map zoom to focus on the new floor (if applicable)
    adjustCameraForFloor(floor);
  }

  Future<void> fetchOfficesForFloor(int floor) async {
    // Example: Fetch office data from database or API
    print("Fetching offices for floor: F$floor");
    // Your API/database call here...
  }

  void adjustCameraForFloor(int floor) {
    // Example: Adjust camera to focus on the new floor
    print("Adjusting camera for floor: F$floor");
    // Your map camera update logic here...
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 100,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 5,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.floors, (index) {
            int floorNum = widget.floors - index; // Display from top to bottom
            return GestureDetector(
              onTap: () => handleFloorChange(floorNum), // ✅ Call new function
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 2),
                padding:
                    const EdgeInsets.symmetric(vertical: 9, horizontal: 13),
                decoration: BoxDecoration(
                  color: selectedFloor == floorNum
                      ? Colors.blue
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'F$floorNum',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color:
                        selectedFloor == floorNum ? Colors.white : Colors.black,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
