import 'package:flutter/material.dart';

class SchedulePage extends StatefulWidget {
  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  List<String> daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Schedule'),
      ),
      body: ListView.builder(
        itemCount: daysOfWeek.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(daysOfWeek[index]),
            onTap: () {
              // Navigate to a page to display classes scheduled for the selected day
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ScheduleDetailPage(day: daysOfWeek[index])),
              );
            },
          );
        },
      ),
    );
  }
}

class ScheduleDetailPage extends StatelessWidget {
  final String day;

  ScheduleDetailPage({required this.day});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Classes for $day'),
      ),
      body: Container(
        // Implement UI to display classes scheduled for the selected day
      ),
    );
  }
}
