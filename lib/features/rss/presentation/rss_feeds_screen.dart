import 'package:flutter/material.dart';

import '../data/rss_repository.dart';

class RssFeedsScreen extends StatelessWidget {
  final RssRepository repository;

  const RssFeedsScreen({
    super.key,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RSS Feeds'),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: repository.watchFeeds(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final feeds = snapshot.data ?? [];

          if (feeds.isEmpty) {
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

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              16,
              8,
              8,
              24,
            ),
            itemCount: feeds.length,
            separatorBuilder: (_, __) {
              return Divider(
                height: 1,
                color: Theme.of(context)
                    .colorScheme
                    .outlineVariant,
              );
            },
            itemBuilder: (context, index) {
              final feed = feeds[index];

              return _FeedTile(
                name: feed.name,
                url: feed.url,
                onEdit: () {
                  _editFeed(
                    context,
                    feed.id,
                    feed.name,
                    feed.url,
                  );
                },
                onDelete: () {
                  _deleteFeed(
                    context,
                    feed.id,
                    feed.name,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _editFeed(
    BuildContext context,
    int id,
    String name,
    String url,
  ) async {
    final result = await showDialog<RssFeedFormData>(
      context: context,
      builder: (_) {
        return _EditFeedDialog(
          name: name,
          url: url,
        );
      },
    );

    if (result == null) {
      return;
    }

    await repository.updateFeed(
      id: id,
      name: result.name,
      url: result.url,
    );
  }

  Future<void> _deleteFeed(
    BuildContext context,
    int id,
    String name,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete feed?'),
          content: Text(
            name.isEmpty
                ? 'This RSS feed will be removed.'
                : name,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await repository.deleteFeed(id);
    }
  }
}

class _FeedTile extends StatelessWidget {
  final String name;
  final String url;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _FeedTile({
    required this.name,
    required this.url,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
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
                  name.isEmpty ? url : name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  url,
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
}

class RssFeedFormData {
  final String name;
  final String url;

  const RssFeedFormData({
    required this.name,
    required this.url,
  });
}

class _EditFeedDialog extends StatefulWidget {
  final String name;
  final String url;

  const _EditFeedDialog({
    required this.name,
    required this.url,
  });

  @override
  State<_EditFeedDialog> createState() =>
      _EditFeedDialogState();
}

class _EditFeedDialogState
    extends State<_EditFeedDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _urlController;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.name,
    );

    _urlController = TextEditingController(
      text: widget.url,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    final url = _urlController.text.trim();

    if (url.isEmpty) {
      return;
    }

    Navigator.pop(
      context,
      RssFeedFormData(
        name: name,
        url: url,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Feed'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            textInputAction:
                TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Name',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _urlController,
            keyboardType:
                TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'RSS / Atom URL',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
