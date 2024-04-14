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
  late Future<int> _completedTasksCount;
  late Future<int> _totalMinutesStudied;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser!;
    _completedTasksCount = _loadCompletedTasksCount();
    _totalMinutesStudied = _loadTotalMinutesStudied();
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
            FutureBuilder<int>(
              future: _completedTasksCount,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Card(
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
                            '${snapshot.data}',
                            style: TextStyle(fontSize: 24, color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
            SizedBox(height: 20),
            FutureBuilder<int>(
              future: _totalMinutesStudied,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Card(
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
                            '${_formatTotalTimeStudied(snapshot.data!)}',
                            style: TextStyle(fontSize: 24, color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<int> _loadCompletedTasksCount() async {
    var docSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(_user.uid)
        .collection('completed_tasks_count')
        .doc('count')
        .get();
    if (docSnapshot.exists) {
      return docSnapshot.data()?['count'] ?? 0;
    } else {
      throw 'Count document does not exist';
    }
  }

  Future<int> _loadTotalMinutesStudied() async {
    var docSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(_user.uid)
        .collection('timerState')
        .doc('state')
        .get();
    if (docSnapshot.exists) {
      return docSnapshot.data()?['totalMinutes'] ?? 0;
    } else {
      throw 'Timer state document does not exist';
    }
  }

  String _formatTotalTimeStudied(int totalMinutes) {
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;
    return '${hours}h ${minutes}m';
  }
}
