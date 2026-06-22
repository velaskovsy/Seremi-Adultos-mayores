// lib/services/historial_service.dart — offline-first
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../database/db_helper.dart';
import 'auth_service.dart';
import 'connectivity_service.dart';

class HistorialItem {
  final int idHistorial;
  final int? idRecordatorio;
  final String tipo;
  final String nombre;
  final String? horaProgramada;
  final String estado;
  final String? valorPresion;
  final String? nivelPresion;
  final DateTime fechaHora;

  HistorialItem({
    required this.idHistorial,
    this.idRecordatorio,
    required this.tipo,
    required this.nombre,
    this.horaProgramada,
    required this.estado,
    this.valorPresion,
    this.nivelPresion,
    required this.fechaHora,
  });

  factory HistorialItem.fromJson(Map<String, dynamic> json) {
    return HistorialItem(
      idHistorial:    json['id_historial'] as int,
      idRecordatorio: json['id_recordatorio'] as int?,
      tipo:           json['tipo'] as String,
      nombre:         json['nombre'] as String,
      horaProgramada: json['hora_programada'] as String?,
      estado:         json['estado'] as String,
      valorPresion:   json['valor_presion'] as String?,
      nivelPresion:   json['nivel_presion'] as String?,
      fechaHora:      DateTime.parse(json['fecha_hora'] as String).toLocal(),
    );
  }

  factory HistorialItem.fromDb(Map<String, dynamic> row) {
    return HistorialItem(
      idHistorial:    row['id_local'] as int,
      idRecordatorio: row['id_recordatorio'] as int?,
      tipo:           row['tipo'] as String,
      nombre:         row['nombre'] as String,
      horaProgramada: row['hora_programada'] as String?,
      estado:         row['estado'] as String,
      valorPresion:   row['valor_presion'] as String?,
      nivelPresion:   row['nivel_presion'] as String?,
      fechaHora:      DateTime.parse(row['fecha_hora'] as String).toLocal(),
    );
  }
}

class HistorialService {
  static const String _baseUrl =
      'https://servidorappseremi-production.up.railway.app';

  final DBHelper _db = DBHelper();
  final AuthService _authService = AuthService();
  final ConnectivityService _connectivity = ConnectivityService();

  // ── Resuelve el id_railway real de un recordatorio ────────────
  // El viewmodel pasa 'id' que puede ser id_railway o id_local
  // (cuando el recordatorio fue creado offline y aún no se sincronizó).
  // Esta función retorna el id_railway real, o null si aún no está en Railway.
  // Así evitamos mandar un id_local al servidor, que causa FK violation.
  Future<int?> _resolverIdRailway(int? idRecordatorio) async {
    if (idRecordatorio == null) return null;

    final db = await _db.database;

    // Primero intentar: ¿existe un recordatorio con id_railway = idRecordatorio?
    // (esto ocurre cuando el recordatorio ya está sincronizado y 'id' es su id_railway)
    final porRailway = await db.query(
      'recordatorios',
      columns: ['id_railway'],
      where: 'id_railway = ?',
      whereArgs: [idRecordatorio],
      limit: 1,
    );
    if (porRailway.isNotEmpty) {
      return porRailway.first['id_railway'] as int?;
    }

    // Si no, buscar por id_local (recordatorio creado offline, 'id' es el id_local)
    final porLocal = await db.query(
      'recordatorios',
      columns: ['id_railway'],
      where: 'id_local = ?',
      whereArgs: [idRecordatorio],
      limit: 1,
    );
    if (porLocal.isNotEmpty) {
      // Puede ser null si aún no se sincronizó con Railway
      return porLocal.first['id_railway'] as int?;
    }

    return null;
  }

  // ── Registrar medicamento tomado ──────────────────────────────
  Future<bool> registrarMedicamento({
    int? idRecordatorio,
    required String nombre,
    String? horaProgramada,
    String estado = 'tomado',
  }) async {
    final usuario = await _authService.getUsuario();
    final rut = usuario?['rut'] as String?;
    if (rut == null) return false;
    final token = await _authService.getToken();
    if (token == null) return false;

    // Resolver el id_railway real (null si el recordatorio aún no se sincronizó)
    final idRailway = await _resolverIdRailway(idRecordatorio);

    final ahora = DateTime.now().toIso8601String();
    final payload = <String, dynamic>{
      'id_recordatorio': idRailway, // null si el recordatorio aún no se sincronizó
      'nombre':          nombre,
      'hora_programada': horaProgramada,
      'estado':          estado,
      // Si id_railway es null pero tenemos el id_local del recordatorio,
      // lo guardamos para que sync_service lo resuelva al momento de subir
      if (idRailway == null && idRecordatorio != null)
        'id_recordatorio_local': idRecordatorio,
    };

    // Guardar en SQLite siempre (inmediato) — guardamos el id_local original
    final idLocal = await _db.insertarHistorial({
      'rut_usuario':     rut,
      'id_recordatorio': idRecordatorio, // guardamos el id_local en SQLite (solo local)
      'tipo':            'medicamento',
      'nombre':          nombre,
      'hora_programada': horaProgramada,
      'estado':          estado,
      'fecha_hora':      ahora,
      'sincronizado':    0,
    });

    final online = await _connectivity.hayInternet();
    if (online) {
      try {
        final res = await http.post(
          Uri.parse('$_baseUrl/api/historial/medicamento'),
          headers: {
            'Content-Type':  'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(payload),
        ).timeout(const Duration(seconds: 10));

        if (res.statusCode == 201) {
          final db = await _db.database;
          await db.update(
            'historial_cumplimiento',
            {'sincronizado': 1},
            where: 'id_local = ?',
            whereArgs: [idLocal],
          );
          return true;
        }
      } catch (_) {}
    }

    // Encolar para sincronizar después (payload ya tiene id_railway correcto o null)
    await _db.encolarOperacion(
      operacion:  'crear_historial_medicamento',
      payload:    payload,
      idLocalRef: idLocal,
    );
    return true;
  }

  // ── Registrar medición de presión ─────────────────────────────
  Future<bool> registrarMedicion({
    int? idRecordatorio,
    String nombre = 'Control de Presión',
    String? horaProgramada,
    required String valorPresion,
    String estado = 'tomado',
  }) async {
    final usuario = await _authService.getUsuario();
    final rut = usuario?['rut'] as String?;
    if (rut == null) return false;
    final token = await _authService.getToken();
    if (token == null) return false;

    // Resolver el id_railway real (null si el recordatorio aún no se sincronizó)
    final idRailway = await _resolverIdRailway(idRecordatorio);

    // Normalizar valor_presion: si es no_tomado, enviar null en lugar de ''
    final valorFinal = (estado == 'no_tomado' || valorPresion.isEmpty)
        ? null
        : valorPresion;

    final ahora = DateTime.now().toIso8601String();
    final payload = <String, dynamic>{
      'id_recordatorio': idRailway, // null si el recordatorio aún no se sincronizó
      'nombre':          nombre,
      'hora_programada': horaProgramada,
      'valor_presion':   valorFinal,
      'estado':          estado,
      // Si id_railway es null pero tenemos el id_local del recordatorio,
      // lo guardamos para que sync_service lo resuelva al momento de subir
      if (idRailway == null && idRecordatorio != null)
        'id_recordatorio_local': idRecordatorio,
    };

    // Calcular nivel localmente (misma lógica que el backend)
    final nivel = valorFinal != null ? _calcularNivelPresion(valorFinal) : null;

    final idLocal = await _db.insertarHistorial({
      'rut_usuario':     rut,
      'id_recordatorio': idRecordatorio, // guardamos el id_local en SQLite (solo local)
      'tipo':            'medicion',
      'nombre':          nombre,
      'hora_programada': horaProgramada,
      'estado':          estado,
      'valor_presion':   valorFinal,
      'nivel_presion':   nivel,
      'fecha_hora':      ahora,
      'sincronizado':    0,
    });

    final online = await _connectivity.hayInternet();
    if (online) {
      try {
        final res = await http.post(
          Uri.parse('$_baseUrl/api/historial/medicion'),
          headers: {
            'Content-Type':  'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(payload),
        ).timeout(const Duration(seconds: 10));

        if (res.statusCode == 201) {
          final db = await _db.database;
          await db.update(
            'historial_cumplimiento',
            {'sincronizado': 1},
            where: 'id_local = ?',
            whereArgs: [idLocal],
          );
          return true;
        }
      } catch (_) {}
    }

    await _db.encolarOperacion(
      operacion:  'crear_historial_medicion',
      payload:    payload,
      idLocalRef: idLocal,
    );
    return true;
  }

  // ── Registrar no atendido ─────────────────────────────────────
  Future<bool> registrarNoAtendido({
    int? idRecordatorio,
    required String tipo,
    required String nombre,
    String? horaProgramada,
  }) async {
    if (tipo == 'medicion') {
      return await registrarMedicion(
        idRecordatorio: idRecordatorio,
        nombre:         nombre,
        horaProgramada: horaProgramada,
        valorPresion:   '',   // se normaliza a null dentro de registrarMedicion
        estado:         'no_tomado',
      );
    } else {
      return await registrarMedicamento(
        idRecordatorio: idRecordatorio,
        nombre:         nombre,
        horaProgramada: horaProgramada,
        estado:         'no_tomado',
      );
    }
  }

  // ── Obtener historial ─────────────────────────────────────────
  Future<List<HistorialItem>> obtenerHistorial({
    DateTime? desde,
    DateTime? hasta,
    String? tipo,
  }) async {
    final usuario = await _authService.getUsuario();
    final rut = usuario?['rut'] as String?;
    if (rut == null) return [];

    String? desdeStr, hastaStr;
    if (desde != null) {
      desdeStr =
          '${desde.year}-${desde.month.toString().padLeft(2, '0')}-${desde.day.toString().padLeft(2, '0')}';
    }
    if (hasta != null) {
      hastaStr =
          '${hasta.year}-${hasta.month.toString().padLeft(2, '0')}-${hasta.day.toString().padLeft(2, '0')}';
    }

    final online = await _connectivity.hayInternet();

    if (online) {
      try {
        final token = await _authService.getToken();
        if (token == null) return [];

        final params = <String, String>{};
        if (desdeStr != null) params['desde'] = desdeStr;
        if (hastaStr != null) params['hasta'] = hastaStr;
        if (tipo != null)     params['tipo']  = tipo;

        final uri = Uri.parse('$_baseUrl/api/historial')
            .replace(queryParameters: params);

        final res = await http.get(
          uri,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type':  'application/json',
          },
        ).timeout(const Duration(seconds: 10));

        if (res.statusCode == 200) {
          final data  = jsonDecode(res.body) as Map<String, dynamic>;
          final lista = (data['historial'] as List<dynamic>? ?? []);
          return lista
              .map((e) => HistorialItem.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      } catch (_) {}
    }

    // Fallback: leer de SQLite local
    final rows = await _db.getHistorial(
      rut,
      desde: desdeStr,
      hasta: hastaStr,
      tipo:  tipo,
    );
    return rows.map((r) => HistorialItem.fromDb(r)).toList();
  }

  // ── Calcular nivel de presión localmente ──────────────────────
  // Misma lógica que el backend para consistencia offline
  String? _calcularNivelPresion(String valor) {
    if (valor.isEmpty) return null;
    try {
      final partes    = valor.split('/');
      final sistolica = int.parse(partes[0].trim());
      final diastolica = int.parse(partes[1].trim());

      if (sistolica >= 180 || diastolica >= 120) return 'critico';
      if (sistolica >= 140 || diastolica >= 90)  return 'elevado';
      return 'normal';
    } catch (_) {
      return null;
    }
  }
}