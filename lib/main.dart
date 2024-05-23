import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:stream_share/Firebase/FirebaseMessaging.dart';
import 'package:stream_share/Screens/Home.dart';
import 'package:stream_share/firebase_options.dart';
import 'package:stream_share/globals/globals.dart';
import 'package:stream_share/login/Screens/signin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Messaging.requestPermissions();
  Messaging.initInfo();
  Messaging.getToken();
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget? screen;

  @override
  void initState() {
    super.initState();
    getScreen();
    getCurrentLocation(context);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: screen,
    );
  }

  void getScreen() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        screen = const SignIn();
      });
    } else {
      setState(() {
        screen = const HomeScreen();
      });
    }
  }
}
