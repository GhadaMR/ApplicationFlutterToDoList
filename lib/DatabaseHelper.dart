import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'todolist.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE tasks(
            id INTEGER PRIMARY KEY,
            userId TEXT,
            task TEXT,
            dateTime TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertTask(Map<String, dynamic> task) async {
    Database db = await database;
    return await db.insert('tasks', {
      'userId': task['userId'],
      'task': task['task'],
      'dateTime': task['dateTime'],
    });
  }

  Future<List<Map<String, dynamic>>> retrieveTasks(String userId) async {
    Database db = await database;
    return await db.query('tasks', where: 'userId = ?', whereArgs: [userId]);
  }

  Future<int> updateTask(Map<String, dynamic> task) async {
    Database db = await database;
    return await db.update('tasks', task,
        where: 'id = ?', whereArgs: [task['id']]);
  }

  Future<int> deleteTask(String id) async {
    Database db = await database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}
