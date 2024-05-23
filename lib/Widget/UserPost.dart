// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stream_share/Screens/Profile.dart';
import 'package:stream_share/Screens/VideoPlayer.dart';
import 'package:stream_share/globals/Constants.dart';
import 'package:stream_share/globals/Message.dart';
import 'package:stream_share/globals/globals.dart';

class UserPost extends StatefulWidget {
  final String id;
  final Map<String, dynamic> data;
  const UserPost({super.key, required this.data, required this.id});

  @override
  State<UserPost> createState() => _UserPostState();
}

class _UserPostState extends State<UserPost> {
  Map<String, dynamic> userInfo = {};

  @override
  void initState() {
    super.initState();
    setData();
  }

  Future<void> setData() async {
    await userCollection.doc(widget.data['userId']).get().then((value) {
      if (mounted) {
        setState(() {
          userInfo = value.data() as Map<String, dynamic>;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            children: [
              Row(
                children: [
                  ProfileAvatar(data: userInfo, radius: 20),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    (userInfo['Name'] != "")
                        ? "${userInfo['Name']}"
                        : "${userInfo['Phone']}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              ),
              Expanded(
                child: Row(
                  children: [
                    const SizedBox(
                      width: 70,
                    ),
                    const Icon(Icons.location_on,
                        size: 30, color: Colors.black),
                    const SizedBox(
                      width: 5,
                      height: 40,
                    ),
                    Expanded(
                      child: Text(
                        widget.data['postLocation'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: style.copyWith(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (builder) => FullScreenVideoPlayer(
                            videoUrl: widget.data['videoUrl'],
                            id: widget.id,
                            views: widget.data['views'],
                          )));
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.network(
                  widget.data['thumbnailUrl'],
                  height: MediaQuery.of(context).size.height * 0.2,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.2,
                  color: Colors.black.withOpacity(0.4),
                  child: const Icon(
                    Icons.play_circle_fill,
                    color: Colors.white60,
                    size: 50,
                  ),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Text(widget.data['title'],
                  style: style.copyWith(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(
            height: 4,
          ),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                    color: Colors.grey.shade500,
                    borderRadius: BorderRadius.circular(6)),
                padding: const EdgeInsets.all(4),
                child: Text(
                  "Category",
                  style: style.copyWith(color: Colors.white),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                widget.data['category'],
                style: style,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      FirebaseFirestore.instance
                          .collection("Post")
                          .doc(widget.id)
                          .update({"likes": ++widget.data['likes']});
                    },
                    icon: const Icon(Icons.thumb_up, color: Colors.black),
                  ),
                  Text(
                    widget.data['likes'].toString(),
                    style: style.copyWith(color: Colors.black),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      FirebaseFirestore.instance
                          .collection("Post")
                          .doc(widget.id)
                          .update({"dislikes": ++widget.data['dislikes']});
                    },
                    icon: const Icon(Icons.thumb_down, color: Colors.black),
                  ),
                  Text(
                    widget.data['dislikes'].toString(),
                    style: style.copyWith(color: Colors.black),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      showSuccessSnackBar(context, "Work in Progress");
                    },
                    icon: const Icon(
                      Icons.message,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    "0",
                    style: style.copyWith(color: Colors.black),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.remove_red_eye,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    widget.data['views'].toString(),
                    style: style.copyWith(color: Colors.black),
                  ),
                  const SizedBox(
                    width: 8,
                  )
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
