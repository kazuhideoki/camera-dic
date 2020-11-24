import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './wordList.dart';
import 'package:camera_dic/scan.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          // エラー時に表示するWidget
          if (snapshot.hasError) {
            return MaterialApp(
              home: Scaffold(
                // body: Text('エラーだよ【main】'),
                body: GetUserName('2kfcz2i9fjQ35TnUQhKl'),
              ),
            );
          }

          // Firebaseのinitialize完了したら表示したいWidget
          if (snapshot.connectionState == ConnectionState.done) {
            return MaterialApp(
              home: Scaffold(
                  // body: Text('アプリだよ!!!'),
                  body: Column(
                children: [
                  GetUserName('2kfcz2i9fjQ35TnUQhKl'),
                  Scan(),
                ],
              )),
            );
          }

          // Firebaseのinitializeが完了するのを待つ間に表示するWidget
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('loading....【main】'),
              ),
            ),
          );
          // return Text('loading...');
        });
  }
}
