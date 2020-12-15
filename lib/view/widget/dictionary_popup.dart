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
                  title: Text('見つかりませんでした。'),
                );
              }

              print(data['results']);

              List<ExpansionTile> defs = [];
              // 意味(definition)がある場合
              if (data['results'] != null) {
                print(data['results'] != null);
                // 意味(definition)が複数ある場合
                if (data['results'] is List) {
                  (data['results'] as List<dynamic>)
                      .asMap()
                      .forEach((index, element) {
                    String def = element['definition'];
                    defs.add(ExpansionTile(
                      title: Text(
                          '【${index + 1}】: ${def.length > 30 ? def.substring(0, 30) + "..." : def}'),
                      children: [
                        ListTile(
                          title: Text(element['definition']),
                        )
                      ],
                    ));
                  });
                  // 意味(definition)が一つの場合
                } else {
                  defs.add(ExpansionTile(
                      title: Text('【1】: ${data['results']['definition']}...')));
                }
                // 意味(definition)がない場合
              } else {
                defs.add(ExpansionTile(title: Text('意味なし')));
              }
              print(defs);

              String pronunciation;
              if (data['rhymes'] != null) {
                pronunciation = '/${data['rhymes']['all']}/';
              } else if (data['pronunciation'] != null) {
                pronunciation = '/${data['pronunciation']['all']}/';
              } else {
                pronunciation = '';
              }

              return SimpleDialog(
                  title: Text('${data['word']} /$pronunciation/'),
                  children: <Widget>[
                    SimpleDialogOption(
                        child: Column(
                      children: defs,
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
