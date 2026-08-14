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

  Future<void> deleteBookmark(int id) async {
    await (database.delete(database.bookmarks)
          ..where((bookmark) => bookmark.id.equals(id)))
        .go();
  }
}
