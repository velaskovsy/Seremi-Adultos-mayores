import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RecordatorioService {
  static const String _url = 'https://servidorappseremi-production.up.railway.app/api/recordatorios/hoy';
  static const String _tokenKey = 'auth_token';
  // NUEVA CLAVE: Para guardar los medicamentos en el teléfono
  static const String _localMedicamentosKey = 'local_medicamentos_hoy';

  Future<List<Map<String, dynamic>>> obtenerSoloMedicamentos() async {
    // 1. Intentamos descargar los datos frescos del servidor
    Map<String, dynamic>? data = await obtenerHoy();

    final prefs = await SharedPreferences.getInstance();

    if (data != null && data['franjas'] != null) {
      // SI HUBO INTERNET: Guardamos una copia de respaldo en el teléfono
      await prefs.setString(_localMedicamentosKey, jsonEncode(data));
    } else {
      // NO HUBO INTERNET (Celular bloqueado): Leemos la copia guardada previamente
      print("Sin internet o celular bloqueado. Intentando leer respaldo local...");
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

  Future<Map<String, dynamic>?> obtenerHoy() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);

      if (token == null) {
        print('No hay token guardado');
        return null;
      }

      final response = await http.get(
        Uri.parse(_url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 5)); // Timeout corto para que no se quede pegado si no hay red

      print('STATUS CODE: ${response.statusCode}');

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
      print('ERROR obtenerHoy (Es normal si está bloqueado): $e');
      return null; // Retorna null para que el método de arriba use el respaldo local
    }
  }
}