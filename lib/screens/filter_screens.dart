import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffmpeg_kit/screens/video_player_screen.dart';
import 'package:ffmpeg_kit/utils/filter_matrics.dart';
import 'package:ffmpeg_kit/utils/util.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/return_code.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/session.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class FilterScreens extends StatefulWidget {
  const FilterScreens({Key? key}) : super(key: key);

  @override
  _FilterScreensState createState() => _FilterScreensState();
}

class _FilterScreensState extends State<FilterScreens> {
  final ImagePicker _picker = ImagePicker();
  XFile? file;
  VideoPlayerController? _controller;
  Stream<Uint8List>? _stream;
  num selectedIndex = -1;
  ValueNotifier<bool> isLoading = ValueNotifier(false);
  late String matrix;
  List<double> selectedMatrix = noFilterMatrixImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _previewVideo(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () async {
          file = await _picker.pickVideo(source: ImageSource.gallery);
          if (file != null) {
            _controller = VideoPlayerController.file(File(file!.path));
            await _controller?.initialize();
            _stream = _generateThumbnails();
            await _controller?.pause();
            setState(() {});
          }
        },
        heroTag: 'video0',
        tooltip: 'Pick Video from gallery',
        child: const Icon(Icons.video_library),
      ),
    );
  }

  Stream<Uint8List> _generateThumbnails() async* {
    Uint8List? _bytes = await VideoThumbnail.thumbnailData(
      imageFormat: ImageFormat.JPEG,
      video: file?.path ?? '',
      timeMs: 0,
    );
    if (_bytes != null) {
      yield _bytes;
    }
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
    if (_controller?.value.isInitialized ?? false) {
      return Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                GestureDetector(
                  onTap: nextOnTap,
                  child: const Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 25, vertical: 10),
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
                          child: ColorFiltered(
                              colorFilter: ColorFilter.matrix(selectedMatrix),
                              child: VideoPlayer(_controller!)),
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
                          child:
                              const Icon(Icons.play_arrow, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
                StreamBuilder(
                  stream: _stream,
                  builder: (_, AsyncSnapshot<Uint8List> snapshot) {
                    final data = snapshot.data;
                    return snapshot.hasData
                        ? SizedBox(
                            height: 90,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              itemCount: matrixList.length,
                              itemBuilder: (_, int index) {
                                return GestureDetector(
                                  onTap: () {
                                    selectedMatrix = matrixList[index];
                                    selectedIndex = index;
                                    List<double> tempList =
                                        List.from(matrixList[index]);

                                    for (int i = matrixList[index].length - 1;
                                        i > 0;
                                        i -= 5) {
                                      tempList.removeAt(i);
                                    }
                                    debugPrint(
                                        'tempList ==> ${tempList.length}');
                                    matrix = tempList
                                        .toString()
                                        .replaceAll(',', ':');
                                    matrix = matrix.replaceAll(' ', '');
                                    matrix = matrix.replaceAll('[', '');
                                    matrix = matrix.replaceAll(']', '');
                                    debugPrint('matrix ==> $matrix');
                                    setState(() {});
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 10.0),
                                    decoration: BoxDecoration(
                                        border: selectedIndex != index
                                            ? Border.all(
                                                color: Colors.transparent,
                                                width: 3)
                                            : Border.all(
                                                color: Colors.blue, width: 3)),
                                    child: ColorFiltered(
                                      colorFilter:
                                          ColorFilter.matrix(matrixList[index]),
                                      child: Image(
                                        image: MemoryImage(data!),
                                        width: 80,
                                        height: 40,
                                        fit: BoxFit.fill,
                                        alignment: Alignment.topLeft,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        : const SizedBox();
                  },
                )
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
      );
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }

  /// Run Command
  void nextOnTap() async {
    try {
      _controller?.pause();
      isLoading.value = true;
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      String outputPath =
          appDocPath + "/output${DateTime.now().microsecondsSinceEpoch}.mp4";
      log(outputPath, name: 'outputPath');
      log(matrix, name: 'matrix');

      String _command =
          "-i ${file!.path} -vf colorchannelmixer=$matrix -pix_fmt yuv420p -c:a copy $outputPath";
      log(_command, name: '_command');

      await FFmpegKit.executeAsync(_command, (Session session) async {
        log(outputPath, name: 'Rotate path');
        final state =
            FFmpegKitConfig.sessionStateToString(await session.getState());
        final returnCode = await session.getReturnCode();
        final failStackTrace = await session.getFailStackTrace();

        ffprint(
            "FFmpeg process exited with state ${state} and rc ${returnCode}.${notNull(failStackTrace, "\\n")}");

        if (ReturnCode.isSuccess(returnCode)) {
          ffprint("Create completed successfully; playing video.");
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => VideoPlayerScreen(
                        file: File(outputPath),
                      )));
          isLoading.value = false;
          listAllStatistics(session as FFmpegSession);
        } else {
          isLoading.value = false;
          print("Create failed. Please check log for the details.");
        }
      });
    } catch (e) {
      isLoading.value = true;
      debugPrint('Error ===> $e');
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    FFmpegKit.cancel();
    _controller?.dispose();
    super.dispose();
  }
}
