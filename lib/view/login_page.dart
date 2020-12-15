import 'package:flutter_vision/view/main_tab.dart';

import '../importer.dart';
import 'scan.dart';

class LoginPage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final email = useState<String>('');
    final password = useState<String>('');
    final infoText = useState<String>('');

    void setUserEmail(String email) =>
        useProvider(storeProvider).setEmail(email);

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
                  email.value = value;
                },
              ),
              // パスワード入力
              TextFormField(
                decoration: InputDecoration(labelText: 'パスワード'),
                obscureText: true,
                onChanged: (String value) {
                  password.value = value;
                },
              ),
              Container(
                padding: EdgeInsets.all(8),
                // メッセージ表示
                child: Text(infoText.value),
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
                        email: email.value,
                        password: password.value,
                      );
                      // ユーザー登録に成功した場合
                      // チャット画面に遷移＋ログイン画面を破棄

                      await Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) {
                          // ユーザー情報を渡す
                          // return Scan(cameras: cameras);
                          return MainTab();
                        }),
                      );
                    } catch (e) {
                      // ユーザー登録に失敗した場合
                      infoText.value = "登録に失敗しました：${e.message}";
                    } finally {
                      setUserEmail(email.value);
                    }
                  },
                ),
              ),
              Container(
                width: double.infinity,
                child: OutlineButton(
                  textColor: Colors.blue,
                  child: Text('ログイン'),
                  onPressed: () async {
                    try {
                      // メール/パスワードでログイン
                      final FirebaseAuth auth = FirebaseAuth.instance;
                      final UserCredential result =
                          await auth.signInWithEmailAndPassword(
                        email: email.value,
                        password: password.value,
                      );
                      // ログインに成功した場合
                      // チャット画面に遷移＋ログイン画面を破棄
                      await Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) {
                          // ユーザー情報を渡す
                          // return Scan(cameras: cameras);
                          return MainTab();
                        }),
                      );
                    } catch (e) {
                      // ログインに失敗した場合
                      infoText.value = "ログインに失敗しました：${e.message}";
                    } finally {
                      setUserEmail(email
                          .value); // ftryの中で使うとuseContextをbuildの外で使ってるよというエラーが出てしまうのでfinallyで。
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
