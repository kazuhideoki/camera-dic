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
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'scan/camera_screen.dart' show CameraScreen;

List<CameraDescription> cameras = [];

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print(e);
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        Widget home;
        if (snapshot.hasError) {
          home = Text('hasError【futureBuilder】');
        } else if (snapshot.connectionState == ConnectionState.done) {
          home = CameraScreen(cameras: cameras);
        } else {
          home = Text('loading....【futureBuilder】');
        }

        return MaterialApp(
          title: 'ML Vision',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: Scaffold(
              appBar: AppBar(
                title: Text('CAMERA DIC'),
              ),
              body: home),
        );
      },
    );
  }
}
