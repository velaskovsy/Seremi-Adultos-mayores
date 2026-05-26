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
}