import 'package:flutter/material.dart';

import 'router.dart';
import 'theme.dart';

class LinkiApp extends StatelessWidget {
  const LinkiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Linki',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
