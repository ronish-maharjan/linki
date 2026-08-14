import '../../../core/database/app_database.dart';

class RssRepository {
  final AppDatabase database;

  RssRepository(this.database);

  Stream<List<RssFeed>> watchFeeds() {
    return database.select(database.rssFeeds).watch();
  }

  Future<int> addFeed({
    required String name,
    required String url,
  }) {
    return database.into(database.rssFeeds).insert(
          RssFeedsCompanion.insert(
            name: name,
            url: url,
            createdAt: DateTime.now(),
          ),
        );
  }

  Future<void> deleteFeed(int id) async {
    await (database.delete(database.rssFeeds)
          ..where((feed) => feed.id.equals(id)))
        .go();
  }
}
