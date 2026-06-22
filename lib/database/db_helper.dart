// lib/database/db_helper.dart
//
// Base de datos SQLite local — offline-first
// ignore_for_file: depend_on_referenced_packages
// Tablas:
//   sesion_usuario        → datos del usuario logueado (para login offline)
//   recordatorios         → copia local de todos los recordatorios
//   historial_cumplimiento→ copia local del historial
//   cola_sincronizacion   → operaciones pendientes de subir a Railway
//
// NUNCA llames a este archivo directamente desde las Views.
// Usa siempre los Services, que deciden si van a SQLite o a Railway.

import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'seremi_offline.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // ── Sesión del usuario (para login offline) ──────────────────
    await db.execute('''
      CREATE TABLE sesion_usuario (
        rut           TEXT PRIMARY KEY,
        nombre        TEXT NOT NULL,
        pin_hash      TEXT NOT NULL,
        token         TEXT NOT NULL,
        id_cuidador   INTEGER,
        guardado_en   TEXT NOT NULL
      )
    ''');

    // ── Recordatorios (espejo local de Railway) ──────────────────
    // id_local: solo se usa cuando aún no tiene id de Railway (offline)
    // id_railway: el id_recordatorio que asignó Railway (NULL si pendiente)
    // sincronizado: 0 = pendiente subir, 1 = ya está en Railway
    await db.execute('''
      CREATE TABLE recordatorios (
        id_local      INTEGER PRIMARY KEY AUTOINCREMENT,
        id_railway    INTEGER,
        rut_usuario   TEXT    NOT NULL,
        tipo          TEXT    NOT NULL,
        nombre        TEXT    NOT NULL,
        detalle       TEXT,
        dosis         TEXT,
        intervalo     TEXT,
        instrucciones TEXT,
        hora_inicio   TEXT    NOT NULL,
        frecuencia    TEXT    NOT NULL DEFAULT "diaria",
        fecha_unica   TEXT,
        activo        INTEGER NOT NULL DEFAULT 1,
        vez           INTEGER,
        grupo_id      TEXT,
        url_foto_caja    TEXT,
        url_foto_remedio TEXT,
        url_foto         TEXT,
        sincronizado  INTEGER NOT NULL DEFAULT 0,
        creado_en     TEXT    NOT NULL
      )
    ''');

    // ── Historial de cumplimiento ────────────────────────────────
    await db.execute('''
      CREATE TABLE historial_cumplimiento (
        id_local         INTEGER PRIMARY KEY AUTOINCREMENT,
        id_railway       INTEGER,
        rut_usuario      TEXT NOT NULL,
        id_recordatorio  INTEGER,
        tipo             TEXT NOT NULL,
        nombre           TEXT NOT NULL,
        hora_programada  TEXT,
        estado           TEXT NOT NULL,
        valor_presion    TEXT,
        nivel_presion    TEXT,
        fecha_hora       TEXT NOT NULL,
        sincronizado     INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // ── Cola de sincronización ───────────────────────────────────
    // operacion: "crear_recordatorio" | "editar_recordatorio" |
    //            "eliminar_recordatorio" | "crear_historial"
    // estado: "pendiente" | "error"
    // intentos: cuántas veces falló (para no reintentar infinito)
    await db.execute('''
      CREATE TABLE cola_sincronizacion (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        operacion     TEXT    NOT NULL,
        payload       TEXT    NOT NULL,
        id_local_ref  INTEGER,
        estado        TEXT    NOT NULL DEFAULT "pendiente",
        intentos      INTEGER NOT NULL DEFAULT 0,
        creado_en     TEXT    NOT NULL
      )
    ''');

    // Índices para performance
    await db.execute('CREATE INDEX idx_rec_rut ON recordatorios(rut_usuario)');
    await db.execute('CREATE INDEX idx_rec_activo ON recordatorios(activo)');
    await db.execute('CREATE INDEX idx_hist_rut ON historial_cumplimiento(rut_usuario)');
    await db.execute('CREATE INDEX idx_cola_estado ON cola_sincronizacion(estado)');
  }

  // ══════════════════════════════════════════════════════════════
  // SESIÓN DE USUARIO
  // ══════════════════════════════════════════════════════════════

  /// Guarda o actualiza la sesión del usuario logueado.
  /// Llamado cada vez que el login es exitoso CON internet.
  Future<void> guardarSesion({
    required String rut,
    required String nombre,
    required String pinHash,
    required String token,
    int? idCuidador,
  }) async {
    final db = await database;
    await db.insert(
      'sesion_usuario',
      {
        'rut':         rut,
        'nombre':      nombre,
        'pin_hash':    pinHash,
        'token':       token,
        'id_cuidador': idCuidador,
        'guardado_en': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Obtiene la sesión guardada localmente (puede ser null si nunca se logueó).
  Future<Map<String, dynamic>?> getSesion() async {
    final db = await database;
    final rows = await db.query('sesion_usuario', limit: 1);
    return rows.isEmpty ? null : rows.first;
  }

  /// Elimina la sesión local (logout).
  Future<void> eliminarSesion() async {
    final db = await database;
    await db.delete('sesion_usuario');
  }

  // ══════════════════════════════════════════════════════════════
  // RECORDATORIOS
  // ══════════════════════════════════════════════════════════════

  /// Inserta un recordatorio local (creado offline o descargado de Railway).
  /// Si ya existe con ese id_railway, lo actualiza.
  Future<int> insertarRecordatorio(Map<String, dynamic> rec) async {
    final db = await database;

    // Si viene con id_railway, verificar si ya existe
    if (rec['id_railway'] != null) {
      final existing = await db.query(
        'recordatorios',
        where: 'id_railway = ?',
        whereArgs: [rec['id_railway']],
        limit: 1,
      );
      if (existing.isNotEmpty) {
        await db.update(
          'recordatorios',
          rec,
          where: 'id_railway = ?',
          whereArgs: [rec['id_railway']],
        );
        return existing.first['id_local'] as int;
      }
    }

    return await db.insert(
      'recordatorios',
      rec,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Obtiene los recordatorios activos de un usuario.
  Future<List<Map<String, dynamic>>> getRecordatorios(String rut) async {
    final db = await database;
    return await db.query(
      'recordatorios',
      where: 'rut_usuario = ? AND activo = 1',
      whereArgs: [rut],
      orderBy: 'hora_inicio ASC',
    );
  }

  /// Obtiene recordatorios de hoy (diarios + únicos de hoy + semanales del día).
  Future<List<Map<String, dynamic>>> getRecordatoriosHoy(String rut) async {
    final db = await database;
    final hoy = _soloFecha(DateTime.now());
    final dowHoy = DateTime.now().weekday % 7; // 0=domingo .. 6=sabado

    final todos = await db.query(
      'recordatorios',
      where: 'rut_usuario = ? AND activo = 1',
      whereArgs: [rut],
      orderBy: 'hora_inicio ASC',
    );

    return todos.where((r) {
      final freq = r['frecuencia'] as String;
      if (freq == 'diaria') return true;
      if (freq == 'unica') return r['fecha_unica'] == hoy;
      if (freq == 'semanal') {
        // Comparar día de la semana con el día en que fue creado
        if (r['creado_en'] != null) {
          final creadoEn = DateTime.parse(r['creado_en'] as String);
          return creadoEn.weekday % 7 == dowHoy;
        }
      }
      return false;
    }).toList();
  }

  /// Obtiene recordatorios de una fecha específica.
  Future<List<Map<String, dynamic>>> getRecordatoriosDia(
      String rut, String fecha) async {
    final db = await database;
    final fechaDt = DateTime.parse(fecha);
    final dow = fechaDt.weekday % 7;

    final todos = await db.query(
      'recordatorios',
      where: 'rut_usuario = ? AND activo = 1',
      whereArgs: [rut],
      orderBy: 'hora_inicio ASC',
    );

    return todos.where((r) {
      final freq = r['frecuencia'] as String;
      if (freq == 'diaria') return true;
      if (freq == 'unica') return r['fecha_unica'] == fecha;
      if (freq == 'semanal') {
        if (r['creado_en'] != null) {
          final creadoEn = DateTime.parse(r['creado_en'] as String);
          return creadoEn.weekday % 7 == dow;
        }
      }
      return false;
    }).toList();
  }

  /// Actualiza un recordatorio local por id_local.
  Future<void> actualizarRecordatorio(
      int idLocal, Map<String, dynamic> datos) async {
    final db = await database;
    await db.update(
      'recordatorios',
      datos,
      where: 'id_local = ?',
      whereArgs: [idLocal],
    );
  }

  /// Marca un recordatorio como inactivo (soft delete).
  Future<void> eliminarRecordatorio(int idLocal) async {
    final db = await database;
    await db.update(
      'recordatorios',
      {'activo': 0},
      where: 'id_local = ?',
      whereArgs: [idLocal],
    );
  }

  /// Marca un recordatorio como sincronizado y le asigna el id de Railway.
  Future<void> marcarRecordatorioSincronizado(
      int idLocal, int idRailway) async {
    final db = await database;
    await db.update(
      'recordatorios',
      {'sincronizado': 1, 'id_railway': idRailway},
      where: 'id_local = ?',
      whereArgs: [idLocal],
    );
  }

  /// Devuelve el id_local de un recordatorio dado su id_railway.
  Future<int?> getIdLocalPorRailway(int idRailway) async {
    final db = await database;
    final rows = await db.query(
      'recordatorios',
      columns: ['id_local'],
      where: 'id_railway = ?',
      whereArgs: [idRailway],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first['id_local'] as int;
  }

  /// Reemplaza todos los recordatorios de un usuario con la data de Railway.
  /// Se usa en el pull (Railway → local).
  Future<void> reemplazarRecordatoriosDesdeRailway(
      String rut, List<Map<String, dynamic>> lista) async {
    final db = await database;

    await db.transaction((txn) async {
      // Borrar los que ya están sincronizados (los pendientes NO se tocan)
      await txn.delete(
        'recordatorios',
        where: 'rut_usuario = ? AND sincronizado = 1',
        whereArgs: [rut],
      );

      // Insertar los de Railway
      for (final rec in lista) {
        await txn.insert(
          'recordatorios',
          rec,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  // ══════════════════════════════════════════════════════════════
  // HISTORIAL
  // ══════════════════════════════════════════════════════════════

  Future<int> insertarHistorial(Map<String, dynamic> item) async {
    final db = await database;
    return await db.insert(
      'historial_cumplimiento',
      item,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getHistorial(
    String rut, {
    String? desde,
    String? hasta,
    String? tipo,
  }) async {
    final db = await database;
    final wheres = ['rut_usuario = ?'];
    final args = <dynamic>[rut];

    if (desde != null) {
      wheres.add('fecha_hora >= ?');
      args.add(desde);
    }
    if (hasta != null) {
      wheres.add('fecha_hora <= ?');
      args.add('${hasta}T23:59:59');
    }
    if (tipo != null) {
      wheres.add('tipo = ?');
      args.add(tipo);
    }

    return await db.query(
      'historial_cumplimiento',
      where: wheres.join(' AND '),
      whereArgs: args,
      orderBy: 'fecha_hora DESC',
    );
  }

  Future<void> reemplazarHistorialDesdeRailway(
      String rut, List<Map<String, dynamic>> lista) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(
        'historial_cumplimiento',
        where: 'rut_usuario = ? AND sincronizado = 1',
        whereArgs: [rut],
      );
      for (final item in lista) {
        await txn.insert(
          'historial_cumplimiento',
          item,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  // ══════════════════════════════════════════════════════════════
  // COLA DE SINCRONIZACIÓN
  // ══════════════════════════════════════════════════════════════

  /// Agrega una operación a la cola.
  Future<void> encolarOperacion({
    required String operacion,
    required Map<String, dynamic> payload,
    int? idLocalRef,
  }) async {
    final db = await database;
    await db.insert('cola_sincronizacion', {
      'operacion':    operacion,
      'payload':      _encodePayload(payload),
      'id_local_ref': idLocalRef,
      'estado':       'pendiente',
      'intentos':     0,
      'creado_en':    DateTime.now().toIso8601String(),
    });
  }

  /// Obtiene todas las operaciones pendientes, en orden de creación.
  Future<List<Map<String, dynamic>>> getColaPendiente() async {
    final db = await database;
    return await db.query(
      'cola_sincronizacion',
      where: 'estado = ? AND intentos < 5',
      whereArgs: ['pendiente'],
      orderBy: 'id ASC',
    );
  }

  /// Marca una operación como procesada (la elimina de la cola).
  Future<void> eliminarDeCola(int id) async {
    final db = await database;
    await db.delete(
      'cola_sincronizacion',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Incrementa el contador de intentos fallidos.
  Future<void> marcarIntentoFallido(int id) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE cola_sincronizacion SET intentos = intentos + 1 WHERE id = ?',
      [id],
    );
  }

  /// Cuántas operaciones quedan pendientes (útil para mostrar badge en UI).
  Future<int> contarPendientes() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as cnt FROM cola_sincronizacion WHERE estado = "pendiente" AND intentos < 5',
    );
    return (result.first['cnt'] as int?) ?? 0;
  }

  // ══════════════════════════════════════════════════════════════
  // UTILIDADES PRIVADAS
  // ══════════════════════════════════════════════════════════════

  String _soloFecha(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  String _encodePayload(Map<String, dynamic> payload) => jsonEncode(payload);
}
