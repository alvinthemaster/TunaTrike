import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:users_app/authentication/login_screen.dart';
import 'package:users_app/methods/common_methods.dart';
import 'package:users_app/widgets/loading_dialog.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController userNameTextEditingController = TextEditingController();
  TextEditingController userPhoneTextEditingController =
      TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  String? selectedDiscountType;
  XFile? idImage;

  final CommonMethods cMethods = CommonMethods();
  final List<String> discountTypes = [
    'PWD',
    'Senior Citizen',
    'Student',
    'None'
  ];

  void checkIfNetworkIsAvailable() {
    cMethods.checkConnectivity(context);
    signUpFormValidation();
  }

  void signUpFormValidation() {
    if (userNameTextEditingController.text.trim().length < 4 ||
        userNameTextEditingController.text.trim().length > 12) {
      cMethods.displaySnackBar(
          "Your name must be at least 4-12 characters.", context);
    } else if (userPhoneTextEditingController.text.trim().length != 11 ||
        !RegExp(r'^[0-9]+$').hasMatch(userPhoneTextEditingController.text)) {
      cMethods.displaySnackBar(
          "Please enter a valid phone number (11 digits).", context);
    } else if (!emailTextEditingController.text.contains("@")) {
      cMethods.displaySnackBar("Please enter a valid email.", context);
    }

    String password = passwordTextEditingController.text.trim();
    RegExp passwordRegExp = RegExp(r'^(?=.*[A-Z])(?=.*\d)[A-Za-z\d]{6,}$');
    if (!passwordRegExp.hasMatch(password)) {
      cMethods.displaySnackBar(
          "Your Password must be at least 6 characters long, contain a capital letter, and a number.",
          context);
    } else if (selectedDiscountType == null) {
      cMethods.displaySnackBar("Please select a discount type.", context);
    } else if (idImage == null) {
      cMethods.displaySnackBar("Please upload your ID.", context);
    } else {
      // Show the terms and conditions agreement modal before registering
      showTermsAndConditionsModal();
    }
  }

  // Show the Terms and Conditions modal
  void showTermsAndConditionsModal() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Terms and Conditions"),
          content: SingleChildScrollView(
            child: Text(
                "Please read and accept the terms and conditions before creating an account."
                    "\n\nTunaTrike ID Upload Terms and Conditions"
                    "\n\n1. Acceptance of Terms"
                    "\nBy uploading your identification document (ID) to TunaTrike, you acknowledge that you have read, understood, and agree to be bound by these terms and conditions. If you do not agree, do not upload your ID or use our service."

                    "\n\n2. Purpose of ID Upload"
                    "\nYour ID will be used for verification purposes only to ensure the accuracy of your identity, enhance user trust, and comply with relevant legal and regulatory requirements. TunaTrike will not use your ID for any other purpose without your explicit consent."

                    "\n\n3. Data Privacy and Security"
                    "\nTunaTrike is committed to protecting your personal information. Your uploaded ID will be securely stored and processed in compliance with relevant data protection laws, including but not limited to the General Data Protection Regulation (GDPR) and other applicable laws. We employ encryption and other security measures to ensure your data is safe from unauthorized access."

                    "\n\n4. Types of Acceptable IDs"
                    "\nYou may be required to upload one or more of the following types of IDs for verification:"
                    "\n  • Government-issued IDs (e.g., Senior Citizen ID, PWD ID card)"
                    "\n  • Valid School ID"

                    "\n\n5. Accuracy of Information"
                    "\nYou are responsible for ensuring that the information provided through your uploaded ID is accurate, current, and complete. Any attempt to upload false or misleading documents may result in the termination of your account or legal action."

                    "\n\n6. Retention of Documents"
                    "\nTunaTrike will retain your uploaded ID for as long as necessary to fulfill the purposes described in these Terms and Conditions or as required by law. After such time, your ID may be securely deleted unless retention is required by applicable law."

                    "\n\n7. Third-Party Access"
                    "\nTunaTrike will not share your uploaded ID with any third party except:"
                    "\n  • As required by law, regulation, or legal process"
                    "\n  • With your consent"
                    "\n  • To authorized service providers who assist us in providing our services, in accordance with confidentiality and security obligations"

                    "\n\n8. User Responsibilities"
                    "\nYou are responsible for the security and confidentiality of your account. Ensure that your TunaTrike account credentials are protected and report any unauthorized access or use of your account immediately."

                    "\n\n9. Modifications"
                    "\nTunaTrike reserves the right to modify or update these terms at any time. Any changes will be communicated to you, and your continued use of the TunaTrike app following such changes will constitute acceptance of the revised terms."

                    "\n\n10. Liability"
                    "\nTunaTrike is not liable for any damages, losses, or claims arising from the submission of incorrect or fraudulent identification documents or unauthorized access to your account."

                    "\n\n11. Contact Information"
                    "\nFor any inquiries or concerns regarding your ID upload and how your data is handled, you can contact TunaTrike's support team at tunatrike@gmail.com."


            ),
          ),
          actions: [
            TextButton(
              child: Text("Decline"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text("Agree"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                registerNewUser(); // Proceed to register the user
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> uploadId() async {
    final ImagePicker picker = ImagePicker();
    idImage = await picker.pickImage(source: ImageSource.gallery);
    setState(() {});
  }

  Future<String?> uploadImageToFirebase(XFile imageFile) async {
    try {
      final FirebaseStorage _storage = FirebaseStorage.instanceFor(
        bucket: "gs://tunatrike-database-final.appspot.com",
      );
      Reference ref = _storage
          .ref()
          .child("Images/${userPhoneTextEditingController.text.trim()}.jpg");
      await ref.putFile(File(imageFile.path));
      return await ref.getDownloadURL();
    } catch (e) {
      cMethods.displaySnackBar(
          "Error uploading image: ${e.toString()}", context);
      return null;
    }
  }

  Future<void> registerNewUser() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          LoadingDialog(messageText: "Registering account"),
    );

    try {
      User? userFirebase =
          (await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailTextEditingController.text.trim(),
        password: passwordTextEditingController.text.trim(),
      ))
              .user;

      if (userFirebase != null) {
        await userFirebase.sendEmailVerification();
        Navigator.pop(context); // Close loading dialog

        // Upload the ID image to Firebase Storage and get the URL
        String? idImageUrl = await uploadImageToFirebase(idImage!);
        if (idImageUrl == null) return; // If upload fails, return

        // Show verification dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Email Verification"),
              content: const Text(
                  "A verification link has been sent to your email address. Please verify your email before logging in."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (c) => LoginScreen()));
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );

        DatabaseReference usersRef = FirebaseDatabase.instance
            .ref()
            .child("users")
            .child(userFirebase.uid);
        Map userDataMap = {
          "name": userNameTextEditingController.text.trim(),
          "email": emailTextEditingController.text.trim(),
          "phone": userPhoneTextEditingController.text.trim(),
          "id": userFirebase.uid,
          "blockStatus": "no",
          "discountType": selectedDiscountType,
          "idImageUrl": idImageUrl,
          "createdAt": ServerValue.timestamp,
        };

        usersRef.set(userDataMap);
        FirebaseAuth.instance.signOut();
      }
    } catch (errorMsg) {
      Navigator.pop(context);
      cMethods.displaySnackBar(errorMsg.toString(), context);
    }
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
              Image.asset("assets/images/sikad.png"),
              const Text(
                "Create a User's Account",
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
                        labelText: "Full Name",
                        labelStyle: TextStyle(fontSize: 14),
                      ),
                      style: const TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                    const SizedBox(height: 22),
                    TextField(
                      controller: userPhoneTextEditingController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: "Phone Number",
                        labelStyle: TextStyle(fontSize: 14),
                      ),
                      style: const TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                    const SizedBox(height: 22),
                    TextField(
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Email",
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
                        labelText: "Password",
                        labelStyle: TextStyle(fontSize: 14),
                      ),
                      style: const TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                    const SizedBox(height: 22),
                    Container(
                      width: MediaQuery.of(context).size.width * 1,
                      child: DropdownButton<String>(
                        hint: const Text("Select Discount Type"),
                        value: selectedDiscountType,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedDiscountType = newValue;
                          });
                        },
                        items: discountTypes
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Container(
                      width: MediaQuery.of(context).size.width * 1,
                      child: ElevatedButton(
                        onPressed: uploadId,
                        child: const Text("Upload ID"),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ),
                    if (idImage != null) Text("ID uploaded: ${idImage!.name}"),
                    const SizedBox(height: 32),
                    Container(
                      width: MediaQuery.of(context).size.width * 1,
                      child: ElevatedButton(
                        onPressed: () {
                          checkIfNetworkIsAvailable();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 80, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text("Sign Up"),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (c) => LoginScreen()));
                },
                child: const Text(
                  "Already have an Account? Login Here",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
