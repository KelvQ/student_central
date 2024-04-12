import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PlannerPage extends StatefulWidget {
  const PlannerPage({Key? key}) : super(key: key);

  @override
  _PlannerPageState createState() => _PlannerPageState();
}

class _PlannerPageState extends State<PlannerPage> {
  final TextEditingController _textEditingController = TextEditingController();
  late User _user;
  late List<TodoItem> _todoItems;
  int _completedTasksCount = 0;
  late DateTime _dateTime; // DateTime to store selected date and time

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser!;
    _todoItems = [];
    _loadTodoItems();
    _loadCompletedTasksCount();
    _dateTime = DateTime.now(); // Initialize dateTime with current date and time
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Planner',
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _todoItems.length,
                itemBuilder: (BuildContext context, int index) {
                  final todoItem = _todoItems[index];
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(
                        todoItem.text,
                        style: TextStyle(
                          decoration: todoItem.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      subtitle: Text(todoItem.dateTime != null
                          ? 'Date: ${todoItem.dateTime!.toString().split(' ')[0]} Time: ${todoItem.dateTime!.toString().split(' ')[1].substring(0, 5)}'
                          : ''), // Display date and time
                      leading: Checkbox(
                        value: todoItem.isCompleted,
                        onChanged: (bool? value) {
                          setState(() {
                            todoItem.isCompleted = value!;
                            _updateTodoItem(todoItem);
                            if (todoItem.isCompleted) {
                              _updateCompletedTasksCount(1); // Increment count by 1 if task is completed
                            }
                          });
                        },
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red), // Change delete button color
                        onPressed: () {
                          _deleteTodoItem(todoItem);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Enter Task'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _textEditingController,
                      decoration: const InputDecoration(hintText: 'Enter your task here'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        _showDateTimePicker(context);
                      },
                      child: Text(
                        'Select Date & Time',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      String enteredText = _textEditingController.text;
                      TodoItem newItem = TodoItem(
                        text: enteredText,
                        isCompleted: false,
                        dateTime: _dateTime,
                      );
                      _saveTodoItem(newItem);
                      Navigator.of(context).pop();
                      _textEditingController.clear();
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        },
        label: Text(
          'Add Task',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        icon: Icon(Icons.add),
        backgroundColor: Colors.blue, // Change button background color
        elevation: 3, // Add elevation to button
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Round button corners
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _showDateTimePicker(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    ).then((selectedDate) {
      if (selectedDate != null) {
        showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        ).then((selectedTime) {
          if (selectedTime != null) {
            setState(() {
              _dateTime = DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                selectedTime.hour,
                selectedTime.minute,
              );
            });
          }
        });
      }
    });
  }

  void _loadTodoItems() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(_user.uid)
        .collection('todo_items')
        .get()
        .then((querySnapshot) {
      setState(() {
        _todoItems = querySnapshot.docs.map((doc) => TodoItem.fromDocumentSnapshot(doc)).toList();
      });
    }).catchError((error) {
      print('Error loading todo items: $error');
    });
  }

  void _saveTodoItem(TodoItem item) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(_user.uid)
        .collection('todo_items')
        .add(item.toMap()) // Convert TodoItem to Map
        .then((value) {
      print('Todo item saved successfully');
      setState(() {
        item.id = value.id;
        _todoItems.add(item);
      });
    }).catchError((error) {
      print('Error saving todo item: $error');
    });
  }

  void _updateTodoItem(TodoItem item) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(_user.uid)
        .collection('todo_items')
        .doc(item.id!)
        .update(item.toMap()) // Convert TodoItem to Map
        .then((value) {
      print('Todo item updated successfully');
    }).catchError((error) {
      print('Error updating todo item: $error');
    });
  }

  void _deleteTodoItem(TodoItem item) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(_user.uid)
        .collection('todo_items')
        .doc(item.id!)
        .delete()
        .then((value) {
      print('Todo item deleted successfully');
      setState(() {
        _todoItems.remove(item);
      });
    }).catchError((error) {
      print('Error deleting todo item: $error');
    });
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
        // Initialize count document if it doesn't exist
        _initializeCompletedTasksCount();
      }
    }).catchError((error) {
      print('Error loading completed tasks count: $error');
    });
  }

  void _initializeCompletedTasksCount() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(_user.uid)
        .collection('completed_tasks_count')
        .doc('count')
        .set({'count': _completedTasksCount})
        .then((value) {
      print('Completed tasks count initialized');
    }).catchError((error) {
      print('Error initializing completed tasks count: $error');
    });
  }

  void _updateCompletedTasksCount(int incrementBy) {
    int newCount = _completedTasksCount + incrementBy;
    FirebaseFirestore.instance
        .collection('users')
        .doc(_user.uid)
        .collection('completed_tasks_count')
        .doc('count')
        .update({'count': newCount}).then((value) {
      print('Completed tasks count updated successfully');
      setState(() {
        _completedTasksCount = newCount;
      });
    }).catchError((error) {
      print('Error updating completed tasks count: $error');
    });
  }
}

class TodoItem {
  String? id;
  final String text;
  bool isCompleted;
  DateTime? dateTime; // Add DateTime field to store date and time

  TodoItem({required this.text, required this.isCompleted, this.id, this.dateTime});

  factory TodoItem.fromDocumentSnapshot(DocumentSnapshot doc) {
    return TodoItem(
      id: doc.id,
      text: doc['text'],
      isCompleted: doc['isCompleted'],
      dateTime: doc['dateTime'] != null ? (doc['dateTime'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'isCompleted': isCompleted,
      'dateTime': dateTime != null ? Timestamp.fromDate(dateTime!) : null,
    };
  }
}
