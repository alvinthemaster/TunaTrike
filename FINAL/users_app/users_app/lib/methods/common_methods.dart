import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import 'package:users_app/appInfo/app_info.dart';
import 'package:users_app/global/global_var.dart';
import 'package:users_app/models/address_model.dart';
import '../models/direction_details.dart';

class CommonMethods {
  final databaseReference = FirebaseDatabase.instance.ref();

  checkConnectivity(BuildContext context) async {
    var connectionResult = await Connectivity().checkConnectivity();
    if (connectionResult != ConnectivityResult.mobile &&
        connectionResult != ConnectivityResult.wifi) {
      if (!context.mounted) return;
      displaySnackBar("", context);
    }
  }

  displaySnackBar(String messageText, BuildContext context) {
    var snackBar = SnackBar(content: Text(messageText));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static Future<dynamic> sendRequestToAPI(String apiUrl) async {
    try {
      final responseFromAPI = await http.get(Uri.parse(apiUrl));
      if (responseFromAPI.statusCode == 200) {
        return jsonDecode(responseFromAPI.body);
      } else {
        return {
          "error":
              "Failed to fetch data. Status code: ${responseFromAPI.statusCode}"
        };
      }
    } catch (e) {
      return {"error": "An error occurred: $e"};
    }
  }

  static Future<String> convertGeoGraphicCoOrdinatesIntoHumanReadableAddress(
      Position position, BuildContext context) async {
    String humanReadableAddress = "";
    String apiGeoCodingUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$googleMapKey";

    var responseFromAPI = await sendRequestToAPI(apiGeoCodingUrl);

    if (responseFromAPI != "error") {
      humanReadableAddress = responseFromAPI["results"][0]["formatted_address"];
      AddressModel model = AddressModel();
      model.humanReadableAddress = humanReadableAddress;
      model.placeName = humanReadableAddress;
      model.longitudePosition = position.longitude;
      model.latitudePosition = position.latitude;

      Provider.of<AppInfo>(listen: false, context).updatePickUpLocation(model);
    }

    return humanReadableAddress;
  }

  Future<double> getMinimumFareFromDatabase() async {
    try {
      DatabaseEvent event =
          await databaseReference.child('fares/minimumFare').once();
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.exists) {
        return double.parse(snapshot.value.toString());
      } else {
        return 15.0;
      }
    } catch (e) {
      return 15.0;
    }
  }

  static Future<DirectionDetails?> getDirectionDetailsFromAPI(
      LatLng source, LatLng destination) async {
    String urlDirectionsAPI =
        "https://maps.googleapis.com/maps/api/directions/json?destination=${destination.latitude},${destination.longitude}&origin=${source.latitude},${source.longitude}&mode=driving&key=$googleMapKey";

    var responseFromDirectionsAPI = await sendRequestToAPI(urlDirectionsAPI);

    // Debugging: Print the entire response
    debugPrint("Directions API response: $responseFromDirectionsAPI");

    if (responseFromDirectionsAPI == "error" ||
        responseFromDirectionsAPI["routes"].isEmpty) {
      debugPrint("Error: Direction API returned no data");
      return null;
    }

    DirectionDetails detailsModel = DirectionDetails();

    var leg = responseFromDirectionsAPI["routes"][0]["legs"][0];

    // Debugging: Print the leg data
    debugPrint("Leg data: $leg");

    if (leg["distance"] == null || leg["duration"] == null) {
      debugPrint(
          "Error: Distance or duration data is missing from API response");
      return null;
    }

    detailsModel.distanceTextString = leg["distance"]["text"];
    detailsModel.distanceValueDigits = leg["distance"]["value"];
    detailsModel.durationTextString = leg["duration"]["text"];
    detailsModel.durationValueDigits = leg["duration"]["value"];
    detailsModel.encodedPoints =
        responseFromDirectionsAPI["routes"][0]["overview_polyline"]["points"];

    // Debugging: Print distance and duration values
    debugPrint(
        "Distance: ${detailsModel.distanceValueDigits}, Duration: ${detailsModel.durationValueDigits}");

    return detailsModel;
  }

  Future<String> calculateFareAmount(DirectionDetails directionDetails) async {
    double farePerKilometer = 1;
    double minimumFare = await getMinimumFareFromDatabase();

    double totalDistanceTravel = directionDetails.distanceValueDigits! / 1000;
    double overallTotalFareAmount;

    if (totalDistanceTravel > 4) {
      overallTotalFareAmount =
          minimumFare + ((totalDistanceTravel - 4) * farePerKilometer);
    } else {
      overallTotalFareAmount = minimumFare;
    }
    return overallTotalFareAmount.toStringAsFixed(2);
  }
}
