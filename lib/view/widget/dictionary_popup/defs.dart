import 'package:flutter_vision/importer.dart';

List<ExpansionTile> defs(data) {
  List<ExpansionTile> defList = [];
  // 意味(definition)がある場合
  if (data['results'] != null) {
    // 意味(definition)が複数ある場合
    if (data['results'] is List) {
      (data['results'] as List<dynamic>).asMap().forEach((index, element) {
        String def = element['definition'];
        List synonyms = element['synonyms'];
        List examples = element['examples'];
        defList.add(ExpansionTile(
          title: Text(
              '【${index + 1}】[${element['partOfSpeech']}]: ${def.length > 30 ? def.substring(0, 30) + "..." : def}'),
          children: [
            ListTile(
              title: Text(element['definition']),
            ),
            synonyms != null && synonyms.length != 0
                ? ListTile(
                    title: Text('Synonyms'),
                    subtitle: Column(
                      children: synonyms
                          .map((value) => Text(value as String))
                          .toList(),
                    ),
                  )
                : Text(''),
            examples != null && examples.length != 0
                ? ListTile(
                    title: Text('Examples'),
                    subtitle: Column(
                      children: examples
                          .map((value) => Text(value as String))
                          .toList(),
                    ),
                  )
                : Text('')
          ],
        ));
      });
      // 意味(definition)が一つの場合
    } else {
      defList.add(ExpansionTile(
          title: Text('【1】: ${data['results']['definition']}...')));
    }
    // 意味(definition)がない場合
  } else {
    defList.add(ExpansionTile(title: Text('No data...')));
  }
  print(defList);
  return defList;
}
