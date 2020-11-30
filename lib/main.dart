import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:flutter_vision/scan.dart';

List<CameraDescription> cameras = [];

void main() async {
  // 最初に表示するWidget
  try {
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
  Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: MaterialApp(
      home: ChangeNotifierProvider<_UserNotifier>(
        create: (_) => _UserNotifier(),
        child: child,
      ),
    ));
  }
}

class _UserNotifier extends ChangeNotifier {
  String _userEmail = '';
  void setUserEmail(String email) {
    _userEmail = email;
    notifyListeners();
  }

  // String _email;
  // void setEmail(String email) {
  //   _email = email;
  //   notifyListeners();
  // }

  // String _password;
  // void setPassword(String password) {
  //   _password = password;
  //   notifyListeners();
  // }

  // String _infoText;
  // void setInfoText(String infoText) {
  //   _infoText = infoText;
  //   notifyListeners();
  // }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String email = '';
  String password = '';
  String infoText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // メールアドレス入力
              TextFormField(
                decoration: InputDecoration(labelText: 'メールアドレス'),
                onChanged: (String value) {
                  setState(() {
                    email = value;
                  });
                },
              ),
              // パスワード入力
              TextFormField(
                decoration: InputDecoration(labelText: 'パスワード'),
                obscureText: true,
                onChanged: (String value) {
                  setState(() {
                    password = value;
                  });
                },
              ),
              Container(
                padding: EdgeInsets.all(8),
                // メッセージ表示
                child: Text(infoText),
              ),
              Container(
                width: double.infinity,
                // ユーザー登録ボタン
                child: RaisedButton(
                  color: Colors.blue,
                  textColor: Colors.white,
                  child: Text('ユーザー登録'),
                  onPressed: () async {
                    try {
                      // メール/パスワードでユーザー登録
                      final FirebaseAuth auth = FirebaseAuth.instance;
                      final UserCredential result =
                          await auth.createUserWithEmailAndPassword(
                        email: email,
                        password: password,
                      );
                      final User user = result.user;
                      // ユーザー登録に成功した場合
                      // チャット画面に遷移＋ログイン画面を破棄
                      await Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) {
                          // ユーザー情報を渡す
                          return Scan(cameras);
                        }),
                      );
                    } catch (e) {
                      // ユーザー登録に失敗した場合
                      setState(() {
                        infoText = "登録に失敗しました：${e.message}";
                      });
                    }
                  },
                ),
              ),
              Container(
                width: double.infinity,
                // ログイン登録ボタン
                child: OutlineButton(
                  textColor: Colors.blue,
                  child: Text('ログイン'),
                  onPressed: () async {
                    try {
                      // メール/パスワードでログイン
                      final FirebaseAuth auth = FirebaseAuth.instance;
                      final UserCredential result =
                          await auth.signInWithEmailAndPassword(
                        email: email,
                        password: password,
                      );
                      // ログインに成功した場合
                      // チャット画面に遷移＋ログイン画面を破棄
                      await Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) {
                          // ユーザー情報を渡す
                          return Scan(cameras);
                        }),
                      );
                    } catch (e) {
                      // ログインに失敗した場合
                      setState(() {
                        infoText = "ログインに失敗しました：${e.message}";
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
