import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drivers_app/global/global_var.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart'; // Import Firebase Database

import '../models/direction_details.dart';

class CommonMethods {
  double minimumFare = 0.0; // Variable to hold the minimum fare fetched from Firebase

  // Function to fetch minimum fare from Firebase
  Future<void> getMinimumFareFromFirebase() async {
    DatabaseReference fareRef = FirebaseDatabase.instance.ref().child("fares").child("minimumFare");

    print("Fetching minimum fare from Firebase...");
    try {
      DataSnapshot snapshot = await fareRef.get();
      if (snapshot.exists) {
        minimumFare = double.parse(snapshot.value.toString());
        print("Minimum fare fetched from Firebase: $minimumFare");
      } else {
        minimumFare = 15.0; // Default value if no minimum fare is found in the database
        print("Minimum fare not found in Firebase. Using default: $minimumFare");
      }
    } catch (error) {
      print("Error fetching minimum fare: $error");
      minimumFare = 15.0; // Fallback to default minimum fare in case of error
      print("Using default minimum fare: $minimumFare");
    }
  }

  // Function to check internet connectivity
  checkConnectivity(BuildContext context) async {
    print("Checking connectivity...");
    var connectionResult = await Connectivity().checkConnectivity();
    if (connectionResult != ConnectivityResult.mobile && connectionResult != ConnectivityResult.wifi) {
      if (!context.mounted) return;
      print("No internet connection detected.");
    } else {
      print("Connected to the internet.");
    }
  }

  // Function to display a SnackBar
  displaySnackBar(String messageText, BuildContext context) {
    print("Displaying snack bar: $messageText");
    var snackBar = SnackBar(content: Text(messageText));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Function to turn off location updates on the home page
  turnOffLocationUpdatesForHomePage() {
    print("Turning off location updates for home page...");
    positionStreamHomePage!.pause();
    Geofire.removeLocation(FirebaseAuth.instance.currentUser!.uid);
    print("Location updates turned off and removed from Geofire.");
  }

  // Function to turn on location updates on the home page
  turnOnLocationUpdatesForHomePage() {
    print("Turning on location updates for home page...");
    positionStreamHomePage!.resume();
    Geofire.setLocation(
      FirebaseAuth.instance.currentUser!.uid,
      driverCurrentPosition!.latitude,
      driverCurrentPosition!.longitude,
    );
    print("Location updates resumed and updated in Geofire.");
  }

  // Static function to send a request to an API
  static sendRequestToAPI(String apiUrl) async {
    print("Sending request to API: $apiUrl");
    http.Response responseFromAPI = await http.get(Uri.parse(apiUrl));

    try {
      if (responseFromAPI.statusCode == 200) {
        String dataFromApi = responseFromAPI.body;
        print("API response received successfully.");
        var dataDecoded = jsonDecode(dataFromApi);
        return dataDecoded;
      } else {
        print("Error in API response: Status code ${responseFromAPI.statusCode}");
        return "error";
      }
    } catch (errorMsg) {
      print("Error parsing API response: $errorMsg");
      return "error";
    }
  }

  // Static function to get direction details from API
  static Future<DirectionDetails?> getDirectionDetailsFromAPI(LatLng source, LatLng destination) async {
    String urlDirectionsAPI =
        "https://maps.googleapis.com/maps/api/directions/json?destination=${destination.latitude},${destination.longitude}&origin=${source.latitude},${source.longitude}&mode=driving&key=$googleMapKey";

    print("Fetching directions from API: $urlDirectionsAPI");
    var responseFromDirectionsAPI = await sendRequestToAPI(urlDirectionsAPI);

    if (responseFromDirectionsAPI == "error") {
      print("Error fetching directions from API.");
      return null;
    }

    print("Parsing direction details...");
    DirectionDetails detailsModel = DirectionDetails();

    detailsModel.distanceTextString = responseFromDirectionsAPI["routes"][0]["legs"][0]["distance"]["text"];
    detailsModel.distanceValueDigits = responseFromDirectionsAPI["routes"][0]["legs"][0]["distance"]["value"];

    detailsModel.durationTextString = responseFromDirectionsAPI["routes"][0]["legs"][0]["duration"]["text"];
    detailsModel.durationValueDigits = responseFromDirectionsAPI["routes"][0]["legs"][0]["duration"]["value"];

    detailsModel.encodedPoints = responseFromDirectionsAPI["routes"][0]["overview_polyline"]["points"];

    print("Direction details parsed successfully.");
    return detailsModel;
  }

  Future<String> calculateFareAmount(DirectionDetails directionDetails) async {
    print("Calculating fare amount...");
    await getMinimumFareFromFirebase();

    double farePerKilometer = 1;
    double totalDistanceTravel = directionDetails.distanceValueDigits! / 1000;
    double overAllTotalFareAmount;

    print("Total distance traveled: $totalDistanceTravel km");
    if (totalDistanceTravel > 4) {
      overAllTotalFareAmount = minimumFare + (totalDistanceTravel * farePerKilometer);
      print("Fare calculated with distance: $overAllTotalFareAmount");
    } else {
      overAllTotalFareAmount = minimumFare;
      print("Fare calculated using minimum fare: $overAllTotalFareAmount");
    }

    return overAllTotalFareAmount.toStringAsFixed(0);
  }

  getMinimumFareFromDatabase() {}
}
