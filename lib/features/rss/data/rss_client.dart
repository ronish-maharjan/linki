import 'package:http/http.dart' as http;

class RssClient {
  Future<String> fetch(String url) async {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'User-Agent': 'Linki/1.0',
      },
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'RSS request failed: ${response.statusCode}',
      );
    }

    return response.body;
  }
}
