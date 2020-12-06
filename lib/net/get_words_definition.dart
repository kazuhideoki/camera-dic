import '../importer.dart';
import 'package:http/http.dart' as http;

void getWordsDefinition(String word) async {
  final headers = {
    "x-rapidapi-key": DotEnv().env['X_RAPIDAPI_KEY'],
    "x-rapidapi-host": "wordsapiv1.p.rapidapi.com",
    "useQueryString": "true",
  };
  String url = 'https://wordsapiv1.p.rapidapi.com/words/$word';

  http.Response result = await http.get(url, headers: headers);

  print(result.body);
}
