import 'package:flutter/material.dart';

import '../features/bookmarks/presentation/add_bookmark_screen.dart';
import '../features/home/presentation/home_screen.dart';

abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/add-bookmark':
        return MaterialPageRoute(
          builder: (_) => const AddBookmarkScreen(),
        );

      case '/':
      default:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );
    }
  }
}
