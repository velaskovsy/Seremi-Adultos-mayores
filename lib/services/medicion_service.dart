import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class MedicionService {
  static const String _baseUrl =
      'https://servidorappseremi-production.up.railway.app';

  final AuthService _authService = AuthService();

  /// Crea un recordatorio de medición en Railway.
  /// Usa POST /api/recordatorios/medicion
  ///
  /// [tipoMedicion]  : tipo de medición, ej. "Presión arterial" (requerido)
  /// [horas]         : lista de horas en formato "HH:mm" (requerido)
  /// [fecha]         : null = recurrente diario, fecha = solo ese día
  /// [instrucciones] : texto libre opcional
  Future<bool> crearMedicion({
    required String tipoMedicion,
    required List<String> horas,
    DateTime? fecha,
    String? instrucciones,
  }) async {
    final token = await _authService.getToken();
    if (token == null) return false;

    try {
      final body = <String, dynamic>{
        'tipo': tipoMedicion,
        'horas': horas, // lista de "HH:mm"
      };

      if (fecha != null) {
        body['fecha_inicio'] =
        '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';
      }

      if (instrucciones != null && instrucciones.trim().isNotEmpty) {
        body['instrucciones'] = instrucciones;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/api/recordatorios/medicion'),
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