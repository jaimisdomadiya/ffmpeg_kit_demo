import 'package:ffmpeg_kit/screens/crop_screen.dart';
import 'package:ffmpeg_kit/screens/filter_screens.dart';
import 'package:ffmpeg_kit/screens/trim_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              roundedButton('Crop', onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CropScreen()));
              }),
              roundedButton('Trim', onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const TrimScreen()));
              }),
            ],
          ),
          const SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              roundedButton('Filter', onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FilterScreens()));
              }),
              roundedButton('Compress', onTap: () {
                /*Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CompressScreen()));*/
              }),
            ],
          ),
          // Flexible(
          //   child: CustomTextFormField(
          //     validator: Validation.validateStartTime,
          //     hintText: 'Enter start time',
          //     textInputType: TextInputType.number,
          //   ),
          // ),
        ],
      ),
    );
  }
}

Widget roundedButton(String title, {GestureTapCallback? onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 20),
      ),
    ),
  );
}
