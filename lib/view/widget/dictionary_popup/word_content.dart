import 'package:flutter_vision/importer.dart';
import 'pronunciation.dart';
import 'defs.dart';

class WordContent extends StatelessWidget {
  const WordContent({Key key, this.data}) : super(key: key);
  final data;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '${data['word']}',
          style: TextStyle(fontSize: 40),
        ),
        Text(
          '/${pronunciation(data)}/',
        ),
        Column(children: defs(data))
      ],
    );
  }
}
