import 'package:flutter_vision/importer.dart';
import 'package:flutter_vision/net/get_words_definition.dart';
import 'defs.dart';
import 'pronunciation.dart';

class DictionaryPopup extends StatelessWidget {
  const DictionaryPopup({Key key, @required this.word}) : super(key: key);
  final String word;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getWordsDefinition(word),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              final data = jsonDecode(snapshot.data) as Map<String, dynamic>;
              if (data['success'] == false) {
                return SimpleDialog(
                  title: Text('Not Found'),
                  titlePadding: const EdgeInsets.all(24),
                );
              }

              print(data['results']);

              CollectionReference words =
                  FirebaseFirestore.instance.collection('words');
              // FirebaseFirestore.instance
              //     .settings({timestampsInSnapshots: true});

              Future<void> addWord() {
                // words.set({
                //   createdAt: FirebaseFirestore.FieldValue.serverTimestamp()
                // })
                return words
                    .add({
                      'createdAt': FieldValue.serverTimestamp(),
                      'data': data,
                    })
                    .then((value) => print("Word Added"))
                    .catchError((error) => print("Failed to add word: $error"));
                // return words.doc(data['word'])
                //     .set({
                //       createdAt:
                //     })
                //     .then((value) => print("Word Added"))
                //     .catchError((error) => print("Failed to add word: $error"));
              }

              return SimpleDialog(
                  title: Stack(
                    children: [
                      Text('${data['word']} /${pronunciation(data)}/'),
                      Container(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                            icon: Icon(
                              Icons.add_circle,
                              color: Colors.orange,
                              size: 40,
                            ),
                            onPressed: () => addWord()),
                      ),
                    ],
                  ),
                  children: <Widget>[
                    SimpleDialogOption(
                        child: Column(
                      children: defs(data),
                    )),
                  ]);
            } else if (snapshot.hasError) {
              return SimpleDialog(
                children: [Text('error occared')],
              );
            }
          } else {
            return SimpleDialog(
              children: [
                Center(
                  child: CircularProgressIndicator(),
                )
              ],
            );
          }
        });
  }
}

// class WordObject {
//   WordObject(this.word, this.results, this.syllables, this.pronunciation);

//   final String word;
//   final List<Definition> results;
//   final Syllables syllables;
//   final Pronunciation pronunciation;

//   WordObject.fromJson(Map<String, dynamic> json)
//       : word = json['word'],
//         results = json['results'].map((value) => Definition.fromJson(value)),
//         syllables = json['syllables'],
//         pronunciation = json['pronunciation'];
// }
class WordObject {
  WordObject(this._word, this._results, this._syllables, this._pronunciation);

  String _word;
  get word => _word;
  List<Definition> _results;
  get results => _results;
  Syllables _syllables;
  get syllables => _syllables;
  Pronunciation _pronunciation;
  get pronunciation => _pronunciation;
}

class Definition {
  Definition(this.definition, this.partOfSpeech, this.synonyms, this.typeOf,
      this.hasTypes, this.derivation, this.examples);
  String definition;
  String partOfSpeech;
  List synonyms;
  List typeOf;
  List hasTypes;
  List derivation;
  List examples;

  Definition.fromJson(Map<String, dynamic> json)
      : definition = json['definition'],
        partOfSpeech = json['partOfSpeech'],
        synonyms = json['synonyms'],
        typeOf = json['typeOf'],
        hasTypes = json['hasTypes'],
        derivation = json['derivation'],
        examples = json['examples'];
}

class Syllables {
  Syllables(this.count, this.list);
  int count;
  List list;
}

class Pronunciation {
  Pronunciation(this.all);
  String all;
}
