import 'package:drivers_app/authentication/login_screen.dart';
import 'package:drivers_app/global/global_var.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:restart_app/restart_app.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController trikeTextEditingController = TextEditingController();
  String? driverPictureUrl; // Holds the driver's picture URL

  @override
  void initState() {
    super.initState();
    setDriverInfo();
    loadDriverPicture();
  }

  setDriverInfo() {
    setState(() {
      nameTextEditingController.text = driverName;
      phoneTextEditingController.text = driverPhone;
      emailTextEditingController.text =
          FirebaseAuth.instance.currentUser!.email.toString();
      trikeTextEditingController.text = trikeModel + " - " + plateNumber;
    });
  }

  Future<void> loadDriverPicture() async {
    String driverId = FirebaseAuth.instance.currentUser!.uid;
    DatabaseReference driverRef =
        FirebaseDatabase.instance.ref().child("drivers").child(driverId);

    driverRef.child("driverPictureUrl").once().then((DatabaseEvent snapshot) {
      if (snapshot.snapshot.value != null) {
        setState(() {
          driverPictureUrl = snapshot.snapshot.value.toString();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Display driver picture
              if (driverPictureUrl != null)
                CircleAvatar(
                  radius: 70,
                  backgroundImage: NetworkImage(driverPictureUrl!),
                )
              else
                CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.grey,
                  child: const Icon(
                    Icons.person,
                    size: 70,
                    color: Colors.white,
                  ),
                ),

              const SizedBox(height: 20),

              // Driver name
              Padding(
                padding:
                    const EdgeInsets.only(left: 25.0, right: 25.0, top: 8),
                child: TextField(
                  controller: nameTextEditingController,
                  textAlign: TextAlign.center,
                  enabled: false,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white24,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Driver phone
              Padding(
                padding:
                    const EdgeInsets.only(left: 25.0, right: 25.0, top: 4),
                child: TextField(
                  controller: phoneTextEditingController,
                  textAlign: TextAlign.center,
                  enabled: false,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white24,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.phone_android_outlined,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Driver email
              Padding(
                padding:
                    const EdgeInsets.only(left: 25.0, right: 25.0, top: 4),
                child: TextField(
                  controller: emailTextEditingController,
                  textAlign: TextAlign.center,
                  enabled: false,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white24,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.email,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Driver trike info
              Padding(
                padding:
                    const EdgeInsets.only(left: 25.0, right: 25.0, top: 4),
                child: TextField(
                  controller: trikeTextEditingController,
                  textAlign: TextAlign.center,
                  enabled: false,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white24,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.drive_eta_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Logout button
              ElevatedButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.push(context,
                      MaterialPageRoute(builder: (c) => LoginScreen()));
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 80, vertical: 18)),
                child: const Text("Logout"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
