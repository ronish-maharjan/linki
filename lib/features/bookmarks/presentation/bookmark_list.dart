import 'package:flutter/material.dart';

import '../../../core/browser/external_browser.dart';
import '../../../core/database/app_database.dart';

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
        if (snapshot.connectionState == ConnectionState.waiting) {
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

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(
            12,
            12,
            12,
            24,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final bookmark = items[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: BookmarkTile(
                bookmark: bookmark,
                onEdit: () => onEdit(bookmark),
                onDelete: () => onDelete(bookmark),
              ),
            );
          },
        );
      },
    );
  }
}

class BookmarkTile extends StatelessWidget {
  final Bookmark bookmark;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BookmarkTile({
    super.key,
    required this.bookmark,
    required this.onEdit,
    required this.onDelete,
  });

  Future<void> _open() async {
    await ExternalBrowser().open(bookmark.url);
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
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  onEdit();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _open,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            14,
            6,
            14,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                      bookmark.url,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                tooltip: 'More',
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showMenu(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
