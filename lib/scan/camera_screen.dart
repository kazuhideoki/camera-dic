// import 'dart:html';
import 'dart:io' show Directory;

import 'package:camera/camera.dart'
    show
        CameraDescription,
        CameraException,
        availableCameras,
        CameraController,
        ResolutionPreset,
        CameraPreview;
import 'package:flutter/material.dart';
import 'package:flutter_vision/image_detail.dart' show DetailScreen;
import 'package:intl/intl.dart' show DateFormat;
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;

class CameraScreen extends StatefulWidget {
  CameraScreen({Key key, @required this.cameras}) : super(key: key);

  List<CameraDescription> cameras = [];

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController _controller;
  String _imagePath;

  @override
  void initState() {
    super.initState();

    _controller = CameraController(widget.cameras[0], ResolutionPreset.medium);
    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  void _setImagePath(path) {
    setState(() {
      _imagePath = path;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<String> _takePicture() async {
    if (!_controller.value.isInitialized) {
      print("Controller is not initialized");
      return null;
    }

    // Formatting Date and Time
    String dateTime = DateFormat.yMMMd()
        .addPattern('-')
        .add_Hms()
        .format(DateTime.now())
        .toString();

    String formattedDateTime = dateTime.replaceAll(' ', '');
    print("Formatted: $formattedDateTime");

    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String visionDir = '${appDocDir.path}/Photos/Vision\ Images';
    await Directory(visionDir).create(recursive: true);
    final String imagePath = '$visionDir/image_$formattedDateTime.jpg';

    if (_controller.value.isTakingPicture) {
      print("Processing is progress ...");
      return null;
    }

    try {
      await _controller.takePicture(imagePath);
    } on CameraException catch (e) {
      print("Camera Exception: $e");
      return null;
    }

    return imagePath;
  }

  Widget screen() {
    if (_controller.value.isInitialized) {
      return Container(
        child: Stack(
          children: <Widget>[
            Container(
              height: 400,
              child: CameraPreview(_controller),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                alignment: Alignment.bottomCenter,
                child: RaisedButton.icon(
                  icon: Icon(Icons.camera),
                  label: Text("Click"),
                  onPressed: () async {
                    await _takePicture().then((String path) {
                      if (path != null) {
                        // print('path != null $path');
                        // print(_imagePath);
                        _setImagePath(path);
                      }
                      // print('path == null');
                      // print(_imagePath);
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        color: Colors.black,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      screen(),
      Expanded(
        child: DetailScreen(imagePath: _imagePath),
      )
    ]);
  }
}
