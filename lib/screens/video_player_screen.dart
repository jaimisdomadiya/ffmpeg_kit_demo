import 'dart:developer';
import 'dart:io';

import 'package:ffmpeg_kit_flutter_min_gpl/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/media_information_session.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({Key? key, required this.file}) : super(key: key);

  final File file;

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    _controller = VideoPlayerController.file(widget.file);
    await _controller.initialize();
    await _controller.pause();
    setState(() {});

    FFprobeKit.getMediaInformationAsync(widget.file.path, (session) async {
      final information =
          await (session as MediaInformationSession).getMediaInformation();

      if (information != null) {
        log("Path: ${information.getMediaProperties()!['filename']}");
        log("size: ${information.getSize()}");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: nextOnClick,
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: AspectRatio(
                  aspectRatio: 0.8,
                  child: _controller != null && _controller.value.isInitialized
                      ? VideoPlayer(_controller)
                      : Container(),
                ),
              ),
              Visibility(
                visible: !_controller.value.isPlaying,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  nextOnClick() async {
    if (_controller.value.isPlaying) {
      await _controller.pause();
    } else {
      await _controller.play();
    }
    setState(() {});
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }
}
