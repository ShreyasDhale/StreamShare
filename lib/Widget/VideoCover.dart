import 'dart:io';

import 'package:flutter/material.dart';
import 'package:stream_share/globals/globals.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoCover extends StatefulWidget {
  final String videoFilePath;

  const VideoCover({super.key, required this.videoFilePath});

  @override
  // ignore: library_private_types_in_public_api
  _VideoCoverState createState() => _VideoCoverState();
}

class _VideoCoverState extends State<VideoCover> {
  late Future<String> _thumbnailFuture;

  @override
  void initState() {
    super.initState();
    _thumbnailFuture = _generateThumbnail();
  }

  Future<String> _generateThumbnail() async {
    final thumbnailPath = await VideoThumbnail.thumbnailFile(
      video: widget.videoFilePath,
      imageFormat: ImageFormat.JPEG,
      maxHeight: 400,
      quality: 100,
    );
    return thumbnailPath!;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _thumbnailFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          cover = File(snapshot.data!);
          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(
              File(snapshot.data!),
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width * 0.4,
              height: MediaQuery.of(context).size.height * 0.3,
            ),
          );
        }
      },
    );
  }
}
