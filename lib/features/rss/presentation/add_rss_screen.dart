import 'package:flutter/material.dart';

import '../data/rss_client.dart';
import '../data/rss_parser.dart';

class AddRssScreen extends StatefulWidget {
  const AddRssScreen({super.key});

  @override
  State<AddRssScreen> createState() => _AddRssScreenState();
}

class _AddRssScreenState extends State<AddRssScreen> {
  final _urlController = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _addFeed() async {
    final url = _urlController.text.trim();

    if (url.isEmpty) {
      _showError('Enter an RSS feed URL');
      return;
    }

    Uri? uri;

    try {
      uri = Uri.parse(url);
    } catch (_) {
      _showError('Enter a valid URL');
      return;
    }

    if (!uri.hasScheme ||
        (uri.scheme != 'http' && uri.scheme != 'https')) {
      _showError('URL must start with http:// or https://');
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final xml = await RssClient().fetch(url);

      final feed = RssParser().parse(xml);

      if (!mounted) return;

      Navigator.pop(
        context,
        AddRssResult(
          name: feed.title,
          url: url,
        ),
      );
    } catch (_) {
      if (!mounted) return;

      _showError(
        'Could not read this RSS feed',
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add RSS Feed'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'RSS URL',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _urlController,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.done,
                autocorrect: false,
                enableSuggestions: false,
                onSubmitted: (_) => _addFeed(),
                decoration: const InputDecoration(
                  hintText: 'https://example.com/rss',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _loading ? null : _addFeed,
                  child: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Add Feed'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddRssResult {
  final String name;
  final String url;

  const AddRssResult({
    required this.name,
    required this.url,
  });
}
