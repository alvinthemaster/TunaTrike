import 'dart:io';

import 'package:drivers_app/pages/dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'authentication/login_screen.dart';


Future<void> main() async
{
  WidgetsFlutterBinding.ensureInitialized();

  Platform.isAndroid
      ? await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCAcjB8a6SEorp0sgZGxBkSH-XZpJ1Dnn0",
      appId: "1:353689170943:android:03240a201ae641e46aedca",
      messagingSenderId:"353689170943",
      projectId: "tunatrike-database-final",
    ),
  ):

  await Firebase.initializeApp();

  await Permission.locationWhenInUse.isDenied.then((valueOfPermission)
  {
    if(valueOfPermission)
    {
      Permission.locationWhenInUse.request();
    }
  });

  await Permission.notification.isDenied.then((valueOfPermission)
  {
    if(valueOfPermission)
    {
      Permission.notification.request();
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget
{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context)
  {
    return MaterialApp(
      title: 'Drivers App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      home: FirebaseAuth.instance.currentUser == null ? const LoginScreen() : const Dashboard(),
    );
  }
}

