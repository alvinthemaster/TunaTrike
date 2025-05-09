import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:admin_tunatrike_web_panel/dashboard/side_navigation_drawer.dart';
import '../methods/common_methods.dart'; // Assuming you have common methods for utility functions

class LoginPage extends StatefulWidget {
  static const String id = 'LoginPage';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String username = ''; // This will hold the email
  String password = ''; // This will hold the user's password
  CommonMethods cMethods = CommonMethods();

  // Firebase Authentication
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Firebase Database Reference
  final DatabaseReference _membersRef = FirebaseDatabase.instance.ref().child('members');

  // Function to handle login
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      username = username.trim(); // Ensure no extra spaces are present

      try {
        DataSnapshot snapshot = await _membersRef
            .orderByChild('email')
            .equalTo(username)
            .limitToFirst(1)
            .get();
        if (snapshot.exists) {
          Map<String, dynamic> userData = Map<String, dynamic>.from(
              (snapshot.value as Map).values.first);
          UserCredential userCredential = await _auth.signInWithEmailAndPassword(
            email: userData['email'],
            password: password,
          );
          if (userCredential.user!.emailVerified) {
            _proceedToDashboard();
          } else {
            await _auth.signOut();
          }
        } else {
          print('User not found in members database.');
        }
      } on FirebaseAuthException catch (e) {
        print("FirebaseAuthException: ${e.message}"); // Print the specific error message
        String errorMessage = 'Invalid username or password';
        if (e.code == 'user-not-found') {
          errorMessage = 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Wrong password provided for that user.';
        }
        print(errorMessage);  // Print the error message
      }
    }
  }

  void _proceedToDashboard() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SideNavigationDrawer()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
        backgroundColor: Colors.pinkAccent.shade700,
      ),
      body: Center(
        child: FractionallySizedBox(
          widthFactor: 0.5, // 50% width of the screen
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Login",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      username = value!.trim();
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      password = value!.trim();
                    },
                  ),
                  const SizedBox(height: 30),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      onPressed: _login,
                      child: const Text('Login'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
