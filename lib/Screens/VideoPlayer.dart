import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stream_share/globals/globals.dart';
import 'package:video_player/video_player.dart';

class FullScreenVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String id;
  final int views;

  const FullScreenVideoPlayer(
      {super.key,
      required this.videoUrl,
      required this.id,
      required this.views});

  @override
  _FullScreenVideoPlayerState createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  String url = "";
  late VideoPlayerController _controller;

  void initilize() {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {});
        int view = widget.views;
        FirebaseFirestore.instance
            .collection("Post")
            .doc(widget.id)
            .update({"views": ++view});
      });
  }

  @override
  void initState() {
    super.initState();
    initilize();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Video Player",
          style: style,
        ),
      ),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    VideoPlayer(_controller),
                    _PlayPauseOverlay(controller: _controller),
                  ],
                ),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}

class _PlayPauseOverlay extends StatefulWidget {
  final VideoPlayerController controller;

  const _PlayPauseOverlay({required this.controller});

  @override
  State<_PlayPauseOverlay> createState() => _PlayPauseOverlayState();
}

class _PlayPauseOverlayState extends State<_PlayPauseOverlay> {
  bool toggled = true;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: widget.controller.value.isPlaying
              ? const SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: Center(
                    child: IconButton(
                      icon: !toggled
                          ? const Icon(
                              Icons.pause,
                              size: 100.0,
                              color: Colors.white,
                            )
                          : const Icon(Icons.play_arrow,
                              size: 100.0, color: Colors.white),
                      onPressed: () {
                        widget.controller.play();
                      },
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            if (widget.controller.value.isPlaying) {
              setState(() {
                toggled = true;
              });
              widget.controller.pause();
            } else {
              setState(() {
                toggled = false;
              });
              widget.controller.play();
            }
          },
        ),
      ],
    );
  }
}
