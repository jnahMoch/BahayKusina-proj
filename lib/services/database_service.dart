import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'bahay_kusina.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE meals (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            type TEXT,
            vendor TEXT,
            desc TEXT,
            price INTEGER,
            left INTEGER,
            imageUrl TEXT
          )
        ''');
      },
    );
  }

  // CRUD Example
  static Future<int> insertMeal(Map<String, dynamic> meal) async {
    final db = await database;
    return await db.insert('meals', meal);
  }

  static Future<List<Map<String, dynamic>>> getMeals() async {
    final db = await database;
    return await db.query('meals');
  }

  static Future<int> updateMeal(int id, Map<String, dynamic> meal) async {
    final db = await database;
    return await db.update('meals', meal, where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> deleteMeal(int id) async {
    final db = await database;
    return await db.delete('meals', where: 'id = ?', whereArgs: [id]);
  }
}
