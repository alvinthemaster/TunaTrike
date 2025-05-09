import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class TripsHistoryPage extends StatefulWidget {
  const TripsHistoryPage({super.key});

  @override
  State<TripsHistoryPage> createState() => _TripsHistoryPageState();
}

class _TripsHistoryPageState extends State<TripsHistoryPage> {
  final completedTripRequestsOfCurrentUser =
      FirebaseDatabase.instance.ref().child("tripRequests");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Trips History',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: StreamBuilder(
        stream: completedTripRequestsOfCurrentUser.onValue,
        builder: (BuildContext context, snapshotData) {
          if (snapshotData.hasError) {
            return const Center(
              child: Text(
                "Error Occurred.",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          if (snapshotData.data?.snapshot.value == null) {
            return const Center(
              child: Text(
                "No record found.",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          Map dataTrips = snapshotData.data!.snapshot.value as Map;
          List tripsList = [];
          dataTrips
              .forEach((key, value) => tripsList.add({"key": key, ...value}));

          return ListView.builder(
            shrinkWrap: true,
            itemCount: tripsList.length,
            itemBuilder: (context, index) {
              if (tripsList[index]["status"] != null &&
                  tripsList[index]["status"] == "ended" &&
                  tripsList[index]["userID"] ==
                      FirebaseAuth.instance.currentUser!.uid) {
                return Card(
                  color: Colors.white12,
                  elevation: 10,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Image.asset('assets/images/initial.png',
                                height: 16, width: 16),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Text(
                                tripsList[index]["pickUpAddress"].toString(),
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white38,
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              "\₱ " + tripsList[index]["fareAmount"].toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Image.asset('assets/images/final.png',
                                height: 16, width: 16),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Text(
                                tripsList[index]["dropOffAddress"].toString(),
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white38,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Add Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () =>
                                  _showRatingDialog(tripsList[index]["key"]),
                              child: const Text(
                                'Rate',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 10),
                            TextButton(
                              onPressed: () =>
                                  _viewDigitalReceipt(tripsList[index]),
                              child: const Text(
                                'View Receipt',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return Container();
              }
            },
          );
        },
      ),
    );
  }

  void _showRatingDialog(String tripKey) {
  double? rating;
  TextEditingController commentController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Rate Your Trip'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Select a rating:'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return Container(
                      width: 40,
                      child: IconButton(
                        icon: Icon(
                          index < (rating ?? 0) ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                        ),
                        onPressed: () {
                          setState(() {
                            rating = index + 1.0;
                          });
                        },
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                const Text('Add a comment:'),
                TextField(
                  controller: commentController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Write your comment here',
                  ),
                  maxLines: 3,
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (rating != null) {
                _submitRating(tripKey, rating!, commentController.text);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Submit'),
          ),
        ],
      );
    },
  );
}


  void _submitRating(String tripKey, double rating, String comment) {
    final tripRef = completedTripRequestsOfCurrentUser.child(tripKey);
    tripRef.update({
      'rating': rating,
      'comment': comment,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rating submitted successfully!')),
    );
  }

  // New function to view the receipt
  void _viewDigitalReceipt(Map tripData) {
    // Show a dialog to display the receipt.
    showDialog(
      context: context,
      builder: (context) {
        // Safely retrieve fareAmount and convert it to double
        double fareAmount =
            double.tryParse(tripData["fareAmount"].toString()) ?? 0.0;
        double discount = 0.20; // 20% discount

        // Calculate the original fare before discount if applicable
        double originalFare = fareAmount / (1 - discount);

        // Determine if the discount should be shown
        bool showDiscountCalculation = tripData["discountType"] != null &&
            tripData["discountType"].toString().isNotEmpty &&
            tripData["discountType"].toString().toLowerCase() != "none" &&
            tripData["discountType"].toString().toLowerCase() != "n/a";

        return AlertDialog(
          title: const Text('Digital Receipt'),
          content: Container(
            // Add padding and set constraints for better presentation
            padding: const EdgeInsets.all(16),
            constraints: BoxConstraints(maxWidth: 400), // Limit width
            decoration: BoxDecoration(
              color: Colors.black54, // Background color
              borderRadius: BorderRadius.circular(10), // Rounded corners
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pick-up: ${tripData["pickUpAddress"]}',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Drop-off: ${tripData["dropOffAddress"]}',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Date: ${tripData["tripDate"] ?? "N/A"}',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Discount Type: ${tripData["discountType"] ?? "N/A"}',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 16),
                // Conditional display of the discount calculation
                if (showDiscountCalculation) ...[
                  Text(
                    'Amount Discounted: ₱ ${originalFare.toStringAsFixed(2)} = ₱ ${fareAmount.toStringAsFixed(2)} - 20%',
                    style: const TextStyle(color: Colors.green, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  'Total Fare: ₱ ${fareAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: Colors.red,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
