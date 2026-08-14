import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../data/rss_parser.dart';
import '../data/rss_repository.dart';
import '../data/rss_service.dart';
import 'rss_article_list.dart';
import 'rss_article_skeleton.dart';

class RssHomeScreen extends StatefulWidget {
  final AppDatabase database;

  const RssHomeScreen({
    super.key,
    required this.database,
  });

  @override
  State<RssHomeScreen> createState() => _RssHomeScreenState();
}

class _RssHomeScreenState extends State<RssHomeScreen> {
  late final RssRepository _repository;
  late final RssService _service;

  List<_RssArticleWithFeed> _articles = [];

  bool _loading = true;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();

    _repository = RssRepository(widget.database);
    _service = RssService();

    _loadArticles();
  }

  Future<void> _loadArticles({
    bool refresh = false,
  }) async {
    if (refresh) {
      setState(() {
        _refreshing = true;
      });
    } else {
      setState(() {
        _loading = true;
      });
    }

    try {
      final feeds = await _repository.watchFeeds().first;

      final results = <_RssArticleWithFeed>[];

      for (final feed in feeds) {
        try {
          final articles = await _service.fetchFeed(
            feed.url,
          );

          for (final article in articles) {
            results.add(
              _RssArticleWithFeed(
                article: article,
                feedName: feed.name,
              ),
            );
          }
        } catch (_) {
          // One broken feed should not prevent
          // the other feeds from loading.
        }
      }

      results.sort((a, b) {
        final aDate = a.article.publishedAt;
        final bDate = b.article.publishedAt;

        if (aDate == null && bDate == null) {
          return 0;
        }

        if (aDate == null) {
          return 1;
        }

        if (bDate == null) {
          return -1;
        }

        return bDate.compareTo(aDate);
      });

      if (!mounted) return;

      setState(() {
        _articles = results;
        _loading = false;
        _refreshing = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _refreshing = false;
      });
    }
  }

  Future<void> _refresh() {
    return _loadArticles(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const RssArticleSkeleton();
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _refresh,
          child: _articles.isEmpty
              ? ListView(
                  physics:
                      const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height:
                          MediaQuery.sizeOf(context).height *
                              0.35,
                    ),
                    Center(
                      child: Text(
                        'No articles yet',
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                )
              : RssArticleList(
                  articles: _articles
                      .map((item) => item.article)
                      .toList(),
                  feedNames: {
                    for (final item in _articles)
                      item.article.url: item.feedName,
                  },
                ),
        ),
        if (_refreshing)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              minHeight: 2,
            ),
          ),
      ],
    );
  }
}

class _RssArticleWithFeed {
  final ParsedRssArticle article;
  final String feedName;

  const _RssArticleWithFeed({
    required this.article,
    required this.feedName,
  });
}
