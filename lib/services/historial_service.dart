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

    final ahora = DateTime.now().toIso8601String();
    final payload = <String, dynamic>{
      'id_recordatorio': idRecordatorio,
      'nombre':          nombre,
      'hora_programada': horaProgramada,
      'estado':          estado,
    };

    // Guardar en SQLite siempre (inmediato)
    final idLocal = await _db.insertarHistorial({
      'rut_usuario':     rut,
      'id_recordatorio': idRecordatorio,
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
          // Marcar como sincronizado
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

    // Encolar para sincronizar después
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

    final ahora = DateTime.now().toIso8601String();
    final payload = <String, dynamic>{
      'id_recordatorio': idRecordatorio,
      'nombre':          nombre,
      'hora_programada': horaProgramada,
      'valor_presion':   valorPresion,
      'estado':          estado,
    };

    // Calcular nivel localmente (misma lógica que el backend)
    final nivel = _calcularNivelPresion(valorPresion);

    final idLocal = await _db.insertarHistorial({
      'rut_usuario':     rut,
      'id_recordatorio': idRecordatorio,
      'tipo':            'medicion',
      'nombre':          nombre,
      'hora_programada': horaProgramada,
      'estado':          estado,
      'valor_presion':   valorPresion,
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
        valorPresion:   '',
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
