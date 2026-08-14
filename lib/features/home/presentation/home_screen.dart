import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../bookmarks/data/bookmark_repository.dart';
import '../../bookmarks/presentation/add_bookmark_screen.dart';
import '../../bookmarks/presentation/bookmark_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _dragStartX = 0;
  double _dragStartY = 0;
  int _selectedTab = 0;

  BookmarkRepository? _bookmarkRepository;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    final database = await DatabaseProvider.instance;

    if (!mounted) return;

    setState(() {
      _bookmarkRepository = BookmarkRepository(database);
    });
  }

  Widget _buildCurrentPage() {
    if (_selectedTab == 0) {
      return const _EmptyPage(
        message: 'No articles yet',
      );
    }
  
    if (_bookmarkRepository == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
  
    return BookmarkList(
      bookmarks: _bookmarkRepository!.watchBookmarks(),
      onEdit: _editBookmark,
      onDelete: _deleteBookmark,
    );
  }

  void _handleHorizontalSwipe(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
  
    if (velocity.abs() < 600) {
      return;
    }
  
    if (velocity < 0 && _selectedTab == 0) {
      _selectTab(1);
      return;
    }
  
    if (velocity > 0 && _selectedTab == 1) {
      _selectTab(0);
    }
  }
  void _selectTab(int index) {
    if (_selectedTab == index) return;
  
    setState(() {
      _selectedTab = index;
    });
  }

  void _onPageChanged(int index) {
    if (_selectedTab == index) return;

    setState(() {
      _selectedTab = index;
    });
  }

  void _showAddMenu() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Add',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _AddOption(
                  icon: Icons.bookmark_outline,
                  title: 'Bookmark',
                  subtitle: 'Save a URL',
                  onTap: () async {
                    Navigator.pop(context);

                    final result = await Navigator.pushNamed(
                      context,
                      '/add-bookmark',
                    );

                    if (result is BookmarkFormData &&
                        _bookmarkRepository != null) {
                      await _bookmarkRepository!.addBookmark(
                        title: result.title,
                        url: result.url,
                      );
                    }
                  },
                ),
                _AddOption(
                  icon: Icons.rss_feed,
                  title: 'RSS Feed',
                  subtitle: 'Follow a website',
                  onTap: () {
                    Navigator.pop(context);
                    _showComingSoon('Add RSS Feed');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature will be added next.'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _editBookmark(Bookmark bookmark) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddBookmarkScreen(
          bookmark: bookmark,
        ),
      ),
    );

    if (result is BookmarkFormData &&
        result.id != null &&
        _bookmarkRepository != null) {
      await _bookmarkRepository!.updateBookmark(
        id: result.id!,
        title: result.title,
        url: result.url,
      );
    }
  }

  Future<void> _deleteBookmark(Bookmark bookmark) async {
    if (_bookmarkRepository == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete bookmark?'),
          content: Text(
            bookmark.title.isEmpty
                ? bookmark.url
                : bookmark.title,
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
      await _bookmarkRepository!.deleteBookmark(
        bookmark.id,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleSpacing: 0,
        title: _TabBar(
          selectedIndex: _selectedTab,
          onSelected: _selectTab,
        ),
        actions: [
          IconButton(
            tooltip: 'Add',
            onPressed: _showAddMenu,
            icon: const Icon(Icons.add),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: GestureDetector(
        onHorizontalDragEnd: _handleHorizontalSwipe,
        child: _buildCurrentPage(),
      ),

    );
  }
}

class _TabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _TabBar({
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _TabButton(
          label: 'RSS',
          selected: selectedIndex == 0,
          onTap: () => onSelected(0),
        ),
        const SizedBox(width: 24),
        _TabButton(
          label: 'BOOKMARKS',
          selected: selectedIndex == 1,
          onTap: () => onSelected(1),
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? Theme.of(context).colorScheme.onSurface
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 14,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: selected
                    ? FontWeight.w600
                    : FontWeight.w400,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 5),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              height: 2,
              width: selected ? 20 : 0,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AddOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 2,
      ),
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }
}

class _EmptyPage extends StatelessWidget {
  final String message;

  const _EmptyPage({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 15,
        ),
      ),
    );
  }
}
