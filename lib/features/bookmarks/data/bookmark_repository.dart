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

  Future<bool> updateBookmark({
    required int id,
    required String title,
    required String url,
  }) async {
    return database.update(database.bookmarks).write(
          BookmarksCompanion(
            title: Value(title),
            url: Value(url),
          ),
          where: (bookmark) => bookmark.id.equals(id),
        );
  }

  Future<int> deleteBookmark(int id) {
    return (database.delete(database.bookmarks)
          ..where((bookmark) => bookmark.id.equals(id)))
        .go();
  }
}
