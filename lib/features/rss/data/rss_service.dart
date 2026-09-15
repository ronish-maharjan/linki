import 'dart:async';

import 'rss_client.dart';
import 'rss_parser.dart';

class RssFeedResult {
  final String url;
  final List<ParsedRssArticle> articles;

  const RssFeedResult({
    required this.url,
    required this.articles,
  });
}

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

  Stream<RssFeedResult> fetchFeedsStream(
    List<String> urls, {
    int concurrency = 8,
  }) {
    if (urls.isEmpty) {
      return const Stream<RssFeedResult>.empty();
    }

    final controller = StreamController<RssFeedResult>();

    var nextIndex = 0;
    var activeWorkers = 0;
    var cancelled = false;

    Future<void> worker() async {
      while (!cancelled) {
        if (nextIndex >= urls.length) {
          break;
        }

        final index = nextIndex++;
        final url = urls[index];

        try {
          final articles = await fetchFeed(url);

          if (!cancelled) {
            controller.add(
              RssFeedResult(
                url: url,
                articles: articles,
              ),
            );
          }
        } catch (_) {
          // One broken feed should not stop the
          // remaining feeds from loading.
        }
      }

      activeWorkers--;

      if (activeWorkers == 0 &&
          !cancelled &&
          !controller.isClosed) {
        await controller.close();
      }
    }

    controller.onListen = () {
      final workerCount = concurrency.clamp(
        1,
        urls.length,
      );

      activeWorkers = workerCount;

      for (var i = 0; i < workerCount; i++) {
        worker();
      }
    };

    controller.onCancel = () {
      cancelled = true;
    };

    return controller.stream;
  }
}
