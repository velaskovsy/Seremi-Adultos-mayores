import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/recordatorio.dart';

class DBHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'recordatorios.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE recordatorios (
            id INTEGER PRIMARY KEY,
            titulo TEXT,
            fechaHora TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertarRecordatorio(Recordatorio rec) async {
    final db = await database;
    await db.insert('recordatorios', rec.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Recordatorio>> obtenerRecordatorios() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('recordatorios');
    return List.generate(maps.length, (i) => Recordatorio.fromMap(maps[i]));
  }
}