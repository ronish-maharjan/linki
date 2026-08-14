import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';

class RssFeedList extends StatelessWidget {
  final Stream<List<RssFeed>> feeds;
  final Future<void> Function(RssFeed feed) onEdit;
  final Future<void> Function(RssFeed feed) onDelete;

  const RssFeedList({
    super.key,
    required this.feeds,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<RssFeed>>(
      stream: feeds,
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final items = snapshot.data ?? [];

        if (items.isEmpty) {
          return Center(
            child: Text(
              'No RSS feeds yet',
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(
            12,
            12,
            12,
            24,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final feed = items[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.fromLTRB(
                    16,
                    6,
                    6,
                    6,
                  ),
                  title: Text(
                    feed.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    feed.url,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    tooltip: 'More',
                    icon: const Icon(
                      Icons.more_vert,
                    ),
                    onPressed: () {
                      _showMenu(context, feed);
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showMenu(
    BuildContext context,
    RssFeed feed,
  ) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.edit_outlined,
                ),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  onEdit(feed);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                ),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  onDelete(feed);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
