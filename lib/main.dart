import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:student_central/create_account.dart';
import 'package:student_central/home.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Main Page'),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.grey, // Set the primary color
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Colors.red, // Set the background color of the SnackBar
        ),
        scaffoldBackgroundColor: Colors.white, // Set the background color to white
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log In'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.JPG',
                height: 275, // Adjust height as needed
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'Email',
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: passwordController,
                obscureText: _obscureText, // Toggle visibility
                decoration: InputDecoration(
                  hintText: 'Password',
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: emailController.text,
                    password: passwordController.text,
                  ).then((value) {
                    print("Success!");
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  }).catchError((error) {
                    print("Error:" + error.toString());
                    String errorMessage = error.toString().split(']')[1].trim();
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Error"),
                          content: Text(errorMessage),
                          actions: [
                            TextButton(
                              child: Text('OK'),
                              onPressed: () => Navigator.pop(context),
                            )
                          ],
                        );
                      },
                    );
                  });
                },
                style: ElevatedButton.styleFrom(
                  side: const BorderSide(color: Colors.black, width: 1),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              const SizedBox(height: 8.0),
              TextButton(
                onPressed: () {
                  // Navigate to sign-up page or perform other action
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreateAccountPage()),
                  );
                },
                child: const Text.rich(
                  TextSpan(
                    text: 'Not a member? ',
                    style: TextStyle(fontWeight: FontWeight.normal),
                    children: [
                      TextSpan(
                        text: 'Create an account',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 50.0),
            ],
          ),
        ),
      ),
    );
  }
}
