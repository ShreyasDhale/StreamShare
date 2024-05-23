import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:stream_share/Screens/Home.dart';
import 'package:stream_share/Widget/widgets.dart';
import 'package:stream_share/globals/Constants.dart';
import 'package:stream_share/globals/Message.dart';
import 'package:stream_share/globals/globals.dart';
import 'package:uuid/uuid.dart';

class CompleteProfile extends StatefulWidget {
  final String id;
  final String title;
  final Map<String, dynamic> data;
  const CompleteProfile(
      {super.key, required this.id, required this.title, required this.data});

  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {
  var nameController = TextEditingController();
  var bioController = TextEditingController();

  double uploadProgress = 0;

  File? profilePic;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: style,
        ),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            InkWell(
              onTap: () async {
                FilePickerResult? result =
                    await FilePicker.platform.pickFiles(type: FileType.image);
                if (result != null) {
                  File converted = File(result.files.first.path!);
                  setState(() {
                    profilePic = converted;
                  });
                }
              },
              child: Stack(
                children: [
                  CircleAvatar(
                    backgroundImage:
                        const AssetImage("Assets/Images/profile.png"),
                    foregroundImage: (widget.data["profilePicUrl"] != "")
                        ? NetworkImage(widget.data["profilePicUrl"])
                        : null,
                    radius: 60,
                  ),
                  if (profilePic != null)
                    CircleAvatar(
                      foregroundImage: FileImage(profilePic!),
                      radius: 60,
                    ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              "Phone Number : ${widget.data["Phone"]}",
              style: style.copyWith(fontSize: 20),
            ),
            const SizedBox(
              height: 20,
            ),
            customTextfield(
                controller: nameController,
                label: "Enter Name",
                leading: const Icon(Icons.person)),
            const SizedBox(
              height: 20,
            ),
            customTextfield(
                controller: bioController,
                label: "Add Bio",
                leading: const Icon(Icons.info)),
            const SizedBox(
              height: 20,
            ),
            if (uploadProgress != 0)
              Column(
                children: [
                  Text(
                    "Updating...",
                    style: style,
                  ),
                  LinearProgressIndicator(
                    value: uploadProgress / 100,
                  )
                ],
              ),
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                customButton(
                    text: widget.title,
                    onTap: () async {
                      String downloadUrl = "";
                      if (profilePic != null) {
                        try {
                          UploadTask uploadTask1 = bucket
                              .ref()
                              .child("Profile Pictures")
                              .child(const Uuid().v1())
                              .putFile(profilePic!);
                          uploadTask1.snapshotEvents
                              .listen((TaskSnapshot snapshot) {
                            setState(() {
                              uploadProgress = (snapshot.bytesTransferred /
                                      snapshot.totalBytes) *
                                  100;
                            });
                          });
                          TaskSnapshot taskSnapshot1 = await uploadTask1;
                          downloadUrl =
                              await taskSnapshot1.ref.getDownloadURL();
                        } on FirebaseException catch (e) {
                          showFailureSnackBar(context, e.message!);
                        }
                        userCollection.doc(widget.id).update({
                          "Bio": bioController.text.trim(),
                          "Name": nameController.text.trim(),
                          "profilePicUrl": downloadUrl
                        });
                      } else {
                        userCollection.doc(widget.id).update({
                          "Bio": bioController.text.trim(),
                          "Name": nameController.text.trim(),
                        });
                      }
                      showSuccessSnackBar(context, "Profile Updated");
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => const HomeScreen()),
                          (route) => false);
                    },
                    fontWeight: FontWeight.normal,
                    borderRadius: 10)
              ],
            ))
          ],
        ),
      ),
    );
  }
}
