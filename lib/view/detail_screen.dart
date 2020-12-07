import 'package:flutter_vision/net/get_words_definition.dart';
import '../importer.dart';

class DetailScreen extends HookWidget {
  DetailScreen(this.path);

  final String path;

  void _initializeVision(
      {List<TextElement> elements,
      List<dynamic> recognizedText,
      Size imageSize,
      bool Function() mounted}) async {
    final File imageFile = File(path);

    if (imageFile != null) {
      await _getImageSize(imageFile: imageFile, imageSize: imageSize);
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
          elements.add(element);
        }
      }
    }

    RegExp regex = new RegExp(r'[^a-zA-Z]');

    if (mounted() != null) {
      recognizedText = elements.map((e) {
        String text = e.text.replaceAll(regex, '');
        return OutlinedButton(
            onPressed: () => getWordsDefinition(text), child: Text(text));
      }).toList();
    }
  }

  Future<void> _getImageSize({File imageFile, Size imageSize}) async {
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

    imageSize = await completer.future;
  }

  @override
  Widget build(BuildContext context) {
    final imageSize = useState<Size>();
    final elements = useState<List<TextElement>>([]);
    final recognizedText = useState<List<dynamic>>([Text("Loading ...")]);

    // final userEmail = useProvider(userProvider).userEmail;
    // print(userEmail);
    final mounted = useIsMounted();

    useEffect(() {
      _initializeVision(
        mounted: mounted,
        // imageSize: imageSize.value,
        // elements: elements.value,
        // recognizedText: recognizedText.value
      );
      return null;
    }, const []);

    return Scaffold(
      appBar: AppBar(
          // title: Text("詳細$userEmail"),
          ),
      body: imageSize != null
          ? Stack(
              children: <Widget>[
                Center(
                  child: Container(
                    width: double.maxFinite,
                    color: Colors.black,
                    child: CustomPaint(
                      foregroundPainter:
                          TextDetectorPainter(imageSize.value, elements.value),
                      child: AspectRatio(
                        aspectRatio: imageSize.value.aspectRatio,
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
                                children: recognizedText.value,
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
