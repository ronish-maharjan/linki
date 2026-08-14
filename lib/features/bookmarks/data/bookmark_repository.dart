import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

class BookmarkRepository {
  final AppDatabase database;

  BookmarkRepository(this.database);

  Stream<List<Bookmark>> watchBookmarks() {
    return database.select(database.bookmarks).watch();
  }

  Future<int> addBookmark({
    required String title,
    required String url,
  }) {
    return database.into(database.bookmarks).insert(
          BookmarksCompanion.insert(
            title: title,
            url: url,
            createdAt: DateTime.now(),
          ),
        );
  }

  Future<void> updateBookmark({
    required int id,
    required String title,
    required String url,
  }) async {
    await (database.update(database.bookmarks)
          ..where((bookmark) => bookmark.id.equals(id)))
        .write(
      BookmarksCompanion(
        title: Value(title),
        url: Value(url),
      ),
    );
  }

  Future<void> deleteBookmark(int id) async {
    await (database.delete(database.bookmarks)
          ..where((bookmark) => bookmark.id.equals(id)))
        .go();
  }
}
