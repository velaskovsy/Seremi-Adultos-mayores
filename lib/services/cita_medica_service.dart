// lib/services/cita_medica_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class CitaMedicaService {
  static const String _baseUrl =
      'https://servidorappseremi-production.up.railway.app';

  final AuthService _authService = AuthService();

  /// Crea una cita médica en Railway.
  /// POST /api/recordatorios/cita
  Future<bool> crearCita({
    required DateTime fecha,
    required String hora,        // "HH:mm"
    required String lugar,
    required String profesional,
    String? notas,
  }) async {
    final token = await _authService.getToken();
    if (token == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/recordatorios/cita'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'fecha': '${fecha.year}-'
              '${fecha.month.toString().padLeft(2, '0')}-'
              '${fecha.day.toString().padLeft(2, '0')}',
          'hora': hora,
          'lugar': lugar,
          'profesional': profesional,
          if (notas != null && notas.trim().isNotEmpty) 'notas': notas.trim(),
        }),
      );
      return response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  /// Edita una cita médica existente.
  /// PUT /api/recordatorios/:id
  Future<bool> editarCita({
    required int id,
    required String hora,
    required String lugar,
    required String profesional,
    String? notas,
    DateTime? fecha,
  }) async {
    final token = await _authService.getToken();
    if (token == null) return false;

    try {
      final body = <String, dynamic>{
        'hora': hora,
        'lugar': lugar,
        'profesional': profesional,
      };
      if (notas != null && notas.trim().isNotEmpty) {
        body['notas'] = notas.trim();
      }
      if (fecha != null) {
        body['fecha'] =
            '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';
      }

      final response = await http.put(
        Uri.parse('$_baseUrl/api/recordatorios/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Elimina (desactiva) una cita médica.
  /// DELETE /api/recordatorios/:id
  Future<bool> eliminarCita(int id) async {
    final token = await _authService.getToken();
    if (token == null) return false;

    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/recordatorios/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}