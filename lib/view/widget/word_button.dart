import 'package:flutter_vision/importer.dart';
import 'package:flutter_vision/view/widget/dictionary_popup/dictionary_popup.dart';

class WordButton extends StatelessWidget {
  const WordButton({Key key, @required this.text}) : super(key: key);
  final String text;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
        onPressed: () => showDialog(
            context: context,
            builder: (BuildContext context) => DictionaryPopup(word: text)),
        child: Text(text));
  }
}
