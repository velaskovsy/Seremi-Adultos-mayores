// lib/services/recordatorio_service.dart — offline-first
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../database/db_helper.dart';
import 'auth_service.dart';
import 'connectivity_service.dart';

class RecordatorioService {
  static const String _baseUrl =
      'https://servidorappseremi-production.up.railway.app';
  static const String _tokenKey = 'auth_token';
  // Cache de SharedPreferences mantenido por compatibilidad con código existente
  static const String _localMedicamentosKey = 'local_medicamentos_hoy';

  final DBHelper _db = DBHelper();
  final AuthService _authService = AuthService();
  final ConnectivityService _connectivity = ConnectivityService();

  // ── Helpers internos ─────────────────────────────────────────

  String _soloFecha(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  String _calcularFranja(String hora) {
    final h = int.tryParse(hora.split(':').first) ?? 0;
    if (h >= 6 && h < 12) return 'manana';
    if (h >= 12 && h < 20) return 'tarde';
    return 'noche';
  }

  Map<String, dynamic> _recordatorioAFranja(
      List<Map<String, dynamic>> lista) {
    final franjas = <String, List<Map<String, dynamic>>>{
      'manana': [],
      'tarde':  [],
      'noche':  [],
    };
    for (final r in lista) {
      final franja = _calcularFranja(r['hora_inicio'] as String? ?? '00:00');
      franjas[franja]!.add({
        'id':               r['id_railway'] ?? r['id_local'],
        'id_local':         r['id_local'],
        'tipo':             r['tipo'],
        'nombre':           r['nombre'],
        'detalle':          r['detalle'],
        'dosis':            r['dosis'],
        'intervalo':        r['intervalo'],
        'instrucciones':    r['instrucciones'],
        'hora':             r['hora_inicio'],
        'frecuencia':       r['frecuencia'],
        'url_foto_caja':    r['url_foto_caja'],
        'url_foto_remedio': r['url_foto_remedio'],
        'url_foto':         r['url_foto'],
        'vez':              r['vez'],
        'grupo_id':         r['grupo_id'],
        'sincronizado':     r['sincronizado'],
      });
    }
    return {'franjas': franjas};
  }

  // ── Obtener hoy ───────────────────────────────────────────────
  Future<Map<String, dynamic>?> obtenerHoy() async {
    final usuario = await _authService.getUsuario();
    final rut = usuario?['rut'] as String?;
    if (rut == null) return null;

    final online = await _connectivity.hayInternet();

    if (online) {
      // Intentar desde Railway
      final data = await _obtenerHoyOnline();
      if (data != null) {
        // Cachear en SharedPreferences (compatibilidad)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_localMedicamentosKey, jsonEncode(data));
        return data;
      }
    }

    // Fallback: SQLite local
    final lista = await _db.getRecordatoriosHoy(rut);
    return _recordatorioAFranja(lista);
  }

  Future<Map<String, dynamic>?> _obtenerHoyOnline() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$_baseUrl/api/recordatorios/hoy'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type':  'application/json',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'proxima_tarea': data['proxima_tarea'],
          'franjas': {
            'manana': List<Map<String, dynamic>>.from(
                (data['franjas']['manana'] ?? []).map((e) => Map<String, dynamic>.from(e))),
            'tarde': List<Map<String, dynamic>>.from(
                (data['franjas']['tarde'] ?? []).map((e) => Map<String, dynamic>.from(e))),
            'noche': List<Map<String, dynamic>>.from(
                (data['franjas']['noche'] ?? []).map((e) => Map<String, dynamic>.from(e))),
          },
        };
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // ── Obtener día específico ────────────────────────────────────
  Future<Map<String, dynamic>?> obtenerDia(DateTime fecha) async {
    final usuario = await _authService.getUsuario();
    final rut = usuario?['rut'] as String?;
    if (rut == null) return null;

    final online = await _connectivity.hayInternet();
    final fechaStr = _soloFecha(fecha);

    if (online) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString(_tokenKey);
        if (token != null) {
          final response = await http.get(
            Uri.parse('$_baseUrl/api/recordatorios/dia?fecha=$fechaStr'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type':  'application/json',
            },
          ).timeout(const Duration(seconds: 5));

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            return {
              'proxima_tarea': data['proxima_tarea'],
              'franjas': {
                'manana': List<Map<String, dynamic>>.from(
                    (data['franjas']['manana'] ?? []).map((e) => Map<String, dynamic>.from(e))),
                'tarde': List<Map<String, dynamic>>.from(
                    (data['franjas']['tarde'] ?? []).map((e) => Map<String, dynamic>.from(e))),
                'noche': List<Map<String, dynamic>>.from(
                    (data['franjas']['noche'] ?? []).map((e) => Map<String, dynamic>.from(e))),
              },
            };
          }
        }
      } catch (_) {}
    }

    // Fallback local
    final lista = await _db.getRecordatoriosDia(rut, fechaStr);
    return _recordatorioAFranja(lista);
  }

  // ── Días con eventos ─────────────────────────────────────────
  Future<List<String>> obtenerDiasConEventos(
      DateTime desde, DateTime hasta) async {
    final online = await _connectivity.hayInternet();

    if (online) {
      try {
        final prefs  = await SharedPreferences.getInstance();
        final token  = prefs.getString(_tokenKey);
        if (token == null) return [];

        String fmt(DateTime d) => _soloFecha(d);
        final url = Uri.parse(
          '$_baseUrl/api/recordatorios/dias-con-eventos'
          '?desde=${fmt(desde)}&hasta=${fmt(hasta)}',
        );
        final response = await http.get(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type':  'application/json',
          },
        ).timeout(const Duration(seconds: 8));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return List<String>.from(data['dias'] ?? []);
        }
      } catch (_) {}
    }

    // Fallback: calcular localmente desde SQLite
    final usuario = await _authService.getUsuario();
    final rut = usuario?['rut'] as String?;
    if (rut == null) return [];

    final Set<String> dias = {};
    var cursor = desde;
    while (!cursor.isAfter(hasta)) {
      final fechaStr = _soloFecha(cursor);
      final lista = await _db.getRecordatoriosDia(rut, fechaStr);
      if (lista.isNotEmpty) dias.add(fechaStr);
      cursor = cursor.add(const Duration(days: 1));
    }
    return dias.toList();
  }

  // ── Filtros por tipo (compatibilidad con código existente) ────

  Future<List<Map<String, dynamic>>> obtenerSoloMedicamentos() async {
    final data = await obtenerHoy();
    return _filtrarPorTipo(data, 'medicamento');
  }

  Future<List<Map<String, dynamic>>> obtenerSoloMediciones() async {
    final data = await obtenerHoy();
    return _filtrarPorTipo(data, 'medicion');
  }

  Future<List<Map<String, dynamic>>> obtenerSoloActividades() async {
    final data = await obtenerHoy();
    return _filtrarPorTipo(data, 'actividad');
  }

  Future<List<Map<String, dynamic>>> obtenerSoloCitas() async {
    final data = await obtenerHoy();
    return _filtrarPorTipo(data, 'cita');
  }

  List<Map<String, dynamic>> _filtrarPorTipo(
      Map<String, dynamic>? data, String tipo) {
    if (data == null || data['franjas'] == null) return [];
    final franjas = data['franjas'] as Map<String, dynamic>;
    final result  = <Map<String, dynamic>>[];
    for (final franja in ['manana', 'tarde', 'noche']) {
      final tareas = (franjas[franja] as List<dynamic>? ?? []);
      for (final t in tareas) {
        if (t['tipo'] == tipo) {
          result.add(Map<String, dynamic>.from(t as Map));
        }
      }
    }
    return result;
  }
}
