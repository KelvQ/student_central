import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({Key? key}) : super(key: key);

  @override
  _ProgressPageState createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  late User _user;
  int _completedTasksCount = 0;
  int _totalMinutesStudied = 0;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser!;
    _loadCompletedTasksCount();
    _loadTotalMinutesStudied();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progress Overview',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Tasks Completed:',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '$_completedTasksCount',
                      style: TextStyle(fontSize: 24, color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Time Studied:',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '${_formatTotalTimeStudied()}',
                      style: TextStyle(fontSize: 24, color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _loadCompletedTasksCount() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(_user.uid)
        .collection('completed_tasks_count')
        .doc('count')
        .get()
        .then((docSnapshot) {
      if (docSnapshot.exists) {
        setState(() {
          _completedTasksCount = docSnapshot.data()?['count'] ?? 0;
        });
      } else {
        // Handle if count document doesn't exist
        print('Count document does not exist');
      }
    }).catchError((error) {
      print('Error loading completed tasks count: $error');
    });
  }

  void _loadTotalMinutesStudied() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(_user.uid)
        .collection('timerState')
        .doc('state')
        .get()
        .then((docSnapshot) {
      if (docSnapshot.exists) {
        setState(() {
          _totalMinutesStudied = docSnapshot.data()?['totalMinutes'] ?? 0;
        });
      } else {
        // Handle if timer state document doesn't exist
        print('Timer state document does not exist');
      }
    }).catchError((error) {
      print('Error loading total minutes studied: $error');
    });
  }

  String _formatTotalTimeStudied() {
    int hours = _totalMinutesStudied ~/ 60;
    int minutes = _totalMinutesStudied % 60;
    return '${hours}h ${minutes}m';
  }
}
