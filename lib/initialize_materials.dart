import 'package:flutter/material.dart';

import 'utils/permission_utils.dart'; 
import 'config/mapbox_config.dart';



Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures async operations before runApp

  // Request Location Permission
  bool isPermissionGranted = await requestLocationPermission();
  if (!isPermissionGranted) {
    runApp(const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Location permission is required to use the map.'),
        ),
      ),
    ));
    return;
  }

  // Set Mapbox Access Token
  try {
    MapboxConfig.setAccessToken();
  } catch (e) {
    runApp(const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Failed to initialize Mapbox. Check your configuration.'),
        ),
      ),
    ));
    return;
  }

  // Start the main app if everything is okay
  // runApp(MyApp());
}
