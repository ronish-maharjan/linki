import 'package:xml/xml.dart';

class ParsedRssFeed {
  final String title;
  final String? description;
  final String? websiteUrl;
  final List<ParsedRssArticle> articles;

  const ParsedRssFeed({
    required this.title,
    this.description,
    this.websiteUrl,
    required this.articles,
  });
}

class ParsedRssArticle {
  final String title;
  final String url;
  final String? description;
  final DateTime? publishedAt;

  const ParsedRssArticle({
    required this.title,
    required this.url,
    this.description,
    this.publishedAt,
  });
}

class RssParser {
  ParsedRssFeed parse(String xmlString) {
    final document = XmlDocument.parse(xmlString);

    final channel = document
        .findAllElements('channel')
        .firstOrNull;

    if (channel == null) {
      throw const FormatException(
        'Invalid RSS feed',
      );
    }

    final title = _text(channel, 'title') ?? 'RSS Feed';

    final description = _text(
      channel,
      'description',
    );

    final websiteUrl = _text(
      channel,
      'link',
    );

    final articles = channel
        .findElements('item')
        .map(_parseItem)
        .where((article) => article.url.isNotEmpty)
        .toList();

    return ParsedRssFeed(
      title: title,
      description: description,
      websiteUrl: websiteUrl,
      articles: articles,
    );
  }

  ParsedRssArticle _parseItem(XmlElement item) {
    final title = _text(item, 'title') ?? 'Untitled';

    final url = _text(item, 'link') ?? '';

    final description = _text(
      item,
      'description',
    );

    final publishedAt = _parseDate(
      _text(item, 'pubDate'),
    );

    return ParsedRssArticle(
      title: title,
      url: url,
      description: description,
      publishedAt: publishedAt,
    );
  }

  String? _text(
    XmlElement element,
    String name,
  ) {
    final child = element
        .findElements(name)
        .firstOrNull;

    return child?.innerText.trim();
  }

  DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    return DateTime.tryParse(value);
  }
}
