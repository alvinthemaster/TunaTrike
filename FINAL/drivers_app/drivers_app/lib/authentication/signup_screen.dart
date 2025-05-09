import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../methods/common_methods.dart';
import '../pages/home_page.dart';
import '../widgets/loading_dialog.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // New variables for cluster dropdown
  String? selectedCluster;
  List<String> clusters = ['Cluster 1', 'Cluster 2', 'Cluster 3', 'Cluster 4'];

  TextEditingController userNameTextEditingController = TextEditingController();
  TextEditingController userPhoneTextEditingController =
      TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController trikeModelTextEditingController =
      TextEditingController();
  TextEditingController plateNumberTextEditingController =
      TextEditingController();
  File? orcrImage;
  File? licenseImage;
  File? plateNumberImage;
  File? driverPicture;
  final FirebaseStorage _storage = FirebaseStorage.instanceFor(
      bucket: "gs://tunatrike-database-final.appspot.com");
  CommonMethods cMethods = CommonMethods();

  // Pick Image function
  Future<void> pickImage(ImageSource source, String type) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage = await _picker.pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        if (type == 'orcr') {
          orcrImage = File(pickedImage.path);
        } else if (type == 'license') {
          licenseImage = File(pickedImage.path);
        } else if (type == 'plate') {
          plateNumberImage = File(pickedImage.path);
        } else if (type == 'driverPicture') {
          driverPicture = File(pickedImage.path);
        }
      });
    }
  }

  // Upload image to Firebase
  Future<String> uploadImageToFirebase(File imageFile, String fileName) async {
    try {
      TaskSnapshot uploadTask =
          await _storage.ref('Driver/$fileName').putFile(imageFile);
      String downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      return '';
    }
  }

  // Check for network availability and form validation
  checkIfNetworkIsAvailable() {
    cMethods.checkConnectivity(context);
    signUpFormValidation();
  }

  // Sign-up form validation
  signUpFormValidation() {
    if (userNameTextEditingController.text.trim().length < 3) {
      cMethods.displaySnackBar(
          "Your Name Must Be 4 or More Characters.", context);
    } else if (userPhoneTextEditingController.text.trim().length != 11 ||
        !RegExp(r'^[0-9]+$').hasMatch(userPhoneTextEditingController.text)) {
      cMethods.displaySnackBar(
          "Please Enter Number Only Or Your Phone Number Must Be Exactly 11 Digits.",
          context);
    } else if (!emailTextEditingController.text.contains("@")) {
      cMethods.displaySnackBar("Please Enter Valid Email.", context);
    } else if (selectedCluster == null) {
      cMethods.displaySnackBar("Please Select a Cluster.", context);
    } else {
      showTermsAndConditionsModal();
    }
  }

  // Register new driver after agreeing to terms and conditions
  registerNewDriver() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          LoadingDialog(messageText: "Registering account..."),
    );

    final User? userFirebase = (await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
      email: emailTextEditingController.text.trim(),
      password: passwordTextEditingController.text.trim(),
    ).catchError((errorMsg) {
      Navigator.pop(context);
      cMethods.displaySnackBar(errorMsg.toString(), context);
    }))
        .user;

    if (!context.mounted) return;
    Navigator.pop(context);

    if (userFirebase != null) {
      await userFirebase.sendEmailVerification();

      String orcrUrl = orcrImage != null
          ? await uploadImageToFirebase(
              orcrImage!, "ORCR_${userFirebase.uid}.jpg")
          : '';
      String licenseUrl = licenseImage != null
          ? await uploadImageToFirebase(
              licenseImage!, "License_${userFirebase.uid}.jpg")
          : '';
      String plateUrl = plateNumberImage != null
          ? await uploadImageToFirebase(
              plateNumberImage!, "Plate_${userFirebase.uid}.jpg")
          : '';
      String driverPictureUrl = driverPicture != null
          ? await uploadImageToFirebase(
              driverPicture!, "DriverPicture_${userFirebase.uid}.jpg")
          : '';

      DatabaseReference usersRef = FirebaseDatabase.instance
          .ref()
          .child("drivers")
          .child(userFirebase.uid);
      Map driverTrikeInfo = {
        "trikeModel": trikeModelTextEditingController.text.trim(),
        "plateNumber": plateNumberTextEditingController.text.trim(),
        "cluster": selectedCluster,  // Save selected cluster
      };
      Map driverDataMap = {
        "trike_details": driverTrikeInfo,
        "name": userNameTextEditingController.text.trim(),
        "email": emailTextEditingController.text.trim(),
        "phone": userPhoneTextEditingController.text.trim(),
        "id": userFirebase.uid,
        "blockStatus": "no",
        "createdAt": ServerValue.timestamp,
        "orcrImageUrl": orcrUrl,
        "licenseImageUrl": licenseUrl,
        "plateImageUrl": plateUrl,
        "driverPictureUrl": driverPictureUrl,
      };
      usersRef.set(driverDataMap);

      Navigator.push(context, MaterialPageRoute(builder: (c) => LoginScreen()));
    }
  }

  // Show terms and conditions modal
  void showTermsAndConditionsModal() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Terms and Conditions"),
          content: SingleChildScrollView(
            child: Text(
              "Please read and accept the terms and conditions before creating an account."
              "\n\nTerms and Conditions details go here..."
            ),
          ),
          actions: [
            TextButton(
              child: Text("Decline"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Agree"),
              onPressed: () {
                Navigator.of(context).pop();
                registerNewDriver();  // Proceed with registration after agreement
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding:
              const EdgeInsets.only(top: 70, left: 10, right: 10, bottom: 10),
          child: Column(
            children: [
              Image.asset("assets/images/tricyclelogo.png"),
              const Text(
                "Create a Driver\'s Account",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    TextField(
                      controller: userNameTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Driver Name",
                        labelStyle: TextStyle(fontSize: 14),
                      ),
                      style: const TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                    const SizedBox(height: 22),
                    TextField(
                      controller: userPhoneTextEditingController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Driver Phone",
                        labelStyle: TextStyle(fontSize: 14),
                      ),
                      style: const TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                    const SizedBox(height: 22),
                    TextField(
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Driver Email",
                        labelStyle: TextStyle(fontSize: 14),
                      ),
                      style: const TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                    const SizedBox(height: 22),
                    TextField(
                      controller: passwordTextEditingController,
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Driver Password",
                        labelStyle: TextStyle(fontSize: 14),
                      ),
                      style: const TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                    const SizedBox(height: 22),
                    TextField(
                      controller: trikeModelTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Motorcycle Model",
                        labelStyle: TextStyle(fontSize: 14),
                      ),
                      style: const TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                    const SizedBox(height: 22),
                    TextField(
                      controller: plateNumberTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Plate Number",
                        labelStyle: TextStyle(fontSize: 14),
                      ),
                      style: const TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                    const SizedBox(height: 22),

                    // Cluster Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedCluster,
                      hint: const Text("Select Cluster"),
                      items: clusters.map((cluster) {
                        return DropdownMenuItem(
                          value: cluster,
                          child: Text(cluster),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCluster = value;
                        });
                      },
                    ),
                    const SizedBox(height: 22),

                    // Existing buttons for image uploads
                    buildImageUploadButton('Upload ORCR License', 'orcr'),
                    buildImageUploadButton('Upload Driver\'s License', 'license'),
                    buildImageUploadButton('Upload Trike Plate Number', 'plate'),
                    buildImageUploadButton('Upload Driver Picture', 'driverPicture'),

                    const SizedBox(height: 22),
                    ElevatedButton(
                      onPressed: checkIfNetworkIsAvailable,
                      child: const Text(
                        "Create Account",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 22),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to create image upload buttons
  Widget buildImageUploadButton(String buttonText, String imageType) {
    return Container(
      width: MediaQuery.of(context).size.width * 1,
      child: ElevatedButton(
        onPressed: () => pickImage(ImageSource.gallery, imageType),
        child: Text(buttonText),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }
}
