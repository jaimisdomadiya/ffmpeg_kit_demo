import 'dart:developer';
import 'dart:io';

import 'package:ffmpeg_kit/screens/video_player_screen.dart';
import 'package:ffmpeg_kit/utils/util.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/log.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/media_information_session.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/session.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/statistics.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

// final String ffmpegCommand =
// "-i ${file!.path} -vcodec libx264 -crf 28 -preset superfast -acodec copy $outputPath";

class CompressScreen extends StatefulWidget {
  const CompressScreen({Key? key}) : super(key: key);

  @override
  _CompressScreenState createState() => _CompressScreenState();
}

class _CompressScreenState extends State<CompressScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? file;
  VideoPlayerController? _controller;
  ValueNotifier<bool> isLoading = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Compress",
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () async {
          file = await _picker.pickVideo(source: ImageSource.gallery);
          if (file != null) {
            _controller = VideoPlayerController.file(File(file!.path));
            await _controller?.initialize();
            await _controller?.pause();
            setState(() {});

            FFprobeKit.getMediaInformationAsync(file!.path, (session) async {
              final information = await (session as MediaInformationSession)
                  .getMediaInformation();

              if (information != null) {
                log("Path: ${information.getMediaProperties()!['filename']}");
                log("size: ${information.getSize()}");
              }
            });
          }
        },
        heroTag: 'video0',
        tooltip: 'Pick Video from gallery',
        child: const Icon(Icons.video_library),
      ),
      body: _previewVideo(),
    );
  }

  Widget _previewVideo() {
    if (_controller == null) {
      return const Center(
        child: Text(
          'You have not yet picked a video',
          textAlign: TextAlign.center,
        ),
      );
    }
    return _controller?.value.isInitialized ?? false
        ? Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: nextOnClick,
                      child: const Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 25, vertical: 10),
                            child: Text(
                              'Next',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500),
                            ),
                          )),
                    ),
                    GestureDetector(
                      onTap: () async {
                        print('GestureDetector');
                        if (_controller?.value.isPlaying ?? false) {
                          await _controller?.pause();
                        } else {
                          await _controller?.play();
                        }
                        setState(() {});
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 10),
                            child: AspectRatio(
                              aspectRatio: 1.0,
                              child: VideoPlayer(_controller!),
                            ),
                          ),
                          Visibility(
                            visible: !(_controller!.value.isPlaying),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.play_arrow,
                                  color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ValueListenableBuilder(
                valueListenable: isLoading,
                builder: (BuildContext context, value, Widget? child) {
                  return isLoading.value
                      ? Container(
                          alignment: Alignment.center,
                          color: Colors.grey.withOpacity(0.2),
                          child: const CircularProgressIndicator())
                      : const SizedBox.shrink();
                },
              ),
            ],
          )
        : const Center(child: CircularProgressIndicator());
  }

  @override
  void dispose() {
    // TODO: implement dispose
    FFmpegKit.cancel();
    super.dispose();
  }

  /// Run command
  nextOnClick() async {
    _controller?.pause();
    isLoading.value = true;
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    String outputPath =
        appDocPath + "/output${DateTime.now().microsecondsSinceEpoch}.mp4";
    log(outputPath, name: 'outputPath');

    final String ffmpegCommand = "-i ${file!.path} -b 800k $outputPath";
    log(ffmpegCommand, name: '_command');

    try {
      log('-------------------------------------');

      log('Session Start', name: 'Session Start');

      await FFmpegKit.executeAsync(ffmpegCommand, (Session session) async {
        final state =
            FFmpegKitConfig.sessionStateToString(await session.getState());
        final returnCode = await session.getReturnCode();
        final failStackTrace = await session.getFailStackTrace();

        ffprint(
            "FFmpeg process exited with state ${state} and rc ${returnCode}.${notNull(failStackTrace, "\\n")}");

        if (returnCode?.isValueSuccess() == true) {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return VideoPlayerScreen(file: File(outputPath));
          }));
          isLoading.value = false;
        }
      }, (Log log) {
        // CALLED WHEN SESSION PRINTS LOGS
      }, (Statistics statistics) {
        // CALLED WHEN SESSION GENERATES STATISTICS
      });

      log('Session End', name: 'Session End');
      log('-------------------------------------');
    } catch (e) {
      isLoading.value = true;
      debugPrint('Error ===> $e');
    }
  }
}
