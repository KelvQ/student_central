import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SchedulePage extends StatefulWidget {
  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  late List<ClassInfo> classInfoList = [];

  @override
  void initState() {
    super.initState();
    _loadClassInfoList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule'),
      ),
      body: ListView.builder(
        itemCount: 7,
        itemBuilder: (BuildContext context, int index) {
          final day = _getDayFromIndex(index);
          final classesForDay = classInfoList.where((classInfo) => classInfo.selectedDays[index]).toList();

          return ExpansionTile(
            initiallyExpanded: true,
            maintainState: true, // Keep the ExpansionTile always expanded
            title: Text(
              day,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            children: classesForDay.map((classInfo) {
              return ListTile(
                title: Row(
                  children: [
                    Expanded(
                      child: Text(classInfo.eventName),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _showDeleteConfirmation(context, classInfo);
                      },
                      color: Colors.red, // Set delete button color to red
                    ),
                  ],
                ),
                subtitle: Text('${classInfo.startTime} - ${classInfo.endTime}'),
                // You can add more customization to each class item here
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the schedule input page and wait for result
          _navigateToScheduleInputPage(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  // Function to navigate to the schedule input page
  void _navigateToScheduleInputPage(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ScheduleInputPage()),
    );

    // If result is not null, add class information to the list
    if (result != null && result is ClassInfo) {
      setState(() {
        classInfoList.add(result);
        _saveClassInfo(result);
      });
    }
  }

  // Function to show delete confirmation dialog
  void _showDeleteConfirmation(BuildContext context, ClassInfo classInfo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Confirmation'),
          content: Text('Are you sure you want to delete the event "${classInfo.eventName}" for all days?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  classInfoList.remove(classInfo);
                  _deleteClassInfo(classInfo);
                });
                Navigator.of(context).pop();
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red), // Set delete button text color to red
              ),
            ),
          ],
        );
      },
    );
  }

  String _getDayFromIndex(int index) {
    switch (index) {
      case 0:
        return 'Monday';
      case 1:
        return 'Tuesday';
      case 2:
        return 'Wednesday';
      case 3:
        return 'Thursday';
      case 4:
        return 'Friday';
      case 5:
        return 'Saturday';
      case 6:
        return 'Sunday';
      default:
        return '';
    }
  }

  void _loadClassInfoList() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('schedule')
        .get()
        .then((querySnapshot) {
      setState(() {
        classInfoList = querySnapshot.docs.map((doc) => ClassInfo.fromDocumentSnapshot(doc)).toList();
      });
    }).catchError((error) {
      print('Error loading class info list: $error');
    });
  }

  void _saveClassInfo(ClassInfo classInfo) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('schedule')
        .add(classInfo.toMap()) // Convert ClassInfo to Map
        .then((value) {
      print('Class info saved successfully');
      classInfo.id = value.id;
    }).catchError((error) {
      print('Error saving class info: $error');
    });
  }

  void _deleteClassInfo(ClassInfo classInfo) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('schedule')
        .doc(classInfo.id)
        .delete()
        .then((value) {
      print('Class info deleted successfully');
    }).catchError((error) {
      print('Error deleting class info: $error');
    });
  }
}

class ScheduleInputPage extends StatefulWidget {
  @override
  _ScheduleInputPageState createState() => _ScheduleInputPageState();
}

class _ScheduleInputPageState extends State<ScheduleInputPage> {
  TextEditingController _eventNameController = TextEditingController();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now();
  List<bool> _selectedDays = [false, false, false, false, false, false, false];
  List<String> _dayLabels = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule Input'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Event Name'),
            TextField(
              controller: _eventNameController,
              decoration: InputDecoration(
                hintText: 'Enter event name',
              ),
            ),
            SizedBox(height: 20.0),
            Text('Start Time'),
            ElevatedButton(
              onPressed: () => _selectStartTime(context),
              child: Text(_startTime.format(context)),
            ),
            SizedBox(height: 20.0),
            Text('End Time'),
            ElevatedButton(
              onPressed: () => _selectEndTime(context),
              child: Text(_endTime.format(context)),
            ),
            SizedBox(height: 20.0),
            Text('Select Days'),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                7,
                    (index) => Row(
                  children: [
                    Checkbox(
                      value: _selectedDays[index],
                      onChanged: (bool? value) {
                        setState(() {
                          _selectedDays[index] = value!;
                        });
                      },
                    ),
                    Text(
                      _dayLabels[index],
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                // Handle saving schedule data
                ClassInfo classInfo = ClassInfo(
                  eventName: _eventNameController.text,
                  startTime: _startTime.format(context),
                  endTime: _endTime.format(context),
                  selectedDays: _selectedDays,
                );

                // Return classInfo back to the schedule page
                Navigator.pop(context, classInfo);
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null && picked != _endTime) {
      setState(() {
        _endTime = picked;
      });
    }
  }
}

class ClassInfo {
  String? id;
  final String eventName;
  final String startTime;
  final String endTime;
  final List<bool> selectedDays;

  ClassInfo({
    required this.eventName,
    required this.startTime,
    required this.endTime,
    required this.selectedDays,
    this.id,
  });

  factory ClassInfo.fromDocumentSnapshot(DocumentSnapshot doc) {
    return ClassInfo(
      id: doc.id,
      eventName: doc['eventName'],
      startTime: doc['startTime'],
      endTime: doc['endTime'],
      selectedDays: List<bool>.from(doc['selectedDays']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventName': eventName,
      'startTime': startTime,
      'endTime': endTime,
      'selectedDays': selectedDays,
    };
  }
}
