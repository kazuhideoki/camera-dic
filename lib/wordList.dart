import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart'
    show CollectionReference, FirebaseFirestore, DocumentSnapshot;

class GetUserName extends StatelessWidget {
  final String documentId;

  GetUserName(this.documentId);

  @override
  Widget build(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(documentId).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong【wordList】");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data = snapshot.data.data();
          return Text("フルネームは: ${data['full_name']} ${data['last_name']}");
        }

        return Center(
          child: Text('loading...【wordList】'),
        );
      },
    );
  }
}
