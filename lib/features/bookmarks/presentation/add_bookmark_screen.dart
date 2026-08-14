import 'package:flutter/material.dart';
import '../../../core/database/app_database.dart';

class AddBookmarkScreen extends StatefulWidget {
  final Bookmark? bookmark;

  const AddBookmarkScreen({
    super.key,
    this.bookmark,
  });

  @override
  State<AddBookmarkScreen> createState() => _AddBookmarkScreenState();
}

class _AddBookmarkScreenState extends State<AddBookmarkScreen> {
  final _urlController = TextEditingController();
  final _titleController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    _titleController.dispose();
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
  
    final bookmark = widget.bookmark;
  
    if (bookmark != null) {
      _urlController.text = bookmark.url;
      _titleController.text = bookmark.title;
    }
  }
  void _save() {
    final url = _urlController.text.trim();

    if (url.isEmpty) {
      return;
    }

    Navigator.of(context).pop(
      BookmarkFormData(
        id: widget.bookmark?.id,
        title: _titleController.text.trim(),
        url: url,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.bookmark == null
              ? 'Add Bookmark'
              : 'Edit Bookmark',
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'URL',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _urlController,
                autofocus: true,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'https://example.com',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Title',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _save(),
                decoration: const InputDecoration(
                  hintText: 'Optional',
                  border: OutlineInputBorder(),
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _save,
                  child: Text(
                    widget.bookmark == null
                        ? 'Save'
                        : 'Update',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BookmarkFormData {
  final int? id;
  final String title;
  final String url;

  const BookmarkFormData({
    this.id,
    required this.title,
    required this.url,
  });
}
