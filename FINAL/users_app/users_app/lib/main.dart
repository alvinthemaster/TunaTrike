import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:users_app/authentication/login_screen.dart';
import 'package:users_app/pages/home_page.dart';
import 'appInfo/app_info.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  if (Platform.isAndroid) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCAcjB8a6SEorp0sgZGxBkSH-XZpJ1Dnn0",
        appId: "1:353689170943:android:f6a16869c009cca36aedca",
        messagingSenderId: "353689170943",
        projectId: "tunatrike-database-final",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  // Request location permission
  await _requestLocationPermission();

  runApp(const MyApp());
}

Future<void> _requestLocationPermission() async {
  var status = await Permission.locationWhenInUse.status;

  if (status.isDenied) {
    await Permission.locationWhenInUse.request();
  }

  if (status.isPermanentlyDenied) {
    openAppSettings(); // Prompt user to enable permission from app settings
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppInfo(),
      child: MaterialApp(
        title: 'TunaTrike',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Colors.black,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => FirebaseAuth.instance.currentUser == null 
              ? const LoginScreen() 
              : const HomePage(),
          '/login': (context) => const LoginScreen(),
          // Add other routes as needed
        },
      ),
    );
  }
}
