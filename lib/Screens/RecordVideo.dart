import 'dart:io';

import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:stream_share/Screens/CreatePost.dart';
import 'package:stream_share/globals/Message.dart';
import 'package:stream_share/globals/globals.dart';

class RecordVideo extends StatefulWidget {
  const RecordVideo({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<RecordVideo> {
  late CameraController controller;
  File? video;
  String videoName = "";
  bool isRecording = false;
  bool isLoading = false;
  bool isToggled = false;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    initilizeCamera();
  }

  initilizeCamera() {
    controller =
        CameraController(cameras[selectedIndex], ResolutionPreset.ultraHigh);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void toggleCamera() {
    setState(() {
      isToggled = !isToggled;
      if (isToggled) {
        selectedIndex = cameras.length - 1;
      } else {
        selectedIndex = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return Scaffold(
      appBar: AppBar(
        leading: Image.asset(
          "Assets/Images/icon.png",
        ),
        title: const Text("Camera"),
        backgroundColor: Colors.grey.shade200,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              SizedBox(
                  height: (video == null)
                      ? MediaQuery.of(context).size.height * 0.64
                      : MediaQuery.of(context).size.height * 0.56,
                  width: MediaQuery.of(context).size.width,
                  child: CameraPreview(controller)),
              Positioned(
                  right: 0,
                  top: 10,
                  child: IconButton(
                      onPressed: () {
                        toggleCamera();
                        initilizeCamera();
                      },
                      icon: const Icon(
                        Icons.camera_front,
                        size: 50,
                        color: Colors.white,
                      )))
            ],
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: startRecording,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          IconButton(
                              onPressed: () async {
                                final result = await FilePicker.platform
                                    .pickFiles(type: FileType.video);
                                if (result != null) {
                                  File converted =
                                      File(result.files.first.path!);
                                  String fileName =
                                      converted.path.split("/").last;
                                  setState(() {
                                    video = converted;
                                    videoName = fileName;
                                  });
                                }
                              },
                              icon: const Icon(
                                Icons.image,
                                size: 40,
                              )),
                          Text(
                            "Galary",
                            style: style,
                          )
                        ],
                      ),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          const CircleAvatar(
                            backgroundColor: Colors.black54,
                            radius: 35,
                          ),
                          isRecording
                              ? const Icon(
                                  Icons.pause,
                                  color: Colors.white,
                                  size: 30,
                                )
                              : const CircleAvatar(
                                  backgroundColor: Colors.red,
                                  radius: 30,
                                ),
                        ],
                      ),
                      (video != null)
                          ? Column(
                              children: [
                                IconButton(
                                    onPressed: isLoading
                                        ? null
                                        : () async {
                                            setState(() {
                                              isLoading = true;
                                            });
                                            var location =
                                                await getCurrentLocation(
                                                    context);
                                            setState(() {
                                              isLoading = false;
                                            });
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        CreatePostScreen(
                                                            video: video!,
                                                            location:
                                                                location)));
                                          },
                                    icon: isLoading
                                        ? const CircularProgressIndicator()
                                        : const Icon(
                                            Icons.arrow_forward,
                                            size: 40,
                                          )),
                                Text(
                                  "Next",
                                  style: style,
                                )
                              ],
                            )
                          : const SizedBox(
                              width: 50,
                            )
                    ],
                  ),
                  if (videoName != "")
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(top: 10),
                      color: Colors.black54,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            videoName,
                            style: style.copyWith(color: Colors.white),
                          ),
                          IconButton(
                              onPressed: () {
                                setState(() {
                                  video = null;
                                  videoName = "";
                                });
                              },
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ))
                        ],
                      ),
                    ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> startRecording() async {
    try {
      if (!controller.value.isRecordingVideo) {
        await controller.startVideoRecording();
        setState(() {
          isRecording = true;
        });
      } else {
        XFile videoFile = await controller.stopVideoRecording();
        File converted = File(videoFile.path);
        setState(() {
          isRecording = false;
          video = converted;
          videoName = video!.path.split("/").last;
        });
        showSuccessSnackBar(context, "Video Recorded at ${videoFile.path}");
      }
    } on CameraException catch (e) {
      print(e);
    }
  }
}
