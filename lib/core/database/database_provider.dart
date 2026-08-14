import 'app_database.dart';

class DatabaseProvider {
  static AppDatabase? _database;

  static Future<AppDatabase> get instance async {
    if (_database != null) {
      return _database!;
    }

    _database = await openDatabase();

    return _database!;
  }
}
