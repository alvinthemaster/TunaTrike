import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

String userName = "";
String userPhone = "";
String quantity = "";
String discountType= "";
String userID = FirebaseAuth.instance.currentUser!.uid;

String googleMapKey = "AIzaSyCAcjB8a6SEorp0sgZGxBkSH-XZpJ1Dnn0";

const CameraPosition googlePlexInitialPosition = CameraPosition(
  target: LatLng(6.115631274998012, 125.17184179376108),
  zoom: 14.4746,
);





