import 'importer.dart';
import './view/login_page.dart';

List<CameraDescription> cameras = [];

final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

final storeProvider = ChangeNotifierProvider((ref) => StoreNotifier());

void main() async {
  // 最初に表示するWidget
  try {
    await DotEnv().load('.env');
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print(e);
  }

  final Future<FirebaseApp> initialization = Firebase.initializeApp();
  runApp(ProviderScope(child: App(initialization)));
}

class App extends StatelessWidget {
  App(this.initialization);
  // Create the initialization Future outside of `build`:
  final Future<FirebaseApp> initialization;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return MyApp(
            child: Scaffold(
              body: Text('snapshot.haserror ${snapshot.error}'),
            ),
          );
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return MyApp(child: LoginPage());
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return MyApp(
          child: Scaffold(
            body: Text('loading...'),
          ),
        );
      },
    );
  }
}

class MyApp extends StatelessWidget {
  MyApp({this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: child,
    );
  }
}

class StoreNotifier extends ChangeNotifier {
  String _userEmail = '<初期>';
  String get userEmail => _userEmail;
  void setEmail(String email) {
    _userEmail = email;
    print('setEmailは $_userEmail');
    notifyListeners();
  }

  String _uid = '';
  String get uid => _uid;
  void setUid(String uid) {
    _uid = uid;
    print('setUidは $_uid');
    notifyListeners();
  }

  Map<String, dynamic> _definitionWords;
  Map<String, dynamic> get definitionWords => _definitionWords;
  void setWords(Map<String, dynamic> words) {
    _definitionWords = words;
    notifyListeners();
  }

  String _path;
  String get path => _path;
  void setPath(String path) {
    _path = path;
    notifyListeners();
  }
}
