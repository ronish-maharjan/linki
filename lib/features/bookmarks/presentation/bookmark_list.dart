import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../../../core/browser/external_browser.dart';

class BookmarkList extends StatelessWidget {
  final Stream<List<Bookmark>> bookmarks;
  final Future<void> Function(Bookmark bookmark) onEdit;
  final Future<void> Function(Bookmark bookmark) onDelete;

  const BookmarkList({
    super.key,
    required this.bookmarks,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Bookmark>>(
      stream: bookmarks,
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
              'No bookmarks yet',
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
              ),
            ),
          );
        }

        return ListView.separated(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            16,
            8,
            8,
            24,
          ),
          itemCount: items.length,
          separatorBuilder: (_, __) {
            return Divider(
              height: 1,
              color: Theme.of(context)
                  .colorScheme
                  .outlineVariant,
            );
          },
          itemBuilder: (context, index) {
            final bookmark = items[index];

            return _BookmarkTile(
              bookmark: bookmark,
              onEdit: () => onEdit(bookmark),
              onDelete: () => onDelete(bookmark),
            );
          },
        );
      },
    );
  }
}

class _BookmarkTile extends StatelessWidget {
  final Bookmark bookmark;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BookmarkTile({
    required this.bookmark,
    required this.onEdit,
    required this.onDelete,
  });

  Future<void> _openBookmark() async {
    await ExternalBrowser().open(bookmark.url);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: _openBookmark,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 14,
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    bookmark.title.isEmpty
                        ? bookmark.url
                        : bookmark.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _domain(bookmark.url),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme
                          .onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              tooltip: 'More',
              visualDensity:
                  VisualDensity.compact,
              icon: const Icon(
                Icons.more_vert,
                size: 20,
              ),
              onPressed: () {
                _showMenu(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
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
                  onEdit();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                ),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  onDelete();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _domain(String url) {
    try {
      final uri = Uri.parse(url);

      if (uri.host.isEmpty) {
        return url;
      }

      return uri.host.replaceFirst(
        'www.',
        '',
      );
    } catch (_) {
      return url;
    }
  }
}
