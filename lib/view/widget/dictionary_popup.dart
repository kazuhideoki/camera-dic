import 'package:flutter_vision/importer.dart';
import 'package:flutter_vision/net/get_words_definition.dart';

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
              print(data);
              if (data['success'] == false) {
                return SimpleDialog(
                  title: Text('見つかりませんでした'),
                );
              }

              List<Widget> defs = [];
              Widget def;
              // 意味(definition)がある場合
              if (data['results'] != null) {
                // 意味(definition)が複数ある場合
                if (data['results'] is List) {
                  (data['results'] as List<dynamic>)
                      .asMap()
                      .forEach((index, element) {
                    defs.add(Text('【${index + 1}】: ${element['definition']}'));
                  });
                  // 意味(definition)が一つの場合
                } else {
                  def = Text('【1】: ${data['results']['definition']}');
                }
                // 意味(definition)がある場合がない場合
              } else {}

              return SimpleDialog(
                title: const Text('意味'),
                children: <Widget>[
                  SimpleDialogOption(
                    onPressed: () {
                      print(data['results']);
                    },
                    child: Text('wordは ${data['word']}'),
                  ),
                  SimpleDialogOption(
                      child: data['results'] is List
                          ? Column(
                              children: defs,
                            )
                          : def),
                  SimpleDialogOption(
                    child: Text(
                        '発音は ${data['pronunciation'] != null ? data['pronunciation']['all'] : 'なし'}'),
                  ),
                ],
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
