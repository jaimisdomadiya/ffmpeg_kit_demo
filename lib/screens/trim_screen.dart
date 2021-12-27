import 'dart:developer';
import 'dart:io';

import 'package:ffmpeg_kit/screens/home_screen.dart';
import 'package:ffmpeg_kit/utils/util.dart';
import 'package:ffmpeg_kit/widget/textformfield.dart';
import 'package:ffmpeg_kit/widget/video_widget.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/session.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/statistics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class TrimScreen extends StatefulWidget {
  const TrimScreen({Key? key}) : super(key: key);

  @override
  _TrimScreenState createState() => _TrimScreenState();
}

class _TrimScreenState extends State<TrimScreen> {
  final ImagePicker _picker = ImagePicker();
  String? _retrieveDataError;

  // final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();

  VideoPlayerController? _controller;
  VideoPlayerController? _toBeDisposed;

  XFile? file;
  ValueNotifier<bool> isPlaying = ValueNotifier(true);
  ValueNotifier<bool> isLoading = ValueNotifier(false);

  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  late String videoDuration;

  @override
  void initState() {
    // TODO: implement initState
    startTimeController.text = '00:00:30';
    endTimeController.text = '00:00:40';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trim'),
      ),
      body: _previewVideo(),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: FloatingActionButton(
          backgroundColor: Colors.red,
          onPressed: () {
            _onImageButtonPressed(ImageSource.gallery);
          },
          heroTag: 'video0',
          tooltip: 'Pick Video from gallery',
          child: const Icon(Icons.video_library),
        ),
      ),
    );
  }

  Widget _previewVideo() {
    final Text? retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_controller == null) {
      return const Center(
        child: Text(
          'You have not yet picked a video',
          textAlign: TextAlign.center,
        ),
      );
    }
    return Stack(
      children: [
        SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  AspectRatioVideo(_controller),
                  const SizedBox(height: 20),
                  ValueListenableBuilder<bool>(
                    valueListenable: isPlaying,
                    builder: (BuildContext context, value, Widget? child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (isPlaying.value) {
                                isPlaying.value = false;
                                _controller!.pause();
                              } else {
                                isPlaying.value = true;
                                _controller!.play();
                              }
                            },
                            child: Icon(
                              isPlaying.value
                                  ? Icons.play_circle_filled_outlined
                                  : Icons.pause,
                              size: 50,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Flexible(
                        child: CustomTextFormField(
                          controller: startTimeController,
                          validator: (value) {
                            Duration duration = Duration();
                            if (value != null) {
                              duration = Duration(
                                  hours: int.parse(value.substring(0, 2)),
                                  minutes: int.parse(value.substring(3, 5)),
                                  seconds: int.parse(value.substring(6, 8)));
                              log('${duration.inSeconds}',
                                  name: 'validateStartTime');
                              log(videoDuration, name: 'secound');
                            }
                            if (value?.isEmpty ?? true) {
                              return 'Please enter start time';
                            } else if ((int.parse(videoDuration) <
                                duration.inSeconds)) {
                              return 'Please enter valid time';
                            } else {
                              return null;
                            }
                          },
                          hintText: 'Enter start time',
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(8),
                            // TimeInputFormatter(),
                          ],
                          textInputType: TextInputType.datetime,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Flexible(
                        child: CustomTextFormField(
                          controller: endTimeController,
                          validator: (value) {
                            Duration duration = Duration();
                            if (value != null) {
                              duration = Duration(
                                  hours: int.parse(value.substring(0, 2)),
                                  minutes: int.parse(value.substring(3, 5)),
                                  seconds: int.parse(value.substring(6, 8)));
                            }

                            if (value?.isEmpty ?? true) {
                              return 'Please enter end time';
                            } else if ((int.parse(videoDuration) <
                                duration.inSeconds)) {
                              return 'Please enter valid time';
                            } else {
                              return null;
                            }
                          },
                          hintText: 'Enter end time',
                          textInputType: TextInputType.datetime,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  roundedButton('Trim', onTap: trimOnClick),
                ],
              ),
            ),
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
  }

  Text? _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError!);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }

  Future<void> _playVideo(XFile? file) async {
    if (file != null && mounted) {
      await _disposeVideoController();
      late VideoPlayerController controller;
      controller = VideoPlayerController.file(File(file.path))
        ..initialize().then((value) async {
          debugPrint(
              "========" + controller.value.duration.inSeconds.toString());
          videoDuration = controller.value.duration.inSeconds.toString();
          _controller = controller;

          await controller.setVolume(0.5);
          await controller.initialize();
          await controller.setLooping(true);
          await controller.play();
          isPlaying.value = true;
          setState(() {});
        });
    }
  }

  Future<void> _disposeVideoController() async {
    if (_toBeDisposed != null) {
      await _toBeDisposed!.dispose();
    }
    _toBeDisposed = _controller;
    _controller = null;
  }

  void _onImageButtonPressed(ImageSource source) async {
    if (_controller != null) {
      await _controller!.setVolume(0.0);
    }
    file = await _picker.pickVideo(
        source: source, maxDuration: const Duration(seconds: 10));

    /*if (file != null) {
      log(file!.path, name: 'File Path');
      FFprobeKit.getMediaInformationAsync(file!.path, (session) async {
        print("Media Information");

        final information =
            await (session as MediaInformationSession).getMediaInformation();

        log("getMediaProperties info ==> ${information?.getMediaProperties()}");
        log("getAllProperties info ==> ${information?.getAllProperties()}");

        log("Path: ${information?.getMediaProperties()!['filename']}");
        log("size: ${information?.getMediaProperties()!['size']}");
      });
      await _playVideo(file);
    }*/

    await _playVideo(file);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    FFmpegKit.cancel();
    _controller?.dispose();
    _toBeDisposed?.dispose();
    super.dispose();
  }

  /// Run Command

  trimOnClick() async {
    if (formKey.currentState!.validate()) {
      try {
        _controller!.pause();
        isLoading.value = true;
        Directory appDocDir = await getApplicationDocumentsDirectory();
        String appDocPath = appDocDir.path;
        String outputPath =
            appDocPath + "/output${DateTime.now().microsecondsSinceEpoch}.mp4";
        log(outputPath, name: 'outputPath');

        String _command =
            "-i ${file!.path} -ss ${startTimeController.text.trim()} -to ${endTimeController.text.trim()} -y $outputPath";

        await FFmpegKit.executeAsync(
            _command,
            (Session session) async {
              final code = await session.getReturnCode();

              if (code?.isValueSuccess() == true) {
                await _playVideo(XFile(outputPath));
                isLoading.value = false;
              }
            },
            (log) => ffprint(log.getMessage()),
            (Statistics statistics) async {
              // CALLED WHEN SESSION GENERATES STATISTICS
            });
      } catch (e) {
        isLoading.value = true;
      }
    }
  }
}
