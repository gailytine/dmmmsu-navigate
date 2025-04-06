import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:dmmmsu_navigate/config/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> fetchEventsAndScheduleNotifications() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  SharedPreferences prefs = await SharedPreferences.getInstance();

  QuerySnapshot eventSnapshot =
      await firestore.collection("school_events").get();

  for (QueryDocumentSnapshot eventDoc in eventSnapshot.docs) {
    String eventId = eventDoc.id;
    String title = eventDoc['title'];
    String description = eventDoc['desc'];
    Timestamp scheduleTimestamp = eventDoc['date'];
    DateTime scheduleTime = scheduleTimestamp.toDate();

    // ✅ Convert to Philippine Time (UTC+8)
    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(
        scheduleTime.toLocal(), tz.getLocation('Asia/Manila'));

    print("📌 Event ID: $eventId");
    print("📝 Title: $title");
    print("📄 Description: $description");
    print("🌍 Converted to Philippine Time: $scheduledDate");

    // ✅ Check if notification was already shown
    bool alreadyNotified = prefs.getBool("notified_$eventId") ?? false;

    if (!alreadyNotified) {
      // 🚀 Show notification immediately
      NotificationService.showNotificationNow(title, "Upcoming: $description");

      // ✅ Mark as notified
      await prefs.setBool("notified_$eventId", true);
      print("🔍 Already Notified? ${prefs.getBool("notified_$eventId")}");
    }

    // ✅ Schedule the notification if it's in the future
    if (scheduledDate
        .isAfter(tz.TZDateTime.now(tz.getLocation('Asia/Manila')))) {
      NotificationService.scheduleNotification(
        id: eventId.hashCode,
        title: title,
        body: description,
        scheduledDate: scheduledDate,
      );
      print("✅ Notification Scheduled for: $scheduledDate");
    } else {
      print("⚠️ Skipping past event: $title");
    }
  }
}
