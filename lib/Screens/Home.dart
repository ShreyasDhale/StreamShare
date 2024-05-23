import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stream_share/Widget/widgets.dart';
import 'package:stream_share/globals/Constants.dart';
import 'package:stream_share/globals/globals.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    configureLocationServices(context);
    currentUser = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        backgroundColor: Colors.grey.shade200,
        unselectedItemColor: Colors.black54,
        selectedItemColor: Colors.black,
        showUnselectedLabels: false,
        onTap: (value) {
          setState(() {
            currentIndex = value;
          });
        },
        selectedLabelStyle: GoogleFonts.poppins(color: Colors.black),
        unselectedLabelStyle: GoogleFonts.poppins(color: Colors.black87),
        // onTap: changeScreen,
        showSelectedLabels: false,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'home',
            activeIcon: Icon(
              Icons.home,
              size: 30,
            ),
          ),
          BottomNavigationBarItem(
              icon: customButton(
                  text: '+',
                  onTap: () {
                    setState(() {
                      currentIndex = 1;
                    });
                  },
                  fontSize: 30,
                  fontWeight: FontWeight.w300,
                  borderRadius: 10,
                  width: 70,
                  height: 40),
              label: ""),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
            activeIcon: Icon(
              Icons.person,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}
