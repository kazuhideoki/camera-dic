import 'package:flutter_vision/view/detail_screen.dart';
import '../importer.dart';

class Scan extends HookWidget {
  Scan({this.cameras});
  final cameras;

  Future<String> _takePicture(CameraController controller) async {
    if (!controller.value.isInitialized) {
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

    if (controller.value.isTakingPicture) {
      print("Processing is progress ...");
      return null;
    }

    try {
      await controller.takePicture(imagePath);
    } on CameraException catch (e) {
      print("Camera Exception: $e");
      return null;
    }

    return imagePath;
  }

  @override
  Widget build(BuildContext context) {
    final controller = useState<CameraController>();
    final store = useProvider(storeProvider);

    final mounted = useIsMounted();

    useEffect(() {
      final initController =
          CameraController(cameras[0], ResolutionPreset.medium);
      initController.initialize().then((_) {
        if (!mounted()) {
          return;
        }
        controller.value = initController;
      });
      return controller.dispose;
    }, []);

    if (controller == null) {
      return Container(child: Text('ぬる？`'));
    }

    return Scaffold(
      appBar: AppBar(
          // title: Text('ML Vision $userEmail'),
          ),
      body: Column(
        children: [
          Container(
            height: 400,
            child: controller.value.value.isInitialized
                ? Stack(
                    children: <Widget>[
                      CameraPreview(controller.value),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Container(
                          alignment: Alignment.bottomCenter,
                          child: RaisedButton.icon(
                            icon: Icon(Icons.camera),
                            label: Text("Click"),
                            onPressed: () async {
                              await _takePicture(controller.value)
                                  .then((String path) {
                                if (path != null) {
                                  print('pathは $path');
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (context) => DetailScreen(path),
                                  //   ),
                                  // );
                                  store.setPath(path);
                                }
                              });
                            },
                          ),
                        ),
                      )
                    ],
                  )
                : Container(
                    color: Colors.black,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
          ),
          store.path != null
              ? Expanded(
                  child: DetailScreen(),
                )
              : Text('loading'),
        ],
      ),
    );
  }
}
