import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RecordatorioService {
  static const String _url = 'https://servidorappseremi-production.up.railway.app/api/recordatorios/hoy';
  static const String _tokenKey = 'auth_token';
  static const String _localMedicamentosKey = 'local_medicamentos_hoy';

  // FILTRO 1: Obtiene solo los medicamentos (Tu lógica original)
  Future<List<Map<String, dynamic>>> obtenerSoloMedicamentos() async {
    Map<String, dynamic>? data = await obtenerHoy();
    final prefs = await SharedPreferences.getInstance();

    if (data != null && data['franjas'] != null) {
      await prefs.setString(_localMedicamentosKey, jsonEncode(data));
    } else {
      final String? localDataStr = prefs.getString(_localMedicamentosKey);
      if (localDataStr != null) {
        data = jsonDecode(localDataStr);
      }
    }

    if (data == null || data['franjas'] == null) return [];

    final franjas = data['franjas'] as Map<String, dynamic>;
    List<Map<String, dynamic>> medicamentosFiltrados = [];

    for (String franja in ['manana', 'tarde', 'noche']) {
      final List<dynamic> tareas = franjas[franja] ?? [];
      for (var tarea in tareas) {
        if (tarea['tipo'] == 'medicamento') {
          medicamentosFiltrados.add(Map<String, dynamic>.from(tarea));
        }
      }
    }
    return medicamentosFiltrados;
  }

  // NUEVO FILTRO 2: Obtiene solo los controles de Presión
  Future<List<Map<String, dynamic>>> obtenerSoloMediciones() async {
    Map<String, dynamic>? data = await obtenerHoy();
    final prefs = await SharedPreferences.getInstance();

    if (data != null && data['franjas'] != null) {
      await prefs.setString(_localMedicamentosKey, jsonEncode(data));
    } else {
      final String? localDataStr = prefs.getString(_localMedicamentosKey);
      if (localDataStr != null) {
        data = jsonDecode(localDataStr);
      }
    }

    if (data == null || data['franjas'] == null) return [];

    final franjas = data['franjas'] as Map<String, dynamic>;
    List<Map<String, dynamic>> medicionesFiltradas = [];

    for (String franja in ['manana', 'tarde', 'noche']) {
      final List<dynamic> tareas = franjas[franja] ?? [];
      for (var tarea in tareas) {
        // Guardamos únicamente si el tipo es una medición médica
        if (tarea['tipo'] == 'medicion') {
          medicionesFiltradas.add(Map<String, dynamic>.from(tarea));
        }
      }
    }
    return medicionesFiltradas;
  }

  // Obtiene los recordatorios de una fecha específica (YYYY-MM-DD)
  Future<Map<String, dynamic>?> obtenerDia(DateTime fecha) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      if (token == null) return null;

      final fechaStr =
          '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';

      final response = await http.get(
        Uri.parse('https://servidorappseremi-production.up.railway.app/api/recordatorios/dia?fecha=$fechaStr'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'proxima_tarea': data['proxima_tarea'],
          'franjas': {
            'manana': List<Map<String, dynamic>>.from(data['franjas']['manana'] ?? []),
            'tarde':  List<Map<String, dynamic>>.from(data['franjas']['tarde']  ?? []),
            'noche':  List<Map<String, dynamic>>.from(data['franjas']['noche']  ?? []),
          },
        };
      }
      return null;
    } catch (e) {
      print('ERROR en obtenerDia: $e');
      return null;
    }
  }

  // Retorna lista de fechas "YYYY-MM-DD" que tienen al menos un recordatorio
  Future<List<String>> obtenerDiasConEventos(DateTime desde, DateTime hasta) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      if (token == null) return [];

      String fmt(DateTime d) =>
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

      final url = Uri.parse(
        'https://servidorappseremi-production.up.railway.app/api/recordatorios/dias-con-eventos'
        '?desde=${fmt(desde)}&hasta=${fmt(hasta)}',
      );

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<String>.from(data['dias'] ?? []);
      }
      return [];
    } catch (e) {
      print('ERROR en obtenerDiasConEventos: $e');
      return [];
    }
  }

  // Descarga del JSON diario desde Railway
  Future<Map<String, dynamic>?> obtenerHoy() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);

      if (token == null) return null;

      final response = await http.get(
        Uri.parse(_url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'proxima_tarea': data['proxima_tarea'],
          'franjas': {
            'manana': List<Map<String, dynamic>>.from(data['franjas']['manana'] ?? []),
            'tarde': List<Map<String, dynamic>>.from(data['franjas']['tarde'] ?? []),
            'noche': List<Map<String, dynamic>>.from(data['franjas']['noche'] ?? []),
          }
        };
      }
      return null;
    } catch (e) {
      print('ERROR al conectar a Railway (modo offline activo): $e');
      return null;
    }
  }
}