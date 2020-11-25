import 'package:flutter/material.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart'
    show
        FirebaseVisionImage,
        VisionText,
        TextElement,
        TextRecognizer,
        FirebaseVision,
        TextLine,
        TextBlock,
        TextContainer;
import 'dart:io' show File;
// import 'dart:ui';
import 'dart:async' show Completer;
import 'wordList.dart' show GetUserName;

class DetailScreen extends StatefulWidget {
  DetailScreen({Key key, @required this.imagePath}) : super(key: key);
  final String imagePath;

  @override
  _DetailScreenState createState() => new _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // final String path;

  Size _imageSize;
  List<TextElement> _elements = [];
  String recognizedText = "Loading ...";

  void _initializeVision() async {
    final File imageFile = File(widget.imagePath);
    print('_initializeVisionのimagePath ${widget.imagePath}');

    if (imageFile != null) {
      await _getImageSize(imageFile);
    }

    final FirebaseVisionImage visionImage =
        FirebaseVisionImage.fromFile(imageFile);

    final TextRecognizer textRecognizer =
        FirebaseVision.instance.textRecognizer();

    final VisionText visionText =
        await textRecognizer.processImage(visionImage);

    String texts = "";
    for (TextBlock block in visionText.blocks) {
      for (TextLine line in block.lines) {
        texts += line.text + '\n';
        for (TextElement element in line.elements) {
          _elements.add(element);
        }
      }
    }

    if (this.mounted) {
      setState(() {
        recognizedText = texts;
      });
    }
  }

  Future<void> _getImageSize(File imageFile) async {
    final Completer<Size> completer = Completer<Size>();

    final Image image = Image.file(imageFile);
    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        ));
      }),
    );

    final Size imageSize = await completer.future;
    setState(() {
      _imageSize = imageSize;
    });
  }

  @override
  void initState() {
    _initializeVision();
    super.initState();
  }

  Widget scanResult() {
    return _imageSize != null
        ? Stack(
            children: <Widget>[
              Center(
                child: Container(
                  width: double.maxFinite,
                  color: Colors.black,
                  child: CustomPaint(
                    foregroundPainter:
                        TextDetectorPainter(_imageSize, _elements),
                    child: AspectRatio(
                      aspectRatio: _imageSize.aspectRatio,
                      child: Image.file(
                        File(widget.imagePath),
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Card(
                  elevation: 8,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: GetUserName('2kfcz2i9fjQ35TnUQhKl'),
                        ),
                        Container(
                          height: 60,
                          child: SingleChildScrollView(
                            child: Text(
                              recognizedText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )
        : Container(
            color: Colors.black,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          child: widget.imagePath != null
              ? Text('imagePathは ${widget.imagePath}')
              : null,
        ),
        Container(
          child: Text('imageSizeは ${_imageSize.toString()}'),
        ),
        Container(
          child: Text(File(widget.imagePath).toString()),
        ),
        Container(
          child: Text('recognizedTextは ${recognizedText}'),
        ),
        scanResult(),
      ],
    );
  }
}

class TextDetectorPainter extends CustomPainter {
  TextDetectorPainter(this.absoluteImageSize, this.elements);

  final Size absoluteImageSize;
  final List<TextElement> elements;

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;

    Rect scaleRect(TextContainer container) {
      return Rect.fromLTRB(
        container.boundingBox.left * scaleX,
        container.boundingBox.top * scaleY,
        container.boundingBox.right * scaleX,
        container.boundingBox.bottom * scaleY,
      );
    }

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.red
      ..strokeWidth = 2.0;

    for (TextElement element in elements) {
      canvas.drawRect(scaleRect(element), paint);
    }
  }

  @override
  bool shouldRepaint(TextDetectorPainter oldDelegate) {
    return true;
  }
}
