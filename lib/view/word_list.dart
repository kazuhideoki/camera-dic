import 'package:flutter_vision/importer.dart';
import 'package:flutter_vision/view/widget/dictionary_popup/word_content.dart';

class WordList extends HookWidget {
  const WordList({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final uid = useProvider(storeProvider).uid;
    final wordsQuery = FirebaseFirestore.instance
        .collection('words')
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true);

    CollectionReference words = FirebaseFirestore.instance.collection('words');
    Future<void> deleteWord(documentId) {
      return words
          .doc(documentId)
          .delete()
          .then((value) => print("User Deleted"))
          .catchError((error) => print("Failed to delete user: $error"));
    }

    return StreamBuilder(
      stream: wordsQuery.snapshots(),
      // initialData: initialData,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          final List<DocumentSnapshot> documents = snapshot.data.docs;

          return ListView(
              children: documents
                  .map(
                    (doc) => Card(
                      key: Key(doc.id),
                      child: ExpansionTile(
                        title: Text(doc['data']['word']),
                        children: [WordContent(data: doc['data'])],
                        trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => deleteWord(doc.reference.id)),
                      ),
                    ),
                  )
                  .toList());
        } else {
          return Container(
            child: Text('loading...'),
          );
        }
      },
    );
  }
}
