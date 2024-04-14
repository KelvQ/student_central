import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_central/edit_profile.dart';
import 'main.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;

          // Extract the first letter of the user's first and last names
          String firstLetter = userData['firstName'][0].toUpperCase();
          String lastLetter = userData['lastName'][0].toUpperCase();

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    // Display first letter of first and last name as icon in CircleAvatar
                    child: Text(
                      '$firstLetter$lastLetter',
                      style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Name: ${userData['firstName']} ${userData['lastName']}', // Display user's name
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Email: ${userData['email']}', // Display user's email
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Action for edit profile button
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EditProfilePage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      side: const BorderSide(color: Colors.black, width: 1),
                    ),
                    child: const Text(
                        'Edit Profile',
                        style: TextStyle(color: Colors.black),
                    ),
                  ),
                  SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MyHomePage(title: 'Student Central')),
                      );
                    },
                    child: const Text(
                        'Log Out',
                        style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
