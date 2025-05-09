import 'package:flutter/material.dart';

class DriverFeedbackPage extends StatelessWidget {
  final String driverName;
  final List<Map<String, dynamic>> feedbackList;

  const DriverFeedbackPage({
    Key? key,
    required this.driverName,
    required this.feedbackList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Feedback for $driverName"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: feedbackList.isNotEmpty
            ? ListView.builder(
                itemCount: feedbackList.length,
                itemBuilder: (context, index) {
                  final feedback = feedbackList[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Rating: ${feedback['rating'].toStringAsFixed(1)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "Comment: ${feedback['comment']}",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
            : const Center(child: Text("No feedback available")),
      ),
    );
  }
}
