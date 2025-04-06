import 'package:flutter/material.dart';
void locationPermissionAlert(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              child: AlertDialog(
                titlePadding: const EdgeInsets.only(top: 60, left: 10, right: 10), // Added padding for image
                title: const Text(
                  'Permission Required',
                  textAlign: TextAlign.center,
                ),
                content: const Text(
                  'Location permission is required to use the map.',
                  textAlign: TextAlign.center,
                ),
                actionsAlignment: MainAxisAlignment.center,
                actionsPadding: const EdgeInsets.only(bottom: 10),
                actions: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2), // Light red background
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK', style: TextStyle(color: Colors.red)),
                    ),
                  ),
                ],
              ),
            ),
            // Positioned Image
            Positioned(
              top: -145, // Adjust as needed
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset(
                  'assets/images/clipart/phone.png', // Change to your image path
                  width: 200, // Adjust size as needed
                  height: 200,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}


Future<bool> userInOtherBoundAlert(BuildContext context, String map) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: IntrinsicHeight(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 0.0),
                child: Container(
                  width: 300,
                  child: AlertDialog(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20), // Added vertical padding
                    titlePadding: const EdgeInsets.only(top: 15, left: 10, right: 10),
                    title: const Text(
                      "Location Alert!",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    content: Text(
                      "You seem to be in $map! Do you want to change maps?",
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    actionsPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15), // More space before buttons
                    actionsAlignment: MainAxisAlignment.spaceEvenly,
                    actions: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5), // Space between buttons
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.2), // Light gray background
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("No", style: TextStyle(color: Colors.grey)),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5), // Space between buttons
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.2), // Light blue background
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Yes', style: TextStyle(color: Colors.blue)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: -145,
                left: 0,
                right: 0,
                child: Center(
                  child: Image.asset(
                    'assets/images/clipart/map.png',
                    width: 200,
                    height: 200,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
  return result ?? false;
}

