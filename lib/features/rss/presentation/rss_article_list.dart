import 'package:flutter/material.dart';

import '../data/rss_parser.dart';
import '../../../core/browser/external_browser.dart';

class RssArticleList extends StatelessWidget {
  final List<ParsedRssArticle> articles;
  final Map<String, String> feedNames;

  const RssArticleList({
    super.key,
    required this.articles,
    required this.feedNames,
  });

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) {
      return Center(
        child: Text(
          'No articles yet',
          style: TextStyle(
            color: Theme.of(context)
                .colorScheme
                .onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        24,
      ),
      itemCount: articles.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: Theme.of(context)
            .colorScheme
            .outlineVariant,
      ),
      itemBuilder: (context, index) {
        final article = articles[index];

        return _ArticleTile(
          article: article,
          feedName: _findFeedName(article),
        );
      },
    );
  }

  String? _findFeedName(
    ParsedRssArticle article,
  ) {
    // Feed name mapping will be connected
    // when the RSS home screen is wired.
    return null;
  }
}

class _ArticleTile extends StatelessWidget {
  final ParsedRssArticle article;
  final String? feedName;

  const _ArticleTile({
    required this.article,
    required this.feedName,
  });

  Future<void> _openArticle() async {
    await ExternalBrowser().open(article.url);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: _openArticle,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 14,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              article.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                if (feedName != null) ...[
                  Flexible(
                    child: Text(
                      feedName!,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme
                            .onSurfaceVariant,
                      ),
                    ),
                  ),
                  Text(
                    ' · ',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme
                          .onSurfaceVariant,
                    ),
                  ),
                ],
                Expanded(
                  child: Text(
                    _domain(article.url),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme
                          .onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _relativeTime(
                    article.publishedAt,
                  ),
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme
                        .onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _domain(String url) {
    try {
      final uri = Uri.parse(url);

      return uri.host.isEmpty
          ? url
          : uri.host.replaceFirst(
              'www.',
              '',
            );
    } catch (_) {
      return url;
    }
  }

  String _relativeTime(DateTime? date) {
    if (date == null) {
      return '';
    }

    final difference =
        DateTime.now().difference(date);

    if (difference.isNegative) {
      return 'now';
    }

    if (difference.inMinutes < 1) {
      return 'now';
    }

    if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    }

    if (difference.inDays < 1) {
      return '${difference.inHours}h';
    }

    if (difference.inDays < 7) {
      return '${difference.inDays}d';
    }

    return '${date.day}/${date.month}';
  }
}
