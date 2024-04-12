import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({Key? key}) : super(key: key);

  @override
  _PomodoroScreenState createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  bool isRunning = false;
  bool isBreakTime = false;
  int initialStudyTime = 25; // Initial study time in minutes
  int breakTime = 5; // Break time in minutes
  int timeLeftInSeconds = 0;
  Timer? timer;
  int? pausedTimeLeftInSeconds;
  int totalMinutes = 0; // Total minutes the timer has been running

  @override
  void initState() {
    super.initState();
    _getTimerState();
  }

  void _getTimerState() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('timerState')
          .doc('state')
          .get();

      if (docSnapshot.exists) {
        setState(() {
          isRunning = docSnapshot['isRunning'] ?? false;
          isBreakTime = docSnapshot['isBreakTime'] ?? false;
          initialStudyTime = docSnapshot['initialStudyTime'] ?? 25;
          breakTime = docSnapshot['breakTime'] ?? 5;
          timeLeftInSeconds = docSnapshot['timeLeftInSeconds'] ?? 0;
          pausedTimeLeftInSeconds = docSnapshot['pausedTimeLeftInSeconds'];
          totalMinutes = docSnapshot['totalMinutes'] ?? 0;
        });
      }
    } catch (error) {
      print('Error retrieving timer state: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timer'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              isBreakTime ? 'Break Time' : 'Study Time',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 250, // Increased size
                  height: 250, // Increased size
                  child: CircularProgressIndicator(
                    value: isRunning ? 1 - (timeLeftInSeconds / (isBreakTime ? breakTime * 60 : initialStudyTime * 60)) : 0,
                    backgroundColor: isBreakTime ? Colors.blue : Colors.red,
                    strokeWidth: 10,
                    //strokeCap: StrokeCap.round,
                  ),
                ),
                Text(
                  getTimeString(timeLeftInSeconds),
                  style: const TextStyle(fontSize: 30),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (isRunning) {
                      pauseTimer();
                    } else {
                      startTimer();
                    }
                  },
                  child: Text(isRunning ? 'Pause' : 'Start'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    restartTimer();
                  },
                  child: const Text('Restart'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      if (initialStudyTime > 1) {
                        initialStudyTime--;
                        _updateStudyTime();
                      }
                    });
                  },
                  icon: const Icon(Icons.remove),
                ),
                Text('Study Time: $initialStudyTime minutes'),
                IconButton(
                  onPressed: () {
                    setState(() {
                      initialStudyTime++;
                      _updateStudyTime();
                    });
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      if (breakTime > 1) {
                        breakTime--;
                        _updateBreakTime();
                      }
                    });
                  },
                  icon: const Icon(Icons.remove),
                ),
                Text('Break Time: $breakTime minutes'),
                IconButton(
                  onPressed: () {
                    setState(() {
                      breakTime++;
                      _updateBreakTime();
                    });
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void startTimer() {
    _saveTimerState(); // Store timer state when starting timer
    setState(() {
      isRunning = true;
    });
    final int totalSeconds = isBreakTime ? breakTime * 60 : initialStudyTime * 60;
    setState(() {
      timeLeftInSeconds = pausedTimeLeftInSeconds ?? totalSeconds;
      pausedTimeLeftInSeconds = null;
    });
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeftInSeconds == 0) {
        timer.cancel();
        setState(() {
          isBreakTime = !isBreakTime;
          isRunning = false;
        });
        startTimer(); // Start the next timer (study/break)
      } else {
        setState(() {
          timeLeftInSeconds--;
          if (isRunning && timeLeftInSeconds % 60 == 0) {
            totalMinutes += 1; // Increment total minutes every 60 seconds
            _saveTimerState(); // Update total minutes in database
          }
        });
      }
    });
  }

  void pauseTimer() {
    if (timer != null && timer!.isActive) {
      timer!.cancel();
      pausedTimeLeftInSeconds = timeLeftInSeconds;
      setState(() {
        isRunning = false;
      });
    }
  }

  void restartTimer() {
    pauseTimer();
    setState(() {
      isBreakTime = false;
      timeLeftInSeconds = initialStudyTime * 60; // Reset to initial study time
      pausedTimeLeftInSeconds = null; // Reset paused time
    });
  }

  void _saveTimerState() {
    FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('timerState').doc('state').set({
      'isRunning': isRunning,
      'isBreakTime': isBreakTime,
      'initialStudyTime': initialStudyTime,
      'breakTime': breakTime,
      'timeLeftInSeconds': timeLeftInSeconds,
      'pausedTimeLeftInSeconds': pausedTimeLeftInSeconds,
      'totalMinutes': totalMinutes, // Store total minutes in database
    }).then((_) {
      print('Timer state saved to Firestore');
    }).catchError((error) {
      print('Error saving timer state: $error');
    });
  }

  String getTimeString(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    String minutesStr = (minutes < 10) ? '0$minutes' : '$minutes';
    String secondsStr = (remainingSeconds < 10) ? '0$remainingSeconds' : '$remainingSeconds';
    return '$minutesStr:$secondsStr';
  }

  void _updateStudyTime() {
    FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('timerState').doc('state').update({
      'initialStudyTime': initialStudyTime,
    }).then((_) {
      print('Study time updated in Firestore');
    }).catchError((error) {
      print('Error updating study time: $error');
    });
  }

  void _updateBreakTime() {
    FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('timerState').doc('state').update({
      'breakTime': breakTime,
    }).then((_) {
      print('Break time updated in Firestore');
    }).catchError((error) {
      print('Error updating break time: $error');
    });
  }

  @override
  void dispose() {
    if (timer != null && timer!.isActive) {
      timer!.cancel();
    }
    super.dispose();
  }
}
