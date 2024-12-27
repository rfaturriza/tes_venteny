// ignore_for_file: depend_on_referenced_packages

import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

@singleton
class DatabaseProvider {
  static final DatabaseProvider databaseProvider = DatabaseProvider();
  late Database _db;

  Future<Database> get database async {
    _db = await _createDatabase();

    return _db;
  }

  Future<Database> _createDatabase() async {
    final String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'database.db');
    return await openDatabase(path, version: 1, onCreate: _initDB);
  }

  void _initDB(Database database, int version) async {
    await database.execute('''
        CREATE TABLE todos (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title VARCHAR(50),
          description TEXT NULL,
          due_date TEXT,
          status VARCHAR(20) DEFAULT 'pending'
        );
      ''');

    await database.execute('''
        CREATE TABLE outboxes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          action VARCHAR(20),
          table_name VARCHAR(20),
          payload TEXT,
          created_at TEXT
        );
      ''');
  }
}
