import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:provider/provider.dart';
import 'config/change_notifier.dart';
import 'config/notification_service.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'screens/main_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';

// import 'utils/map_utils.dart';
import 'utils/permission_utils.dart';
import 'utils/notification_utils.dart';
import 'config/mapbox_config.dart';

import 'database/premade_db/setup_db.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppStateNotifier(), // Provide the LoadingState
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isSplashCompleted = false;
  bool _hasSeenOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    setState(() {
      _hasSeenOnboarding = hasSeenOnboarding;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: _isSplashCompleted
          ? (_hasSeenOnboarding ? MainScreen() : OnboardingScreen())
          : SplashScreen(
              onFinish: () {
                setState(() {
                  _isSplashCompleted = true;
                });
              },
            ),
    );
  }
}

// void main() async {
//   final dbPath = 'assets/database/campus_db.db';
//   setupDatabase(dbPath);
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   tz.initializeTimeZones();

//   // Initialize Notifications
//   await NotificationService.initializeNotifications();

//   await fetchEventsAndScheduleNotifications();

//   // Request FCM permissions
//   FirebaseMessaging messaging = FirebaseMessaging.instance;
//   await messaging.requestPermission(
//     alert: true,
//     badge: true,
//     sound: true,
//   );

//   // Get FCM Token (for debugging)
//   String? token = await messaging.getToken();
//   print("FCM Token: $token");

//   // Listen for Foreground Messages
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//     print("📩 Received Foreground Message: ${message.notification?.title}");
//     NotificationService.showNotification(message);
//   });

//   // Handle Background Notifications
//   FirebaseMessaging.onBackgroundMessage(
//       NotificationService.firebaseMessagingBackgroundHandler);

//   // Handle Notification Taps
//   NotificationService.setupNotificationTapHandler();

//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         body: Center(child: Text("🔥 Firebase Notifications Ready!")),
//       ),
//     );
//   }
// }
