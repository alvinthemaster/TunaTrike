import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../methods/common_methods.dart';
import '../widgets/loading_dialog.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  TextEditingController emailTextEditingController = TextEditingController();
  CommonMethods cMethods = CommonMethods();

  resetPassword() async {
    if (emailTextEditingController.text.isEmpty || !emailTextEditingController.text.contains("@")) {
      cMethods.displaySnackBar("Please enter a valid email.", context);
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => LoadingDialog(messageText: "Sending reset link"),
    );

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailTextEditingController.text.trim(),
      );

      Navigator.pop(context); // Remove the loading dialog
      cMethods.displaySnackBar("Password reset email has been sent!", context);

      // Redirect back to login page after reset link is sent
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (c) => LoginScreen()),
      );
    } catch (error) {
      Navigator.pop(context); // Remove the loading dialog
      cMethods.displaySnackBar("Error: $error", context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reset Password"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          children: [
            const Text(
              "Enter your email to receive a password reset link.",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailTextEditingController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email",
                labelStyle: TextStyle(
                  fontSize: 14,
                ),
              ),
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: resetPassword,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 10)),
              child: const Text("Send Reset Link"),
            ),
          ],
        ),
      ),
    );
  }
}