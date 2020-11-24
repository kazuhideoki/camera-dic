import 'package:flutter/material.dart';

// Import the firebase_core and cloud_firestore plugin
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:developer';
// import 'package:firebase_ml_vision/firebase_ml_vision.dart';

class Scan extends StatefulWidget {
  Scan({Key key}) : super(key: key);

  @override
  _ScanState createState() => _ScanState();
}

class _ScanState extends State<Scan> {
  File _image;
  // File _image = File('/images/text_picture.png');
  // Image _image = Image.asset('images/text_picture.png');
  final picker = ImagePicker();

  Future getImage() async {
    log('ログ');
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: ButtonBar(
      children: [
        // _image == null ? Text('No image selected.d') : Image.file(_image),
        Image.asset('images/text_picture.png'),
        RaisedButton(
          child: Icon(
            Icons.camera,
            size: 64,
          ),
          onPressed: () => getImage(),
          // onPressed: () => print(_image.toString()),
        ),
        RaisedButton(
          child: Icon(
            Icons.question_answer_outlined,
            size: 64,
          ),
          onPressed: () => print(_image.toString()),
          // onPressed: () => print(_image.toString()),
        )
      ],
    ));
  }
}
