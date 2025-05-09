import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ModifyFair extends StatefulWidget {
  static const String id = "\webPageModify";

  const ModifyFair({super.key});

  @override
  State<ModifyFair> createState() => _ModifyFairState();
}

class _ModifyFairState extends State<ModifyFair> {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  double currentMinimumFare = 0.0;
  final TextEditingController fareController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchCurrentMinimumFare();
  }

  Future<void> fetchCurrentMinimumFare() async {
    DataSnapshot snapshot = await _databaseReference.child('fares/minimumFare').get();
    if (snapshot.exists) {
      setState(() {
        currentMinimumFare = snapshot.value as double;
      });
    }
  }

  Future<void> updateMinimumFare() async {
    double newFare = double.tryParse(fareController.text.trim()) ?? currentMinimumFare;
    await _databaseReference.child('fares/minimumFare').set(newFare);
    fareController.clear();
    fetchCurrentMinimumFare();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Minimum fare updated successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Modify Minimum Fare")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Current Minimum Fare: \$${currentMinimumFare.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: fareController,
              decoration: const InputDecoration(
                labelText: "Enter New Minimum Fare",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateMinimumFare,
              child: const Text("Update Minimum Fare"),
            ),
          ],
        ),
      ),
    );
  }
}
