import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stream_share/Screens/Eplore.dart';
import 'package:stream_share/Screens/Profile.dart';
import 'package:stream_share/Screens/RecordVideo.dart';

// Lists

List<String> categories = [];

// Cover File

File? cover;

// Cameras

List<CameraDescription> cameras = [];

// Style

TextStyle style = GoogleFonts.poppins();

// List Widgets(Screens)

List<Widget> screens = [const Explore(), const RecordVideo(), const Profile()];

// Functions

Future<void> getCurrentUserId(String phone, Function setId) async {
  String data = "";
  await FirebaseFirestore.instance
      .collection("Users")
      .where("Phone", isEqualTo: phone)
      .get()
      .then((value) {
    var val = value.docs.first.data();
    data = val["UserId"];
    print("Phone : $phone UserId : $data");
    setId(data);
  });
}

Future<void> configureLocationServices(BuildContext context) async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {}
  }
}

Future<Map<String, dynamic>> getCurrentLocation(BuildContext context) async {
  try {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placemarks[0];
    print(
        "********************************************************************************************");
    print(
        'Address: ${place.name}, ${place.locality}, ${place.subAdministrativeArea}, ${place.administrativeArea}, ${place.country}');
    print(
        "********************************************************************************************");
    return {
      "street": place.street,
      "country": place.country,
      "area": place.locality,
      "city": place.subAdministrativeArea,
      "state": place.administrativeArea,
      "name": place.name,
      "postalCode": place.postalCode,
    };
  } catch (e) {
    debugPrint(e.toString());
    return {};
  }
}

Future<void> requestPermission() async {
  try {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.photos,
      Permission.videos,
      Permission.audio,
      Permission.camera,
    ].request();
    print(statuses);
  } on Exception catch (e, stackTrace) {
    debugPrintStack(stackTrace: stackTrace);
  }
}
