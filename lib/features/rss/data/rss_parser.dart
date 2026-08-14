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
    final root = document.rootElement;

    // RSS 2.0
    if (root.name.local == 'rss') {
      return _parseRss(root);
    }

    // Atom
    if (root.name.local == 'feed') {
      return _parseAtom(root);
    }

    throw const FormatException(
      'Unsupported feed format',
    );
  }

  // ─────────────────────────────────────────────
  // RSS 2.0
  // ─────────────────────────────────────────────

  ParsedRssFeed _parseRss(XmlElement root) {
    final channel = root
        .findElements('channel')
        .firstOrNull;

    if (channel == null) {
      throw const FormatException(
        'Invalid RSS feed',
      );
    }

    final title = _text(
          channel,
          'title',
        ) ??
        'RSS Feed';

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
        .map(_parseRssItem)
        .where(
          (article) => article.url.isNotEmpty,
        )
        .toList();

    return ParsedRssFeed(
      title: title,
      description: description,
      websiteUrl: websiteUrl,
      articles: articles,
    );
  }

  ParsedRssArticle _parseRssItem(
    XmlElement item,
  ) {
    final title = _text(
          item,
          'title',
        ) ??
        'Untitled';

    final url = _text(
          item,
          'link',
        ) ??
        '';

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

  // ─────────────────────────────────────────────
  // Atom
  // ─────────────────────────────────────────────

  ParsedRssFeed _parseAtom(XmlElement root) {
    final title = _text(
          root,
          'title',
        ) ??
        'Atom Feed';

    final description = _text(
      root,
      'subtitle',
    );

    final websiteUrl = _atomLink(
      root,
      alternate: true,
    );

    final articles = root
        .findElements('entry')
        .map(_parseAtomEntry)
        .where(
          (article) => article.url.isNotEmpty,
        )
        .toList();

    return ParsedRssFeed(
      title: title,
      description: description,
      websiteUrl: websiteUrl,
      articles: articles,
    );
  }

  ParsedRssArticle _parseAtomEntry(
    XmlElement entry,
  ) {
    final title = _text(
          entry,
          'title',
        ) ??
        'Untitled';

    final url = _atomLink(
          entry,
          alternate: true,
        ) ??
        _atomLink(
          entry,
          alternate: false,
        ) ??
        '';

    final description =
        _text(entry, 'summary') ??
        _text(entry, 'content');

    final published =
        _text(entry, 'published');

    final updated =
        _text(entry, 'updated');

    final publishedAt = _parseDate(
      published ?? updated,
    );

    return ParsedRssArticle(
      title: title,
      url: url,
      description: description,
      publishedAt: publishedAt,
    );
  }

  // ─────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────

  String? _text(
    XmlElement element,
    String name,
  ) {
    final child = element
        .findElements(name)
        .firstOrNull;

    return child?.innerText.trim();
  }

  String? _atomLink(
    XmlElement element, {
    required bool alternate,
  }) {
    final links = element.findElements('link');

    for (final link in links) {
      final rel = link.getAttribute('rel');

      if (alternate) {
        if (rel == null || rel == 'alternate') {
          final href = link.getAttribute('href');

          if (href != null &&
              href.trim().isNotEmpty) {
            return href.trim();
          }
        }
      } else {
        final href = link.getAttribute('href');

        if (href != null &&
            href.trim().isNotEmpty) {
          return href.trim();
        }
      }
    }

    return null;
  }

  DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    return DateTime.tryParse(value);
  }
}
