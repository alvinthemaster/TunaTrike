import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MembersAndCreateAccountPage extends StatefulWidget {
  static const String id = "\webPageMember";

  @override
  _MembersAndCreateAccountPageState createState() => _MembersAndCreateAccountPageState();
}

class _MembersAndCreateAccountPageState extends State<MembersAndCreateAccountPage> {
  final _formKey = GlobalKey<FormState>();
  
  String firstName = '';
  String lastName = '';
  String address = '';
  DateTime? birthday;
  String username = ''; // Email for the account
  String password = '';

  String searchQuery = '';
  List<Map<String, dynamic>> members = [];
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref().child('members');
  
  // Firebase Authentication instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  // Fetch members from Firebase
  Future<void> _fetchMembers() async {
    final snapshot = await _databaseRef.once();
    if (snapshot.snapshot.value != null) {
      Map<dynamic, dynamic> data = snapshot.snapshot.value as Map<dynamic, dynamic>;
      List<Map<String, dynamic>> tempMembers = [];
      data.forEach((key, value) {
        tempMembers.add(Map<String, dynamic>.from(value));
      });
      setState(() {
        members = tempMembers;
      });
    }
  }

  // Save account data to Firebase
  // Save account data to Firebase
Future<void> _createAccount() async {
  try {
    // Create user in Firebase Authentication
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: username,  // Use email as username
      password: password, // Password provided by the user
    );

    // Send verification email
    await userCredential.user?.sendEmailVerification();

    // Store additional user information in the database
    await _databaseRef.child(userCredential.user!.uid).set({
      'firstName': firstName,
      'lastName': lastName,
      'address': address,
      'birthday': birthday?.toIso8601String(),
      'email': username,
      // Note: Do NOT store the password in plain text
    });

    _fetchMembers(); // Refresh members list
    _showSuccessDialog(); // Show success dialog
  } on FirebaseAuthException catch (e) {
    // Handle registration errors
    String errorMessage = 'Failed to create account';
    if (e.code == 'weak-password') {
      errorMessage = 'The password provided is too weak.';
    } else if (e.code == 'email-already-in-use') {
      errorMessage = 'The account already exists for that email.';
    }
    _showErrorDialog(errorMessage); // Show error dialog
  } catch (e) {
    // Handle any other errors
    _showErrorDialog('An unexpected error occurred. Please try again.');
  }
}


  // Filter members based on search query
  List<Map<String, dynamic>> _filterMembers() {
    if (searchQuery.isEmpty) {
      return members;
    } else {
      return members.where((member) {
        final firstName = member['firstName'].toLowerCase();
        final lastName = member['lastName'].toLowerCase();
        final query = searchQuery.toLowerCase();
        return firstName.contains(query) || lastName.contains(query);
      }).toList();
    }
  }

  // Show account creation modal
  void _showCreateAccountModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 20,
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Create Account", style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'First Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter first name';
                      }
                      return null;
                    },
                    onSaved: (value) => firstName = value!,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Last Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter last name';
                      }
                      return null;
                    },
                    onSaved: (value) => lastName = value!,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Address'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter address';
                      }
                      return null;
                    },
                    onSaved: (value) => address = value!,
                  ),
                  GestureDetector(
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          birthday = pickedDate;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Birthday',
                      ),
                      child: Text(
                        birthday == null
                            ? 'Select your birthday'
                            : "${birthday!.toLocal()}".split(' ')[0],
                      ),
                    ),
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Username (Email)'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter username';
                      }
                      return null;
                    },
                    onSaved: (value) => username = value!,
                  ),
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(labelText: 'Password'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter password';
                      }
                      return null;
                    },
                    onSaved: (value) => password = value!,
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          _createAccount();
                          Navigator.pop(context); // Close modal
                        }
                      },
                      child: const Text('Create Account'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Success dialog
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Account Created"),
          content: const Text("The account has been successfully created."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredMembers = _filterMembers();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Members & Create Account'),
        backgroundColor: Colors.pinkAccent.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            ElevatedButton(
              onPressed: _showCreateAccountModal,
              child: const Text('Create Account'),
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Search Members',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: filteredMembers.isNotEmpty
                  ? ListView.builder(
                      itemCount: filteredMembers.length,
                      itemBuilder: (context, index) {
                        final member = filteredMembers[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.pinkAccent.shade700,
                              child: Text(
                                member['firstName'][0],
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text('${member['firstName']} ${member['lastName']}'),
                            subtitle: Text('Username: ${member['email']}'),
                          ),
                        );
                      },
                    )
                  : const Center(child: Text('No members found')),
            ),
          ],
        ),
      ),
    );
  }
}
