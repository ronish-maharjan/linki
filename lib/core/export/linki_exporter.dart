import 'package:flutter/services.dart';

import '../database/app_database.dart';

class LinkiExporter {
  static const MethodChannel _channel =
      MethodChannel('linki/file');

  static Future<void> save({
    required List<Bookmark> bookmarks,
    required List<RssFeed> feeds,
  }) async {
    final buffer = StringBuffer();

    buffer.writeln('[BOOKMARKS]');
    buffer.writeln();

    for (var i = 0; i < bookmarks.length; i++) {
      final bookmark = bookmarks[i];

      buffer.writeln('${i + 1}. ${bookmark.title}');
      buffer.writeln(bookmark.url);
      buffer.writeln();
    }

    buffer.writeln('[RSS FEEDS]');
    buffer.writeln();

    for (var i = 0; i < feeds.length; i++) {
      final feed = feeds[i];

      buffer.writeln('${i + 1}. ${feed.name}');
      buffer.writeln(feed.url);
      buffer.writeln();
    }

    await _channel.invokeMethod<void>(
      'saveFile',
      {
        'content': buffer.toString(),
      },
    );
  }
}
