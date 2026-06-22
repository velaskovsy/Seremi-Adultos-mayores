// lib/services/sync_service.dart
//
// Sincronización bidireccional entre SQLite local y Railway.
//
// SUBIDA (local → Railway): procesa la cola_sincronizacion en orden.
// BAJADA (Railway → local): descarga recordatorios e historial actualizados.
//
// Se activa:
//   1. Automáticamente cuando el teléfono recupera internet (via ConnectivityService stream)
//   2. Manualmente al abrir la app con internet
//   3. Llamándolo directamente desde cualquier Service

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../database/db_helper.dart';
import 'auth_service.dart';
import 'connectivity_service.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  static const String _baseUrl =
      'https://servidorappseremi-production.up.railway.app';

  final DBHelper _db = DBHelper();
  final AuthService _authService = AuthService();
  final ConnectivityService _connectivity = ConnectivityService();

  bool _sincronizando = false;
  StreamSubscription<bool>? _connectivitySub;

  // ── Iniciar escucha automática ────────────────────────────────
  // Llamar desde main.dart una sola vez.
  void iniciarEscucha() {
    _connectivitySub?.cancel();
    _connectivitySub = _connectivity.onConnectivityChanged.listen((online) {
      if (online) {
        sincronizar();
      }
    });
  }

  void detenerEscucha() {
    _connectivitySub?.cancel();
    _connectivitySub = null;
  }

  // ── Sincronización completa ───────────────────────────────────
  Future<void> sincronizar() async {
    if (_sincronizando) return; // evitar ejecuciones paralelas
    _sincronizando = true;

    try {
      final online = await _connectivity.hayInternet();
      if (!online) return;

      final token = await _authService.getToken();
      if (token == null) return;

      final usuario = await _authService.getUsuario();
      if (usuario == null) return;
      final rut = usuario['rut'] as String;

      // 1. Primero subir lo que está en la cola (local → Railway)
      await _procesarCola(token);

      // 2. Luego bajar lo nuevo de Railway (Railway → local)
      await _pullDesdeRailway(token, rut);
    } catch (e) {
      print('❌ SyncService.sincronizar error: $e');
    } finally {
      _sincronizando = false;
    }
  }

  // ══════════════════════════════════════════════════════════════
  // SUBIDA: Cola → Railway
  // ══════════════════════════════════════════════════════════════

  Future<void> _procesarCola(String token) async {
    final pendientes = await _db.getColaPendiente();

    for (final item in pendientes) {
      final id        = item['id'] as int;
      final operacion = item['operacion'] as String;
      final payload   = jsonDecode(item['payload'] as String) as Map<String, dynamic>;
      final idLocalRef = item['id_local_ref'] as int?;

      try {
        final exito = await _ejecutarOperacion(
          operacion:   operacion,
          payload:     payload,
          idLocalRef:  idLocalRef,
          token:       token,
        );

        if (exito) {
          await _db.eliminarDeCola(id);
        } else {
          await _db.marcarIntentoFallido(id);
        }
      } catch (e) {
        print('❌ SyncService._procesarCola error en operacion $operacion: $e');
        await _db.marcarIntentoFallido(id);
      }
    }
  }

  Future<bool> _ejecutarOperacion({
    required String operacion,
    required Map<String, dynamic> payload,
    required int? idLocalRef,
    required String token,
  }) async {
    final headers = {
      'Content-Type':  'application/json',
      'Authorization': 'Bearer $token',
    };

    switch (operacion) {

      // ── Crear recordatorio ──────────────────────────────────
      case 'crear_medicamento':
        final res = await http.post(
          Uri.parse('$_baseUrl/api/recordatorios/medicamento'),
          headers: headers,
          body: jsonEncode(payload),
        ).timeout(const Duration(seconds: 10));

        if (res.statusCode == 201 && idLocalRef != null) {
          final data = jsonDecode(res.body);
          // El backend devuelve los ids creados
          final ids = data['ids'] as List<dynamic>?;
          if (ids != null && ids.isNotEmpty) {
            await _db.marcarRecordatorioSincronizado(
                idLocalRef, ids.first as int);
          }
        }
        return res.statusCode == 201;

      case 'crear_medicion':
        final res = await http.post(
          Uri.parse('$_baseUrl/api/recordatorios/medicion'),
          headers: headers,
          body: jsonEncode(payload),
        ).timeout(const Duration(seconds: 10));
        if (res.statusCode == 201 && idLocalRef != null) {
          final data = jsonDecode(res.body);
          final ids = data['ids'] as List<dynamic>?;
          if (ids != null && ids.isNotEmpty) {
            await _db.marcarRecordatorioSincronizado(
                idLocalRef, ids.first as int);
          }
        }
        return res.statusCode == 201;

      case 'crear_actividad':
        final res = await http.post(
          Uri.parse('$_baseUrl/api/recordatorios/actividad'),
          headers: headers,
          body: jsonEncode(payload),
        ).timeout(const Duration(seconds: 10));
        if (res.statusCode == 201 && idLocalRef != null) {
          final data = jsonDecode(res.body);
          final ids = data['ids'] as List<dynamic>?;
          if (ids != null && ids.isNotEmpty) {
            await _db.marcarRecordatorioSincronizado(
                idLocalRef, ids.first as int);
          }
        }
        return res.statusCode == 201;

      case 'crear_cita':
        final res = await http.post(
          Uri.parse('$_baseUrl/api/recordatorios/cita'),
          headers: headers,
          body: jsonEncode(payload),
        ).timeout(const Duration(seconds: 10));
        if (res.statusCode == 201 && idLocalRef != null) {
          final data = jsonDecode(res.body);
          final ids = data['ids'] as List<dynamic>?;
          if (ids != null && ids.isNotEmpty) {
            await _db.marcarRecordatorioSincronizado(
                idLocalRef, ids.first as int);
          }
        }
        return res.statusCode == 201;

      // ── Editar recordatorio ─────────────────────────────────
      case 'editar_recordatorio':
        final idRailway = payload['id_railway'];
        if (idRailway == null) return false;
        final body = Map<String, dynamic>.from(payload)
          ..remove('id_railway');
        final res = await http.put(
          Uri.parse('$_baseUrl/api/recordatorios/$idRailway'),
          headers: headers,
          body: jsonEncode(body),
        ).timeout(const Duration(seconds: 10));
        return res.statusCode == 200;

      // ── Eliminar recordatorio ───────────────────────────────
      case 'eliminar_recordatorio':
        final idRailway = payload['id_railway'];
        if (idRailway == null) return true; // nunca llegó a Railway, ok
        final res = await http.delete(
          Uri.parse('$_baseUrl/api/recordatorios/$idRailway'),
          headers: headers,
        ).timeout(const Duration(seconds: 10));
        return res.statusCode == 200;

      // ── Registrar historial ─────────────────────────────────
      case 'crear_historial_medicamento':
        final payloadMed = await _resolverIdRecordatorioEnPayload(payload);
        final res = await http.post(
          Uri.parse('$_baseUrl/api/historial/medicamento'),
          headers: headers,
          body: jsonEncode(payloadMed),
        ).timeout(const Duration(seconds: 10));
        return res.statusCode == 201;

      case 'crear_historial_medicion':
        final payloadMedicion = await _resolverIdRecordatorioEnPayload(payload);
        final res = await http.post(
          Uri.parse('$_baseUrl/api/historial/medicion'),
          headers: headers,
          body: jsonEncode(payloadMedicion),
        ).timeout(const Duration(seconds: 10));
        return res.statusCode == 201;

      default:
        print('⚠️ SyncService: operación desconocida "$operacion"');
        return true; // eliminar de cola para no atascar
    }
  }

  // ══════════════════════════════════════════════════════════════
  // BAJADA: Railway → SQLite local
  // ══════════════════════════════════════════════════════════════


  // ── Resuelve id_recordatorio en payload de historial ─────────
  // Si el payload tiene 'id_recordatorio_local', intenta obtener el
  // id_railway que ya le asignó Railway (el recordatorio debió subirse
  // antes en la misma pasada de _procesarCola).
  // Retorna el payload listo para enviar al servidor.
  Future<Map<String, dynamic>> _resolverIdRecordatorioEnPayload(
      Map<String, dynamic> payload) async {
    final idLocal = payload['id_recordatorio_local'] as int?;
    if (idLocal == null) return payload; // ya tiene id_railway o es null

    final db = await _db.database;
    final rows = await db.query(
      'recordatorios',
      columns: ['id_railway'],
      where: 'id_local = ?',
      whereArgs: [idLocal],
      limit: 1,
    );

    final idRailway = rows.isNotEmpty ? rows.first['id_railway'] as int? : null;

    // Construir payload final: reemplazar id_recordatorio con el railway real
    // y eliminar la clave auxiliar id_recordatorio_local
    return {
      ...payload,
      'id_recordatorio': idRailway,
    }..remove('id_recordatorio_local');
  }

  Future<void> _pullDesdeRailway(String token, String rut) async {
    await Future.wait([
      _pullRecordatorios(token, rut),
      _pullHistorial(token, rut),
    ]);
  }

  Future<void> _pullRecordatorios(String token, String rut) async {
    try {
      // Descargamos TODOS los recordatorios activos del usuario
      final res = await http.get(
        Uri.parse('$_baseUrl/api/recordatorios/todos'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type':  'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode != 200) return;

      final data  = jsonDecode(res.body) as Map<String, dynamic>;
      final lista = (data['recordatorios'] as List<dynamic>? ?? []);

      final locales = lista.map((e) {
        final r = e as Map<String, dynamic>;
        return {
          'id_railway':      r['id']           ?? r['id_recordatorio'],
          'rut_usuario':     rut,
          'tipo':            r['tipo'],
          'nombre':          r['nombre'],
          'detalle':         r['detalle'],
          'dosis':           r['dosis'],
          'intervalo':       r['intervalo'],
          'instrucciones':   r['instrucciones'],
          'hora_inicio':     r['hora'],
          'frecuencia':      r['frecuencia'] ?? 'diaria',
          'fecha_unica':     r['fecha_unica'],
          'activo':          (r['activo'] == true || r['activo'] == 1) ? 1 : 0,
          'vez':             r['vez'],
          'grupo_id':        r['grupo_id'],
          'url_foto_caja':   r['url_foto_caja'],
          'url_foto_remedio':r['url_foto_remedio'],
          'url_foto':        r['url_foto'],
          'sincronizado':    1,
          'creado_en':       r['created_at'] ?? DateTime.now().toIso8601String(),
        };
      }).toList();

      await _db.reemplazarRecordatoriosDesdeRailway(rut, locales);
    } catch (e) {
      print('❌ SyncService._pullRecordatorios error: $e');
    }
  }

  Future<void> _pullHistorial(String token, String rut) async {
    try {
      // Bajar el historial de los últimos 90 días
      final desde = DateTime.now().subtract(const Duration(days: 90));
      final desdeStr =
          '${desde.year}-${desde.month.toString().padLeft(2, '0')}-${desde.day.toString().padLeft(2, '0')}';

      final res = await http.get(
        Uri.parse('$_baseUrl/api/historial?desde=$desdeStr'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type':  'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode != 200) return;

      final data  = jsonDecode(res.body) as Map<String, dynamic>;
      final lista = (data['historial'] as List<dynamic>? ?? []);

      final locales = lista.map((e) {
        final h = e as Map<String, dynamic>;
        return {
          'id_railway':       h['id_historial'],
          'rut_usuario':      rut,
          'id_recordatorio':  h['id_recordatorio'],
          'tipo':             h['tipo'],
          'nombre':           h['nombre'],
          'hora_programada':  h['hora_programada'],
          'estado':           h['estado'],
          'valor_presion':    h['valor_presion'],
          'nivel_presion':    h['nivel_presion'],
          'fecha_hora':       h['fecha_hora'],
          'sincronizado':     1,
        };
      }).toList();

      await _db.reemplazarHistorialDesdeRailway(rut, locales);
    } catch (e) {
      print('❌ SyncService._pullHistorial error: $e');
    }
  }
}