import 'dart:developer';
import 'dart:io';

import 'package:ffmpeg_kit/screens/home_screen.dart';
import 'package:ffmpeg_kit/utils/util.dart';
import 'package:ffmpeg_kit/utils/validation/validation.dart';
import 'package:ffmpeg_kit/widget/textformfield.dart';
import 'package:ffmpeg_kit/widget/video_widget.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/return_code.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/session.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class CropScreen extends StatefulWidget {
  const CropScreen({Key? key}) : super(key: key);

  @override
  _CropScreenState createState() => _CropScreenState();
}

class _CropScreenState extends State<CropScreen> {
  XFile? file;
  ValueNotifier<bool> isPlaying = ValueNotifier(true);
  ValueNotifier<bool> isLoading = ValueNotifier(false);

  TextEditingController heightController = TextEditingController();
  TextEditingController widthController = TextEditingController();
  TextEditingController xController = TextEditingController();
  TextEditingController yController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  final ImagePicker _picker = ImagePicker();
  String? _retrieveDataError;

  VideoPlayerController? _controller;
  VideoPlayerController? _toBeDisposed;

  @override
  void initState() {
    // TODO: implement initState
    heightController.text = "418";
    widthController.text = "479";
    xController.text = "0";
    yController.text = "100";
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    FFmpegKit.cancel();
    _controller?.dispose();
    _toBeDisposed?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop'),
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

  void _onImageButtonPressed(ImageSource source) async {
    if (_controller != null) {
      await _controller!.setVolume(0.0);
    }
    file = await _picker.pickVideo(
        source: source, maxDuration: const Duration(seconds: 10));

    if (file != null) {
      log(file!.path, name: 'File Path');
      await _playVideo(file);
    }
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
                          controller: heightController,
                          validator: Validation.validateHeight,
                          hintText: 'Enter height',
                        ),
                      ),
                      const SizedBox(width: 15),
                      Flexible(
                        child: CustomTextFormField(
                          controller: widthController,
                          validator: Validation.validateWidth,
                          hintText: 'Enter width',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Flexible(
                        child: CustomTextFormField(
                          controller: xController,
                          validator: Validation.validateXPositioned,
                          hintText: 'Enter x position',
                        ),
                      ),
                      const SizedBox(width: 15),
                      Flexible(
                        child: CustomTextFormField(
                          controller: yController,
                          validator: Validation.validateYPositioned,
                          hintText: 'Enter y position',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  roundedButton('Crop', onTap: cropOnClick),
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

  Future<void> _disposeVideoController() async {
    if (_toBeDisposed != null) {
      await _toBeDisposed!.dispose();
    }
    _toBeDisposed = _controller;
    _controller = null;
  }

  Future<void> _playVideo(XFile? file) async {
    if (file != null && mounted) {
      await _disposeVideoController();
      late VideoPlayerController controller;
      controller = VideoPlayerController.file(File(file.path));
      _controller = controller;
      const double volume = 0.5;
      await controller.setVolume(volume);
      await controller.initialize();
      await controller.setLooping(true);
      await controller.play();
      isPlaying.value = true;
      setState(() {});
    }
  }

  /// Run Command
  cropOnClick() async {
    if (formKey.currentState!.validate()) {
      try {
        _controller!.pause();
        isLoading.value = true;
        Directory appDocDir = await getApplicationDocumentsDirectory();
        String appDocPath = appDocDir.path;
        String outputPath = appDocPath + "/output.mp4";
        log(outputPath, name: 'outputPath');

        String command =
            "-i ${file!.path} -filter:v crop=${widthController.text.trim()}:${heightController.text.trim()}:${xController.text.trim()}:${yController.text.trim()} -y $outputPath";

        await FFmpegKit.executeAsync(command, (Session session) async {
          final state =
              FFmpegKitConfig.sessionStateToString(await session.getState());
          final returnCode = await session.getReturnCode();
          final failStackTrace = await session.getFailStackTrace();

          ffprint(
              "FFmpeg process exited with state ${state} and rc ${returnCode}.${notNull(failStackTrace, "\\n")}");

          if (ReturnCode.isSuccess(returnCode)) {
            ffprint("Create completed successfully; playing video.");
            await _playVideo(XFile(outputPath));
            isLoading.value = false;
            listAllStatistics(session as FFmpegSession);
          } else {
            isLoading.value = false;
            print("Create failed. Please check log for the details.");
          }
        }, (log) => ffprint(log.getMessage()));
      } catch (e) {
        isLoading.value = false;
      }
    }
  }
}
