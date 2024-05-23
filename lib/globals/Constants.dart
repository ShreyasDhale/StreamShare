import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

User? currentUser;

// Collections

CollectionReference postCollection =
    FirebaseFirestore.instance.collection("Post");
CollectionReference userCollection =
    FirebaseFirestore.instance.collection("Users");

// Storage Bucket

FirebaseStorage bucket = FirebaseStorage.instance;

// Firebase Messaging

FirebaseMessaging messaging = FirebaseMessaging.instance;
String token = "";
FlutterLocalNotificationsPlugin fps = FlutterLocalNotificationsPlugin();
