import 'package:flutter_vision/importer.dart';
import 'package:flutter_vision/net/get_words_definition.dart';
import 'package:http/http.dart';

class DictionaryPopup extends StatelessWidget {
  const DictionaryPopup({Key key, @required this.word}) : super(key: key);
  final String word;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getWordsDefinition(word),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          // final data = jsonDecode(snapshot.data) as WordObject;
          // final data = WordObject(d['word'], d['results'] as List<Definition>,
          //     d['syllables'], d['pronuncation']);

          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              final data = jsonDecode(snapshot.data);
              return data['success'] != false
                  ? SimpleDialog(
                      title: const Text('意味'),
                      children: <Widget>[
                        SimpleDialogOption(
                          // onPressed: () { Navigator.pop(context, Department.treasury); },
                          onPressed: () {
                            print(snapshot);
                          },
                          // child: Text('wordは ${data.word}'),
                          child: Text('wordは ${data['word']}'),
                        ),
                        SimpleDialogOption(
                          // onPressed: () { Navigator.pop(context, Department.state); },
                          // child: Text('発音は ${data.pronunciation.all}'),
                          child: Text('発音は '),
                        ),
                      ],
                    )
                  : SimpleDialog(
                      title: Text('見つかりませんでした'),
                    );
            } else if (snapshot.hasError) {
              return SimpleDialog(
                children: [Text('error occared')],
              );
            }
          } else {
            return SimpleDialog(
              children: [
                Center(
                  // height: 20,
                  // width: 20,
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
