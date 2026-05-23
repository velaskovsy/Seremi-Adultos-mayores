import 'package:flutter/foundation.dart'; // 1. IMPORTANTE: Para usar kIsWeb
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart'; // 2. IMPORTANTE: Soporte para Web

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  // Obtener DB
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('app.db');
    return _database!;
  }

  // Inicializar DB
  Future<Database> _initDB(String filePath) async {
    // === CAMBIO AQUÍ ===
    if (kIsWeb) {
      // Si es web, inicializamos la fábrica para el navegador
      databaseFactory = databaseFactoryFfiWeb;

      // En Web no existen las rutas de carpetas tradicionales,
      // pasamos directamente el nombre del archivo.
      return await openDatabase(
        filePath,
        version: 1,
        onCreate: _createDB,
      );
    } else {
      // Si es Android o iOS, corre tu código original tal cual
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);

      return await openDatabase(
        path,
        version: 1,
        onCreate: _createDB,
      );
    }
    // ===================
  }

  // Crear tablas
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE alarma (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT,
        dosis TEXT,
        hora TEXT,
        fecha TEXT,
        intervalo TEXT,
        instrucciones TEXT,
        pathFotoCaja TEXT,
        pathFotoRemedio TEXT,
        activo INTEGER,
        tipo INTEGER
      )
    ''');
  }

  // Cerrar DB
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}