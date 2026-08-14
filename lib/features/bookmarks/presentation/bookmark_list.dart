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

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: items.length,
          separatorBuilder: (_, _) => const Divider(
            height: 1,
          ),
          itemBuilder: (context, index) {
            final bookmark = items[index];

            return BookmarkTile(
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
    return ListTile(
      onTap: _open,
      title: Text(
        bookmark.title.isEmpty
            ? bookmark.url
            : bookmark.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        bookmark.url,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        tooltip: 'More',
        icon: const Icon(Icons.more_vert),
        onPressed: () => _showMenu(context),
      ),
    );
  }
}
