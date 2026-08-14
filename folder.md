linki/
│
├── .github/
│   └── workflows/
│       └── android.yml
│
├── android/
├── ios/
│
├── lib/
│   │
│   ├── main.dart
│   │
│   ├── app/
│   │   ├── app.dart
│   │   ├── router.dart
│   │   └── theme.dart
│   │
│   ├── core/
│   │   │
│   │   ├── database/
│   │   │   ├── app_database.dart
│   │   │   ├── tables/
│   │   │   │   ├── feeds_table.dart
│   │   │   │   ├── articles_table.dart
│   │   │   │   └── bookmarks_table.dart
│   │   │   └── migrations.dart
│   │   │
│   │   ├── network/
│   │   │   └── http_client.dart
│   │   │
│   │   ├── browser/
│   │   │   └── external_browser.dart
│   │   │
│   │   └── errors/
│   │       └── app_exception.dart
│   │
│   ├── features/
│   │   │
│   │   ├── home/
│   │   │   ├── presentation/
│   │   │   │   ├── home_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── home_tab_bar.dart
│   │   │   │       ├── article_list.dart
│   │   │   │       └── article_tile.dart
│   │   │   └── controllers/
│   │   │       └── home_controller.dart
│   │   │
│   │   ├── feeds/
│   │   │   ├── data/
│   │   │   │   ├── feed_repository.dart
│   │   │   │   └── rss_service.dart
│   │   │   │
│   │   │   ├── domain/
│   │   │   │   └── feed.dart
│   │   │   │
│   │   │   └── presentation/
│   │   │       ├── add_feed_screen.dart
│   │   │       └── feed_settings_screen.dart
│   │   │
│   │   ├── bookmarks/
│   │   │   ├── data/
│   │   │   │   └── bookmark_repository.dart
│   │   │   │
│   │   │   ├── domain/
│   │   │   │   └── bookmark.dart
│   │   │   │
│   │   │   └── presentation/
│   │   │       └── add_bookmark_screen.dart
│   │   │
│   │   ├── articles/
│   │   │   ├── domain/
│   │   │   │   └── article.dart
│   │   │   │
│   │   │   └── data/
│   │   │       └── article_repository.dart
│   │   │
│   │   ├── settings/
│   │   │   └── presentation/
│   │   │       └── settings_screen.dart
│   │   │
│   │   └── migration/
│   │       ├── data/
│   │       │   ├── export_service.dart
│   │       │   └── import_service.dart
│   │       └── domain/
│   │           └── backup.dart
│   │
│   └── shared/
│       ├── widgets/
│       │   ├── empty_state.dart
│       │   ├── loading_indicator.dart
│       │   └── error_view.dart
│       │
│       └── utils/
│           └── date_formatter.dart
│
├── test/
│   ├── features/
│   │   ├── feeds/
│   │   ├── bookmarks/
│   │   └── migration/
│   │
│   └── core/
│
├── pubspec.yaml
├── analysis_options.yaml
├── README.md
├── CHANGELOG.md
└── LICENSE
