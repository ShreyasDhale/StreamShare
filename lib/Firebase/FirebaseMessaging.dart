import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:stream_share/globals/Constants.dart';
import 'package:stream_share/globals/Message.dart';

class Messaging {
  static Future<void> requestPermissions() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    final status = settings.authorizationStatus;

    if (status == AuthorizationStatus.authorized) {
      print("User Granted permission");
    } else if (status == AuthorizationStatus.provisional) {
      print("User Granted Provisonal permissions");
    } else {
      print("User Declined");
    }
  }

  static Future<void> getToken() async {
    await messaging.getToken().then((tok) => token = tok!);
    print(
        "*******************************************************************************\n$token\n******************************************************************************");
  }

  static void initInfo() {
    var androidInitilization =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initilizationSettings =
        InitializationSettings(android: androidInitilization);
    fps.initialize(initilizationSettings);
    try {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        print("..................ON MESSAGE....................");
        print(
            "onMessage: ${message.notification?.title}/${message.notification?.body}");

        BigTextStyleInformation bigTextStyleInformation =
            BigTextStyleInformation(message.notification!.body.toString(),
                htmlFormatBigText: true,
                contentTitle: message.notification!.title.toString(),
                htmlFormatContentTitle: true);

        AndroidNotificationDetails androidChannelSpecifics =
            AndroidNotificationDetails("Aptitude_notify", "Aptitude_notify",
                importance: Importance.max,
                styleInformation: bigTextStyleInformation,
                priority: Priority.max,
                playSound: true);

        NotificationDetails platformChannelSpecifics =
            NotificationDetails(android: androidChannelSpecifics);

        await fps.show(0, message.notification?.title,
            message.notification?.body, platformChannelSpecifics,
            payload: message.data['title']);
      });
    } catch (e) {
      print(e);
    }
  }

  static Future<void> notifyAllUsers(
      String title, String body, BuildContext context) async {
    List<String> tokens = [];
    await userCollection.get().then((value) {
      for (var doc in value.docs) {
        var data = doc.data() as Map<String, dynamic>;
        if (!tokens.contains(data["Token"])) {
          tokens.add(data["Token"]);
        }
      }
    });
    for (int count = 0; count < tokens.length; count++) {
      await sendPushMessage(tokens[count], body, title);
    }
    showSuccessSnackBar(context, "Notified All Users");
  }

  static Future<void> sendPushMessage(
      String token, String body, String title) async {
    try {
      http.post(Uri.parse("https://fcm.googleapis.com/fcm/send"),
          headers: <String, String>{
            'Content-type': 'application/json',
            'Authorization':
                'key=AAAAsym1Rjc:APA91bECgnUxGHxxAvOcGBC07Qmt8ztGUwm0y5HsoYZhjKPJp9g_-byz8zjEAz3zW96F53HF9mdWb3OvSW2iMXwp2RHBUq-Vd1xa1Gg7rJPMGALjxXhK3ajnaYIUHx5ZiZtIQYUIkPw_',
          },
          body: jsonEncode(<String, dynamic>{
            'priority': 'high',
            'data': <String, dynamic>{
              'click-action': 'FLUTTER_NOTIFICATION_CLICK',
              'status': 'done',
              'body': body,
              'title': title
            },
            'notification': <String, dynamic>{
              'title': title,
              'body': body,
              'android_channel_id': 'Aptitude_notify'
            },
            'to': token,
          }));
    } on HttpException catch (e) {
      print("***************************************************");
      print(e.message);
      print("***************************************************");
    } on Exception catch (e) {
      print("***************************************************");
      print(e);
      print("***************************************************");
    }
  }
}
