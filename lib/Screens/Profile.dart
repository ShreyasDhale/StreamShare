import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stream_share/Screens/CompleteProfile.dart';
import 'package:stream_share/Widget/UserPost.dart';
import 'package:stream_share/Widget/widgets.dart';
import 'package:stream_share/globals/Constants.dart';
import 'package:stream_share/globals/globals.dart';
import 'package:stream_share/login/Screens/signin.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String id = "";
  Map<String, dynamic> data = {};

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void setId(String uid) {
    if (mounted) {
      setState(() {
        id = uid;
      });
    }
  }

  Future<void> getUserData() async {
    await getCurrentUserId(currentUser!.phoneNumber!, setId);
    await userCollection.doc(id).get().then((value) => setState(() {
          data = value.data() as Map<String, dynamic>;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Image.asset(
          "Assets/Images/icon.png",
        ),
        title: Text(
          "Profile",
          style: style,
        ),
        centerTitle: false,
        backgroundColor: Colors.grey.shade200,
        actions: [
          IconButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (builder) => const SignIn()),
                    (route) => false);
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                ProfileAvatar(
                  data: data,
                  radius: 50,
                ),
                Expanded(
                    child: SizedBox(
                  child: ListTile(
                    title: data['Name'] == ""
                        ? Text(
                            "${data['Phone']}",
                            style: style.copyWith(fontSize: 15),
                          )
                        : Text(
                            "${data['Name']}",
                            style: style.copyWith(
                                fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                    subtitle: (data['Name'] != "" || data['Bio'] != "")
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.phone),
                                  data['Name'] != ""
                                      ? Text(
                                          "${data['Phone']}",
                                          style: style.copyWith(fontSize: 15),
                                        )
                                      : const SizedBox(),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.info),
                                  const SizedBox(
                                    width: 3,
                                  ),
                                  data['Bio'] != ""
                                      ? Text("${data['Bio']}")
                                      : const SizedBox(),
                                ],
                              ),
                            ],
                          )
                        : null,
                  ),
                ))
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            customButton(
                text: (data['Name'] == "" || data['Bio'] == "")
                    ? "Complete Profile"
                    : "Update Profile",
                fontWeight: FontWeight.normal,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => CompleteProfile(
                        id: id,
                        title: (data['Name'] == "" || data['Bio'] == "")
                            ? "Complete Profile"
                            : "Update Profile",
                        data: data))),
                borderRadius: 5),
            const SizedBox(
              height: 20,
            ),
            Container(
              color: Colors.black,
              height: 1.5,
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              "My Posts",
              style: GoogleFonts.stylish(
                  fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(
              height: 15,
            ),
            Container(
              color: Colors.black,
              height: 1.5,
            ),
            const SizedBox(
              height: 20,
            ),
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("Post")
                    .where("userId", isEqualTo: id)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData && snapshot.data != null) {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height * 0.42,
                        child: ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              var data = snapshot.data!.docs[index].data();
                              String id = snapshot.data!.docs[index].id;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 15.0),
                                child: UserPost(
                                  data: data,
                                  id: id,
                                ),
                              );
                            }),
                      );
                    } else {
                      return const Text("No Data");
                    }
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.black,
                      ),
                    );
                  } else {
                    print("Connection state is not active!");
                    return const Center(
                      child: Text(
                        "No data !!",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }
                })
          ],
        ),
      ),
    );
  }
}

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.data,
    required this.radius,
  });

  final Map<String, dynamic> data;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: (data["profilePicUrl"] != "" && data["profilePicUrl"] != null)
          ? CircleAvatar(
              foregroundImage: NetworkImage("${data["profilePicUrl"]}"),
              radius: radius,
            )
          : CircleAvatar(
              backgroundImage: const AssetImage("Assets/Images/profile.png"),
              radius: radius,
            ),
    );
  }
}
