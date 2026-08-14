import 'package:drift/drift.dart';

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

  Future<void> updateFeed({
    required int id,
    required String name,
    required String url,
  }) async {
    await (database.update(database.rssFeeds)
          ..where((feed) => feed.id.equals(id)))
        .write(
      RssFeedsCompanion(
        name: Value(name),
        url: Value(url),
      ),
    );
  }

  Future<void> deleteFeed(int id) async {
    await (database.delete(database.rssFeeds)
          ..where((feed) => feed.id.equals(id)))
        .go();
  }
}
