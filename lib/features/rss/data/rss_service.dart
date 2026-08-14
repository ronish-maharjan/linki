import 'rss_client.dart';
import 'rss_parser.dart';

class RssService {
  final RssClient client;
  final RssParser parser;

  RssService({
    RssClient? client,
    RssParser? parser,
  })  : client = client ?? RssClient(),
        parser = parser ?? RssParser();

  Future<List<ParsedRssArticle>> fetchFeed(
    String url,
  ) async {
    final xml = await client.fetch(url);

    final feed = parser.parse(xml);

    return feed.articles;
  }

  Future<List<ParsedRssArticle>> fetchFeeds(
    List<String> urls,
  ) async {
    final results = await Future.wait(
      urls.map(
        (url) => fetchFeed(url),
      ),
    );

    return results.expand((items) => items).toList();
  }
}
