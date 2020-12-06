import 'importer.dart';
import './view/login_page.dart';

List<CameraDescription> cameras = [];

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
  runApp(App(initialization));
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
    return ChangeNotifierProvider<UserNotifier>(
      create: (_) => UserNotifier(),
      child: MaterialApp(
        home: LoginPage(),
      ),
    );
  }
}

class UserNotifier extends ChangeNotifier {
  String userEmail = '<初期>';
  void setEmail(String email) {
    userEmail = email;
    notifyListeners();
  }

  Map<String, dynamic> definitionWords;
  void setWords(Map<String, dynamic> words) {
    definitionWords = words;
    notifyListeners();
  }
}
