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
    if (value == null || value.isEmpty) return null;
  
    // 1. ISO 8601 / RFC 3339 (Atom feeds)
    // Example: 2026-07-21T00:00:00+00:00
    final iso = DateTime.tryParse(value);
    if (iso != null) return iso;
  
    // 2. RFC 822 / RFC 2822 (RSS 2.0 feeds)
    // Examples: Fri, 07 Aug 2026 16:01:02 GMT
    //           Fri, 07 Aug 2026 16:01:02 +0000
    //           07 Aug 2026 16:01:02 +05:30
    return _parseRfc822Date(value);
  }
  
  DateTime? _parseRfc822Date(String value) {
    var cleaned = value.trim();
  
    // Strip optional day name like "Fri, " or "Friday, "
    final commaIdx = cleaned.indexOf(',');
    if (commaIdx != -1 && commaIdx < 15) {
      cleaned = cleaned.substring(commaIdx + 1).trim();
    }
  
    const months = {
      'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4,
      'May': 5, 'Jun': 6, 'Jul': 7, 'Aug': 8,
      'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
    };
  
    final match = RegExp(
      r'^(\d{1,2})\s+([A-Za-z]{3})\s+(\d{4})\s+(\d{1,2}):(\d{2}):(\d{2})\s*([\+\-]?\d[\d:]*)?$',
    ).firstMatch(cleaned);
  
    if (match == null) return null;
  
    final day = int.tryParse(match.group(1)!);
    final month = months[match.group(2)!];
    final year = int.tryParse(match.group(3)!);
    final hour = int.tryParse(match.group(4)!);
    final minute = int.tryParse(match.group(5)!);
    final second = int.tryParse(match.group(6)!);
    final tz = (match.group(7) ?? '').trim();
  
    if (day == null || month == null || year == null ||
        hour == null || minute == null || second == null) {
      return null;
    }
  
    // Parse timezone offset
    Duration offset = Duration.zero;
  
    if (tz.isNotEmpty && tz != 'GMT' && tz != 'UTC') {
      // Numeric offsets: +0000, +00:00, -0530
      if (tz.startsWith('+') || tz.startsWith('-')) {
        final sign = tz.startsWith('-') ? -1 : 1;
        final nums = tz.substring(1).replaceAll(':', '');
        if (nums.length >= 2) {
          final h = int.tryParse(nums.substring(0, 2)) ?? 0;
          final m = nums.length >= 4 ? int.tryParse(nums.substring(2, 4)) ?? 0 : 0;
          offset = Duration(hours: h * sign, minutes: m * sign);
        }
      } else {
        // Common abbreviations
        const abbr = {
          'UT': 0, 'GMT': 0, 'UTC': 0,
          'EST': -5, 'EDT': -4,
          'CST': -6, 'CDT': -5,
          'MST': -7, 'MDT': -6,
          'PST': -8, 'PDT': -7,
        };
        final h = abbr[tz.toUpperCase()];
        if (h != null) offset = Duration(hours: h);
      }
    }
  
    try {
      final dt = DateTime.utc(year, month, day, hour, minute, second);
      return dt.subtract(offset); // Convert to UTC
    } catch (_) {
      return null;
    }
  }

}
