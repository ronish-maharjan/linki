import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import '../../core/database/app_database.dart';

class LinkiExporter {
  static Future<bool> export({
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

    buffer.writeln();
    buffer.writeln('[RSS FEEDS]');
    buffer.writeln();

    for (var i = 0; i < feeds.length; i++) {
      final feed = feeds[i];

      buffer.writeln('${i + 1}. ${feed.name}');
      buffer.writeln(feed.url);
      buffer.writeln();
    }

    final Uint8List bytes = Uint8List.fromList(
      utf8.encode(buffer.toString()),
    );

    final path = await FilePicker.saveFile(
      dialogTitle: 'Save Linki export',
      fileName: 'linki.txt',
      type: FileType.custom,
      allowedExtensions: ['txt'],
      bytes: bytes,
    );

    return path != null;
  }
}
