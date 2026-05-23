// lib/services/activity_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ActivityService {
  static const String _baseUrl =
      'https://servidorappseremi-production.up.railway.app';

  final AuthService _authService = AuthService();

  /// Crea uno o varios recordatorios de actividad en Railway.
  /// Usa POST /api/recordatorios/actividad
  ///
  /// [tipoActividad]  : nombre de la actividad, ej. "Hidratarse" (requerido)
  /// [horas]          : lista de horas en formato "HH:mm" (requerido)
  /// [fecha]          : null = recurrente diario, fecha = solo ese día
  /// [cantidadPorHora]: mapa de hora → cantidad, ej. {"08:00": "2 vasos"}
  Future<bool> crearActividad({
    required String tipoActividad,
    required List<String> horas,
    DateTime? fecha,
    Map<String, String>? cantidadPorHora,
  }) async {
    final token = await _authService.getToken();
    if (token == null) return false;

    try {
      final body = <String, dynamic>{
        'tipoActividad': tipoActividad,
        'horas': horas,
      };

      if (fecha != null) {
        body['fecha_inicio'] =
            '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';
      }

      if (cantidadPorHora != null && cantidadPorHora.isNotEmpty) {
        body['cantidadPorHora'] = cantidadPorHora;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/api/recordatorios/actividad'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      return response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }
}
