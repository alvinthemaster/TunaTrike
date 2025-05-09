import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../methods/common_methods.dart';

class DriversDataList extends StatefulWidget {
  final String searchQuery;

  const DriversDataList({super.key, required this.searchQuery});

  @override
  State<DriversDataList> createState() => _DriversDataListState();
}

class _DriversDataListState extends State<DriversDataList> {
  final driversRecordsFromDatabase =
      FirebaseDatabase.instance.ref().child("drivers");
  CommonMethods cMethods = CommonMethods();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: driversRecordsFromDatabase.onValue,
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

        if (snapshotData.data == null ||
            snapshotData.data!.snapshot.value == null) {
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
        dataMap.forEach((key, value) {
          itemsList.add({"key": key, ...value});
        });
        itemsList.sort((a, b) => b["createdAt"].compareTo(a["createdAt"]));
        List filteredList = itemsList.where((driver) {
          return driver["email"]
                  .toString()
                  .toLowerCase()
                  .contains(widget.searchQuery) ||
              driver["name"]
                  .toString()
                  .toLowerCase()
                  .contains(widget.searchQuery) ||
              driver["phone"]
                  .toString()
                  .toLowerCase()
                  .contains(widget.searchQuery);
        }).toList();

        return ListView.builder(
          shrinkWrap: true,
          itemCount: filteredList.length,
          itemBuilder: (context, index) {
            DateTime createdAt = DateTime.fromMillisecondsSinceEpoch(
                filteredList[index]["createdAt"]);
            String formattedDate =
                DateFormat('yyyy-MM-dd HH:mm').format(createdAt);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  cMethods.data(
                    1,
                    Text(filteredList[index]["email"].toString()),
                  ),
                  cMethods.data(
                    1,
                    Text(filteredList[index]["name"].toString()),
                  ),
                  cMethods.data(
                    1,
                    Text(filteredList[index]["phone"].toString()),
                  ),
                  cMethods.data(
                    1,
                    Text(formattedDate),
                  ),
                  cMethods.data(
                    1,
                    Row(
                      children: [
                        // View Details Button
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DriverDetailsScreen(
                                  driverData: filteredList[index],
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          child: const Text(
                            "View Details",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10), // Spacing between buttons

                        // Block/Unblock Button
                        filteredList[index]["blockStatus"] == "no"
                            ? ElevatedButton(
                                onPressed: () async {
                                  await FirebaseDatabase.instance
                                      .ref()
                                      .child("drivers")
                                      .child(filteredList[index]["key"])
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
                                      .child("drivers")
                                      .child(filteredList[index]["key"])
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
                      ],
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

class DriverDetailsScreen extends StatelessWidget {
  final Map driverData;

  const DriverDetailsScreen({Key? key, required this.driverData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(driverData["name"] ?? "Driver Details"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(
              context,
              title: "Driver Picture",
              imageUrl: driverData["driverPictureUrl"],
            ),

            const SizedBox(height: 16),
            _buildInfoCard(
              title: "Driver Information",
              items: [
                _buildInfoRow("Email", driverData["email"]),
                _buildInfoRow("Name", driverData["name"]),
                _buildInfoRow("Phone", driverData["phone"]),
                _buildInfoRow("Block Status",
                    driverData["blockStatus"] == 'no' ? 'Active' : 'Blocked'),
              ],
            ),
            if (driverData.containsKey("trike_details"))
              _buildInfoCard(
                title: "Trike Details",
                items: [
                  _buildInfoRow(
                      "Trike Model", driverData["trike_details"]["trikeModel"]),
                  _buildInfoRow("Plate Number",
                      driverData["trike_details"]["plateNumber"]),
                  _buildInfoRow(
                      "Cluster", driverData["trike_details"]["cluster"]),
                ],
              ),
            const SizedBox(height: 16),
            Container(
              child: Row(
                children: [
                  _buildImageSection(
                    context,
                    title: "License Image",
                    imageUrl: driverData["licenseImageUrl"],
                  ),
                  const SizedBox(height: 16),
                  _buildImageSection(
                    context,
                    title: "OR/CR Image",
                    imageUrl: driverData["orcrImageUrl"],
                  ),
                  const SizedBox(height: 16),
                  _buildImageSection(
                    context,
                    title: "Plate Image",
                    imageUrl: driverData["plateImageUrl"],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  Widget _buildInfoCard({required String title, required List<Widget> items}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Column(children: items),
          ],
        ),
      ),
    );
  }
  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value ?? "-",
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildImageSection(BuildContext context,
      {required String title, required String? imageUrl}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (imageUrl != null)
          Image.network(
            imageUrl,
            height: 150,
            width: 150,
            loadingBuilder: (BuildContext context, Widget child,
                ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          (loadingProgress.expectedTotalBytes ?? 1)
                      : null,
                ),
              );
            },
            errorBuilder: (BuildContext context, Object exception,
                StackTrace? stackTrace) {
              return const Icon(Icons.error,
                  size: 150);
            },
          )
        else
          const Icon(Icons.image_not_supported, size: 150),
      ],
    );
  }
}
