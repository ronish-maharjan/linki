import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class Bookmarks extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get title => text()();

  TextColumn get url => text()();

  DateTimeColumn get createdAt => dateTime()();
}

@DriftDatabase(
  tables: [
    Bookmarks,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;
}

Future<AppDatabase> openDatabase() async {
  final directory = await getApplicationDocumentsDirectory();

  final file = File(
    p.join(
      directory.path,
      'linki.sqlite',
    ),
  );

  return AppDatabase(
    NativeDatabase.createInBackground(file),
  );
}
