import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:stream_share/Firebase/FirebaseMessaging.dart';
import 'package:stream_share/Models/Post.dart';
import 'package:stream_share/Screens/Home.dart';
import 'package:stream_share/Widget/VideoCover.dart';
import 'package:stream_share/Widget/widgets.dart';
import 'package:stream_share/globals/Constants.dart';
import 'package:stream_share/globals/Message.dart';
import 'package:stream_share/globals/globals.dart';

// ignore: must_be_immutable
class CreatePostScreen extends StatefulWidget {
  final File video;
  Map<String, dynamic> location;
  CreatePostScreen({super.key, required this.video, required this.location});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  var titleController = TextEditingController();
  var cateController = TextEditingController();

  String location = "";
  String id = "";
  String selectedCategory = "";

  List<String> categories = [];

  bool loader = false;
  double uploadProgress = 0;

  @override
  void initState() {
    super.initState();
    initilize();
  }

  Future<void> initilize() async {
    await FirebaseFirestore.instance.collection("Category").get().then((value) {
      if (value.docs.isNotEmpty) {
        List<String> opts = [];
        for (var doc in value.docs) {
          var data = doc.data();
          opts.add(data['type']);
        }
        setState(() {
          categories = opts;
          selectedCategory = opts.first;
        });
      }
    });
    if (widget.location == {}) {
      var loc = await getCurrentLocation(context);
      setState(() {
        widget.location = loc;
      });
    }
    setState(() {
      location = "${widget.location['area']}, ${widget.location['city']}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Post Video",
          style: style,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.84,
            child: Column(
              children: [
                VideoCover(videoFilePath: widget.video.path),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Text(
                      "Enter Title",
                      style: style.copyWith(fontSize: 17),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                customTextfield(
                    controller: titleController,
                    label: "Enter Title",
                    leading: const Icon(Icons.title)),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Text(
                      "Select Category",
                      style: style.copyWith(fontSize: 17),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  height: 56,
                  child: Center(
                    child: Row(children: [
                      Expanded(
                        child: DropdownButton<String>(
                          dropdownColor: Colors.white,
                          value: selectedCategory,
                          underline: Container(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedCategory = newValue!;
                            });
                          },
                          items: categories
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 10),
                                child: Text(value),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ]),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Text(
                      "Your Current Location",
                      style: style.copyWith(fontSize: 17),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                ListTile(
                  title: Text(
                    location,
                    style: style,
                  ),
                  leading: const Icon(Icons.location_on),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          customButton(
                              text: "Post",
                              onTap: savePost,
                              width: 100,
                              loader: loader,
                              borderRadius: 10),
                        ],
                      ),
                      if (uploadProgress != 0)
                        Column(
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            LinearProgressIndicator(
                              value: uploadProgress / 100,
                            ),
                          ],
                        )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void setId(String id) {
    setState(() {
      this.id = id;
    });
  }

  Future<void> savePost() async {
    String title = titleController.text.trim();
    String? phone = currentUser?.phoneNumber;
    await getCurrentUserId(phone!, setId);

    print(
        "************************************************************* $phone");
    setState(() {
      loader = true;
    });
    if (location.isEmpty) {
      initilize();
    } else {
      if (title != "" && selectedCategory != "") {
        String fileName = widget.video.path.split(Platform.pathSeparator).last;
        try {
          UploadTask uploadTask1 = bucket
              .ref()
              .child("Video Posts")
              .child(fileName)
              .putFile(widget.video);
          uploadTask1.snapshotEvents.listen((TaskSnapshot snapshot) {
            setState(() {
              uploadProgress =
                  (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
            });
          });
          TaskSnapshot taskSnapshot1 = await uploadTask1;
          String downloadUrl = await taskSnapshot1.ref.getDownloadURL();

          UploadTask uploadTask2 = bucket
              .ref()
              .child("Video Thumbnails")
              .child("${cover!.path.split("/").last}.jpg")
              .putFile(cover!);
          uploadTask1.snapshotEvents.listen((TaskSnapshot snapshot) {
            setState(() {
              uploadProgress =
                  (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
            });
          });
          TaskSnapshot taskSnapshot2 = await uploadTask2;
          String downloadUrl2 = await taskSnapshot2.ref.getDownloadURL();

          var data = Post(
                  likes: 0,
                  dislikes: 0,
                  userId: id,
                  title: title,
                  category: selectedCategory,
                  videoUrl: downloadUrl,
                  postLocation: location,
                  comments: [],
                  thumbnail: downloadUrl2,
                  views: 0)
              .toJson();
          postCollection.add(data);
          Messaging.sendPushMessage(
              token, "New Video Posted Successfully !!", title);
          showSuccessSnackBar(context, "Video Posted successfully !!");
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false);
        } on FirebaseException catch (e) {
          showFailureSnackBar(context, e.code);
          setState(() {
            loader = false;
          });
        }
      } else {
        showFailureSnackBar(context, "Please Enter all Details");
      }
    }
    setState(() {
      loader = false;
    });
  }
}
