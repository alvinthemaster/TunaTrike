import 'package:flutter/material.dart';
import '../methods/common_methods.dart';
import '../widgets/drivers_data_list.dart';

class DriversPage extends StatefulWidget {
  static const String id = "\webPageDrivers";

  const DriversPage({super.key});

  @override
  State<DriversPage> createState() => _DriversPageState();
}

class _DriversPageState extends State<DriversPage> {
  CommonMethods cMethods = CommonMethods();
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  void updateSearchQuery(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.topLeft,
                child: const Text(
                  "Manage Drivers",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: searchController,
                onChanged: updateSearchQuery,
                decoration: InputDecoration(
                  labelText: 'Search',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 18),

              Row(
                children: [
                  cMethods.header(1, "EMAIL"),
                  cMethods.header(1, "NAME"),
                  cMethods.header(1, "PHONE"),
                  cMethods.header(1, "TIME CREATED"),
                  cMethods.header(1, "ACTION"),
                ],
              ),
              DriversDataList(searchQuery: searchQuery),
            ],
          ),
        ),
      ),
    );
  }
}
