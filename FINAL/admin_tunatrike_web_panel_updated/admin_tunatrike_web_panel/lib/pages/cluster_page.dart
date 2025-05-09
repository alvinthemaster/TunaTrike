import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../methods/common_methods.dart';

class ClusterPage extends StatefulWidget {
  static const String id = "\webPageCluster";

  const ClusterPage({super.key});

  @override
  State<ClusterPage> createState() => _ClusterPageState();
}

class _ClusterPageState extends State<ClusterPage> {
  CommonMethods cMethods = CommonMethods();
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();

  List<String> locations = [];
  List<Map<String, dynamic>> clustersData = [];
  List<Map<String, dynamic>> faresData = [];
  String? selectedLocation1;
  String? selectedLocation2;
  String? selectedCluster;
  String? selectedLocationForFare;

  final List<String> availableClusters = [
    "Cluster 1",
    "Cluster 2",
    "Cluster 3",
    "Cluster 4"
  ];

  @override
  void initState() {
    super.initState();
    fetchLocations();
    fetchClusters();
    fetchFares();
  }

  Future<void> fetchLocations() async {
    DataSnapshot snapshot = await _databaseReference.child('locations').get();
    if (snapshot.exists) {
      Map<dynamic, dynamic> locationData =
          snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        locations =
            locationData.values.map((loc) => loc['name'] as String).toList();
      });
    }
  }

  Future<void> fetchClusters() async {
    DataSnapshot snapshot = await _databaseReference.child('clusters').get();
    if (snapshot.exists) {
      Map<dynamic, dynamic> clusterData =
          snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        clustersData = clusterData.entries.map((entry) {
          return {
            'location1': entry.value['location1'],
            'location2': entry.value['location2'],
            'cluster': entry.value['cluster'],
          };
        }).toList();
      });
    }
  }

  Future<void> fetchFares() async {
    DataSnapshot snapshot = await _databaseReference.child('fares').get();
    if (snapshot.exists) {
      Map<dynamic, dynamic> fareData = snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        faresData = fareData.entries.map((entry) {
          return {
            'location_pair': entry.value['location_pair'],
            'fare': entry.value['fare'],
          };
        }).toList();
      });
    }
  }

  void _openAddLocationModal() {
    TextEditingController locationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Location"),
          content: TextField(
            controller: locationController,
            decoration: const InputDecoration(labelText: "Location"),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                String location = locationController.text.trim();
                if (location.isNotEmpty) {
                  await _databaseReference.child('locations').push().set({
                    'name': location,
                  });
                  Navigator.of(context).pop();
                  fetchLocations();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Location added successfully")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter a location")),
                  );
                }
              },
              child: const Text("Save"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void _openAddClusterModal() {
    selectedLocation1 = null;
    selectedLocation2 = null;
    selectedCluster = null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Cluster"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedLocation1,
                decoration:
                    const InputDecoration(labelText: "Select Location 1"),
                items: locations.map((location) {
                  return DropdownMenuItem(
                    value: location,
                    child: Text(location),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedLocation1 = value;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                value: selectedLocation2,
                decoration:
                    const InputDecoration(labelText: "Select Location 2"),
                items: locations.map((location) {
                  return DropdownMenuItem(
                    value: location,
                    child: Text(location),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedLocation2 = value;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                value: selectedCluster,
                decoration: const InputDecoration(labelText: "Select Cluster"),
                items: availableClusters.map((cluster) {
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
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (selectedLocation1 != null &&
                    selectedLocation2 != null &&
                    selectedCluster != null) {
                  await _databaseReference.child('clusters').push().set({
                    'location1': selectedLocation1,
                    'location2': selectedLocation2,
                    'cluster': selectedCluster,
                  });
                  Navigator.of(context).pop();
                  fetchClusters();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Cluster added successfully")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text("Please select both locations and a cluster")),
                  );
                }
              },
              child: const Text("Save"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void _openModifyFareModal() {
    TextEditingController fareController = TextEditingController();
    selectedLocationForFare = null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Modify Fare"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedLocationForFare,
                decoration:
                    const InputDecoration(labelText: "Select Location Pair"),
                items: clustersData.map((cluster) {
                  String combinedLocation =
                      '${cluster['location1']} - ${cluster['location2']}';
                  return DropdownMenuItem(
                    value: combinedLocation,
                    child: Text(combinedLocation),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedLocationForFare = value;
                  });
                },
              ),
              TextField(
                controller: fareController,
                decoration: const InputDecoration(labelText: "Enter Fare"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (selectedLocationForFare != null &&
                    fareController.text.isNotEmpty) {
                  await _databaseReference.child('fares').push().set({
                    'location_pair': selectedLocationForFare,
                    'fare': fareController.text.trim(),
                  });
                  Navigator.of(context).pop();
                  fetchFares();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Fare modified successfully")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please fill all fields")),
                  );
                }
              },
              child: const Text("Save"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  List<Map<String, dynamic>> getClusterFareList() {
    return clustersData.map((cluster) {
      String locationPair = '${cluster['location1']} - ${cluster['location2']}';
      String fare = faresData.firstWhere(
        (fare) => fare['location_pair'] == locationPair,
        orElse: () => {'fare': 'N/A'},
      )['fare'];
      return {
        'location1': cluster['location1'],
        'location2': cluster['location2'],
        'cluster': cluster['cluster'],
        'fare': fare,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final clusterFareList = getClusterFareList();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Manage Clusters",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _openAddClusterModal,
                    tooltip: 'Add Cluster',
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _openAddLocationModal,
                    child: const Text("Add Location"),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  cMethods.header(1, "Location 1"),
                  cMethods.header(1, "Location 2"),
                  cMethods.header(1, "Cluster"),
                ],
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: clusterFareList.length,
                itemBuilder: (context, index) {
                  final item = clusterFareList[index];
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      cMethods.data(1, Text(item['location1'])),
                      cMethods.data(1, Text(item['location2'])),
                      cMethods.data(1, Text(item['cluster'])),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
