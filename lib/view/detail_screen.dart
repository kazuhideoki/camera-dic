import 'package:flutter_vision/net/get_words_definition.dart';
import '../importer.dart';

class DetailScreen extends StatefulWidget {
  final String imagePath;
  DetailScreen({this.imagePath});

  @override
  _DetailScreenState createState() => new _DetailScreenState(imagePath);
}

class _DetailScreenState extends State<DetailScreen> {
  _DetailScreenState(this.path);

  final String path;

  Map<String, dynamic> words = {
    "word": 'atomic',
    "results": [
      {
        "definition":
            "(weapons) deriving destructive energy from the release of atomic energy",
        "partOfSpeech": "adjective",
        "synonyms": ["nuclear"],
        "similarTo": ["thermonuclear"],
        "examples": ["atomic bombs"]
      },
      {
        "definition": "immeasurably small",
        "partOfSpeech": "adjective",
        "similarTo": ["little", "small"],
        "derivation": ["atom"]
      },
      {
        "definition": "of or relating to or comprising atoms",
        "partOfSpeech": null,
        "pertainsTo": ["atom"],
        "derivation": ["atom"],
        "examples": ["atomic structure", "atomic hydrogen"]
      }
    ],
    "syllables": {
      "count": 3,
      "list": ["a", "tom", "ic"]
    },
    "pronunciation": {"all": "ə'tɑmɪk"},
    "frequency": 3.64
  };

  Size _imageSize;
  List<TextElement> _elements = [];
  List<Widget> recognizedText = [Text("Loading ...")];

  void _initializeVision() async {
    final File imageFile = File(path);

    if (imageFile != null) {
      await _getImageSize(imageFile);
    }

    final FirebaseVisionImage visionImage =
        FirebaseVisionImage.fromFile(imageFile);

    final TextRecognizer textRecognizer =
        FirebaseVision.instance.textRecognizer();

    final VisionText visionText =
        await textRecognizer.processImage(visionImage);

    for (TextBlock block in visionText.blocks) {
      for (TextLine line in block.lines) {
        for (TextElement element in line.elements) {
          _elements.add(element);
        }
      }
    }

    // RegExp regex = new RegExp(r'/^[a-zA-Z]*$/');
    RegExp regex = new RegExp(r'[^a-zA-Z]');
    // print(('abc_)(*&').replaceAll(regex, ''));

    if (this.mounted) {
      setState(() {
        recognizedText = _elements.map((e) {
          String text = e.text.replaceAll(regex, '');
          return OutlinedButton(
              onPressed: () => getWordsDefinition(text), child: Text(text));
        }).toList();
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

  @override
  Widget build(BuildContext context) {
    final userEmail = Provider.of<UserNotifier>(context).userEmail;
    print(userEmail);

    return Scaffold(
      appBar: AppBar(
        title: Text("詳細$userEmail"),
      ),
      body: _imageSize != null
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
                          File(path),
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
                            child: Text(
                              "Identified texts",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            height: 200,
                            child: SingleChildScrollView(
                              child: Wrap(
                                spacing: 8,
                                children: recognizedText,
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
            ),
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
