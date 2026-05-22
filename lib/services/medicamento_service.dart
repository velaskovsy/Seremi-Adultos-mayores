// lib/services/medicamento_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class MedicamentoService {
  static const String _baseUrl =
      'https://servidorappseremi-production.up.railway.app';

  final AuthService _authService = AuthService();

  /// Crea un recordatorio de medicamento en Railway.
  /// Usa POST /api/recordatorios/medicamento
  ///
  /// [nombre]        : nombre del medicamento (requerido)
  /// [dosis]         : ej. "500mg" o "1 pastilla" (requerido)
  /// [hora]          : hora de primera toma en formato "HH:mm" (requerido)
  /// [fecha]         : null = recurrente diario, fecha = solo ese día
  /// [intervalo]     : texto del intervalo seleccionado, ej. "Cada 12 horas"
  /// [instrucciones] : texto libre opcional
  Future<bool> crearMedicamento({
    required String nombre,
    required String dosis,
    required String hora,
    DateTime? fecha,
    String? intervalo,
    String? instrucciones,
  }) async {
    final token = await _authService.getToken();
    if (token == null) return false;

    try {
      final body = <String, dynamic>{
        'nombre': nombre,
        'dosis': dosis,
        'hora_primera': hora, // formato "HH:mm"
      };

      // Si se eligió una fecha específica la mandamos (frecuencia = 'unica')
      // Si no, el servidor la trata como diaria
      if (fecha != null) {
        body['fecha_inicio'] =
            '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';
      }

      if (intervalo != null && intervalo.trim().isNotEmpty) {
        body['intervalo'] = intervalo;
      }

      if (instrucciones != null && instrucciones.trim().isNotEmpty) {
        body['instrucciones'] = instrucciones;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/api/recordatorios/medicamento'),
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
