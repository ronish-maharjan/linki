import 'dart:async';

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

  StreamSubscription<RssFeedResult>? _feedSubscription;
  Timer? _publishTimer;

  List<_RssArticleWithFeed> _articles = [];

  bool _loading = true;
  bool _refreshing = false;

  int _loadGeneration = 0;

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
    // Do not start another refresh while one is already running.
    if (refresh && _refreshing) {
      return;
    }

    final generation = ++_loadGeneration;

    await _feedSubscription?.cancel();
    _feedSubscription = null;

    _publishTimer?.cancel();
    _publishTimer = null;

    if (!mounted) {
      return;
    }

    setState(() {
      if (refresh) {
        _refreshing = true;
      } else {
        _loading = true;
      }
    });

    try {
      final feeds = await _repository.watchFeeds().first;

      if (!mounted || generation != _loadGeneration) {
        return;
      }

      final results = <_RssArticleWithFeed>[];

      void sortResults() {
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
      }

      void publishResults({
        bool immediate = false,
      }) {
        if (!mounted ||
            generation != _loadGeneration) {
          return;
        }

        if (immediate) {
          _publishTimer?.cancel();
          _publishTimer = null;
        } else {
          if (_publishTimer?.isActive ?? false) {
            return;
          }

          _publishTimer = Timer(
            const Duration(milliseconds: 75),
            () {
              _publishTimer = null;
              publishResults(immediate: true);
            },
          );

          return;
        }

        sortResults();

        setState(() {
          _articles =
              List<_RssArticleWithFeed>.from(results);

          _loading = false;
        });
      }

      if (feeds.isEmpty) {
        setState(() {
          _articles = [];
          _loading = false;
          _refreshing = false;
        });

        return;
      }

      final completed = Completer<void>();

      _feedSubscription = _service
          .fetchFeedsStream(
            feeds.map((feed) => feed.url).toList(),
            concurrency: 8,
          )
          .listen(
        (result) {
          if (!mounted ||
              generation != _loadGeneration) {
            return;
          }

          final feed = feeds.firstWhere(
            (feed) => feed.url == result.url,
          );

          for (final article in result.articles) {
            results.add(
              _RssArticleWithFeed(
                article: article,
                feedName: feed.name,
              ),
            );
          }

          publishResults();
        },
        onDone: () {
          _publishTimer?.cancel();
          _publishTimer = null;

          if (mounted &&
              generation == _loadGeneration) {
            sortResults();

            setState(() {
              _articles =
                  List<_RssArticleWithFeed>.from(
                results,
              );

              _loading = false;
              _refreshing = false;
            });
          }

          _feedSubscription = null;

          if (!completed.isCompleted) {
            completed.complete();
          }
        },
        onError: (_, __) {
          _publishTimer?.cancel();
          _publishTimer = null;

          if (mounted &&
              generation == _loadGeneration) {
            sortResults();

            setState(() {
              _articles =
                  List<_RssArticleWithFeed>.from(
                results,
              );

              _loading = false;
              _refreshing = false;
            });
          }

          _feedSubscription = null;

          if (!completed.isCompleted) {
            completed.complete();
          }
        },
      );

      // IMPORTANT:
      // Keep _loadArticles alive until all feed workers
      // have actually finished.
      await completed.future;
    } catch (_) {
      if (!mounted ||
          generation != _loadGeneration) {
        return;
      }

      setState(() {
        _loading = false;
        _refreshing = false;
      });
    }
  }

  Future<void> _refresh() async {
    if (_refreshing) {
      return;
    }

    await _loadArticles(refresh: true);
  }

  @override
  void dispose() {
    _loadGeneration++;

    _publishTimer?.cancel();
    _feedSubscription?.cancel();

    super.dispose();
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
                          MediaQuery.sizeOf(context)
                              .height *
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
