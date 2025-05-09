import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../methods/common_methods.dart';
import 'driverfeedbackpage.dart'; // Import your new page

class FeedbackList extends StatefulWidget {
  const FeedbackList({super.key});

  @override
  State<FeedbackList> createState() => _FeedDataListState();
}

class _FeedDataListState extends State<FeedbackList> {
  final completedTripsRecordsFromDatabase =
      FirebaseDatabase.instance.ref().child("tripRequests");
  CommonMethods cMethods = CommonMethods();

  // Function to calculate average rating
  double calculateAverage(List<double> ratings) {
    if (ratings.isEmpty) return 0.0;
    double sum = ratings.reduce((a, b) => a + b);
    return sum / ratings.length;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: completedTripsRecordsFromDatabase.onValue,
      builder: (BuildContext context, snapshotData) {
        if (snapshotData.hasError) {
          return const Center(
            child: Text(
              "Error Occurred. Try Later.",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.pink,
              ),
            ),
          );
        }

        if (snapshotData.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshotData.data?.snapshot.value == null) {
          return const Center(
            child: Text(
              "NO CURRENT DATA",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.grey,
              ),
            ),
          );
        }

        Map dataMap = snapshotData.data!.snapshot.value as Map;
        Map<String, List<Map<String, dynamic>>> driverFeedbackMap = {};

        // Group feedback by driver and filter out empty comments
        dataMap.forEach((key, value) {
          if (value["status"] == "ended" &&
              value["comment"] != null &&
              value["comment"].toString().isNotEmpty) {
            String driverName = value["driverName"];
            if (!driverFeedbackMap.containsKey(driverName)) {
              driverFeedbackMap[driverName] = [];
            }
            driverFeedbackMap[driverName]!.add({
              "comment": value["comment"],
              "rating": double.tryParse(value["rating"].toString()) ?? 0.0,
            });
          }
        });

        return ListView.builder(
          shrinkWrap: true,
          itemCount: driverFeedbackMap.length,
          itemBuilder: (context, index) {
            String driverName = driverFeedbackMap.keys.elementAt(index);
            List<Map<String, dynamic>> feedbackList =
                driverFeedbackMap[driverName]!; // Ensure correct type here
            List<double> ratings =
                feedbackList.map((f) => f["rating"] as double).toList();

            // Calculate average rating
            double averageRating = calculateAverage(ratings);

            return Card(
              elevation: 3,
              margin: const EdgeInsets.all(10),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Driver: $driverName",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Average Rating: ${averageRating.toStringAsFixed(1)}",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 5),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to the DriverFeedbackPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DriverFeedbackPage(
                              driverName: driverName,
                              feedbackList: List<Map<String, dynamic>>.from(feedbackList), // Type cast here
                            ),
                          ),
                        );
                      },
                      child: const Text("View Ratings"),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
