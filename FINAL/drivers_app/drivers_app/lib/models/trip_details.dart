import 'package:google_maps_flutter/google_maps_flutter.dart';

class TripDetails
{
  String? tripID;

  LatLng? pickUpLatLng;
  String? pickupAddress;

  LatLng? dropOffLatLng;
  String? dropOffAddress;

  String? userName;
  String? userPhone;
  String? discountType;
  double? fareAmount;
  bool? isStudent; // New field
  bool? isSenior;

  TripDetails({
    this.tripID,
    this.pickUpLatLng,
    this.pickupAddress,
    this.dropOffLatLng,
    this.dropOffAddress,
    this.userName,
    this.userPhone,
    this.discountType,
    this.fareAmount,
    this.isStudent = false, // Default value
    this.isSenior = false,
  });
}