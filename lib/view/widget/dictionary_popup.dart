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
          final data = jsonDecode(snapshot.data);

          return SimpleDialog(
            title: const Text('意味'),
            children: <Widget>[
              SimpleDialogOption(
                // onPressed: () { Navigator.pop(context, Department.treasury); },
                onPressed: () =>
                    print('DictionaryPopupのwordは ${data['word']} '),
                // child: Text('wordは ${data.word}'),
                child: Text('wordは '),
              ),
              SimpleDialogOption(
                // onPressed: () { Navigator.pop(context, Department.state); },
                // child: Text('発音は ${data.pronunciation.all}'),
                child: Text('発音は '),
              ),
            ],
          );
        });
  }
}

class WordObject {
  String word;
  List<Definition> results;
  Syllables syllables;
  Pronunciation pronunciation;
}

class Definition {
  String definition;
  String partOfSpeech;
  List synonyms;
  List typeOf;
  List hasTypes;
  List derivation;
  List examples;
}

class Syllables {
  int count;
  List list;
}

class Pronunciation {
  String all;
}
