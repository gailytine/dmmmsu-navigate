import 'package:permission_handler/permission_handler.dart';

Future<bool> requestLocationPermission() async {
  var status = await Permission.locationWhenInUse.status;
  if (!status.isGranted) {
    status = await Permission.locationWhenInUse.request();
  }
  return status.isGranted;
}