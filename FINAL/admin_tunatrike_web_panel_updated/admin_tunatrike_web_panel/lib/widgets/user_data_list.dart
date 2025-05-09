import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../methods/common_methods.dart';

class UsersDataList extends StatefulWidget {
  const UsersDataList({super.key});

  @override
  State<UsersDataList> createState() => _UsersDataListState();
}

class _UsersDataListState extends State<UsersDataList> {
  final usersRecordsFromDatabase = FirebaseDatabase.instance.ref().child("users");
  CommonMethods cMethods = CommonMethods();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: usersRecordsFromDatabase.onValue,
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

        if (snapshotData.data == null || snapshotData.data!.snapshot.value == null) {
          return const Center(
            child: Text(
              "No data available",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.grey,
              ),
            ),
          );
        }

        Map dataMap = snapshotData.data!.snapshot.value as Map;
        List itemsList = [];

        // Adding users to list
        dataMap.forEach((key, value) {
          itemsList.add({"key": key, ...value});
        });

        // Sort the list (newest first)
        itemsList.sort((a, b) => b["createdAt"].compareTo(a["createdAt"]));

        return ListView.builder(
          shrinkWrap: true,
          itemCount: itemsList.length,
          itemBuilder: (context, index) {
            //timestamp to readable date
            DateTime createdAt = DateTime.fromMillisecondsSinceEpoch(itemsList[index]["createdAt"]);
            String formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(createdAt); // Format date and time

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //email
                  cMethods.data(
                    1,
                    Text(itemsList[index]["email"].toString()),
                  ),

                  //name
                  cMethods.data(
                    1,
                    Text(itemsList[index]["name"].toString()),
                  ),

                  //phone number
                  cMethods.data(
                    1,
                    Text(itemsList[index]["phone"].toString()),
                  ),

                  // Display (date and time)
                  cMethods.data(
                    1,
                    Text(formattedDate),
                  ),

                  // Display block/approve button
                  cMethods.data(
                    1,
                    itemsList[index]["blockStatus"] == "no"
                        ? ElevatedButton(
                      onPressed: () async {
                        await FirebaseDatabase.instance
                            .ref()
                            .child("users")
                            .child(itemsList[index]["key"])
                            .update({"blockStatus": "yes"});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text(
                        "Block",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                        : ElevatedButton(
                      onPressed: () async {
                        await FirebaseDatabase.instance
                            .ref()
                            .child("users")
                            .child(itemsList[index]["key"])
                            .update({"blockStatus": "no"});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text(
                        "Approve",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
