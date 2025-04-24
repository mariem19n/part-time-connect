import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<dynamic>> fetchCandidates({
  String searchQuery = '',
  List<String> skills = const [],
  int page = 1,
}) async {
  final uri = Uri.parse('http://10.0.2.2:8000/api/candidates/').replace(queryParameters: {
    'search': searchQuery,
    'skills': skills.join(','),
    'page': page.toString(),
  });

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    return json.decode(response.body)['results'] as List<dynamic>;
  } else {
    throw Exception('Failed to load candidates');
  }
}
