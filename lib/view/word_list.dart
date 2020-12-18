import 'package:flutter_vision/importer.dart';

class WordList extends StatelessWidget {
  const WordList({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Query words = FirebaseFirestore.instance
        .collection('words')
        .orderBy('createdAt', descending: true);

    return StreamBuilder(
      stream: words.snapshots(),
      // initialData: initialData,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          final List<DocumentSnapshot> documents = snapshot.data.docs;
          return ListView(
              children: documents
                  .map((doc) => Card(
                        child: ListTile(
                          title: Text(doc['data']['word']),
                          // subtitle: Text(doc['email']),
                        ),
                      ))
                  .toList());
        }
      },
    );
  }
}
