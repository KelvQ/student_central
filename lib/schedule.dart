import 'package:flutter/material.dart';

class SchedulePage extends StatefulWidget {
  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  List<ClassInfo> classInfoList = [];

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
  final String eventName;
  final String startTime;
  final String endTime;
  final List<bool> selectedDays;

  ClassInfo({
    required this.eventName,
    required this.startTime,
    required this.endTime,
    required this.selectedDays,
  });
}
