import 'package:flutter/material.dart';
import 'package:intl/intl.dart';  // Import this for date formatting

class TimeWidget extends StatefulWidget {
  @override
  _TimeWidgetState createState() => _TimeWidgetState();
}

class _TimeWidgetState extends State<TimeWidget> {
  String _formattedTime = '';

 
  void getCurrentTime() {
    DateTime now = DateTime.now(); // Get the current date and time
    // Use the intl package to format the time (you need to add intl package to pubspec.yaml)
    _formattedTime = DateFormat('HH:mm').format(now);  // Format it as HH:mm
    setState(() {});  // Update the state to refresh the UI
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: Text(
        _formattedTime + ' °C',  // Display the current time
        style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w100),
      ),
    );
  }
}
