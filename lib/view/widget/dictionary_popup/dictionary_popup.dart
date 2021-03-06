import 'package:flutter_vision/importer.dart';
import 'package:flutter_vision/net/get_words_definition.dart';
import 'package:flutter_vision/view/widget/dictionary_popup/word_content.dart';

class DictionaryPopup extends HookWidget {
  const DictionaryPopup({Key key, @required this.word}) : super(key: key);
  final String word;

  @override
  Widget build(BuildContext context) {
    final uid = useProvider(storeProvider).uid;

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

              // print(data['results']);

              final snackBar = SnackBar(
                content: Text('Save the word!'),
              );

              CollectionReference words =
                  FirebaseFirestore.instance.collection('words');
              Future<void> addWord() {
                words.add({
                  'createdAt': FieldValue.serverTimestamp(),
                  'uid': uid,
                  'data': data,
                }).then((value) {
                  print("Word Added");
                  scaffoldKey.currentState.showSnackBar(snackBar);
                }).catchError((error) => print("Failed to add word: $error"));
                Navigator.pop(context, true);
              }

              return SimpleDialog(children: [
                Stack(
                  children: [
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
                    WordContent(data: data)
                  ],
                ),
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
