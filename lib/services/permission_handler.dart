import 'package:permission_handler/permission_handler.dart';

Future<void> requestLocationPermission() async {
  var status = await Permission.location.status;
  if (!status.isGranted) {
    // Request permission
    if (await Permission.location.request().isGranted) {
      // Permission granted
      print("Location permission granted");
    } else {
      // Permission denied
      print("Location permission denied");
    }
  }
}
