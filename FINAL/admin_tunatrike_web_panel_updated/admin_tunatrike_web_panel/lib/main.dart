import 'package:admin_tunatrike_web_panel/dashboard/dashboard.dart';
import 'package:admin_tunatrike_web_panel/dashboard/side_navigation_drawer.dart';
import 'package:admin_tunatrike_web_panel/login.dart';
import 'package:admin_tunatrike_web_panel/pages/create_account_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDqx5ZTbb58fScWOGfaHNVdrJkL5_uyO2A",
      authDomain: "tunatrike-database-final.firebaseapp.com",
      databaseURL: "https://tunatrike-database-final-default-rtdb.firebaseio.com",
      projectId: "tunatrike-database-final",
      storageBucket: "tunatrike-database-final.appspot.com",
      messagingSenderId: "353689170943",
      appId: "1:353689170943:web:a89e219dfa37a3a86aedca",
      measurementId: "G-6151RS7T8R",
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Admin Panel',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: LoginPage(),
    );
  }
}
