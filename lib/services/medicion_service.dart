// lib/services/medicion_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class MedicionService {
  static const String _baseUrl =
      'https://servidorappseremi-production.up.railway.app';

  final AuthService _authService = AuthService();

  Future<bool> crearMedicion({
    required String tipoMedicion,
    required List<String> horas,
    DateTime? fecha,
    String? instrucciones,
    String? urlFoto,
  }) async {
    final token = await _authService.getToken();
    if (token == null) return false;

    try {
      final body = <String, dynamic>{
        'tipo': tipoMedicion,
        'horas': horas,
      };

      if (fecha != null) {
        body['fecha_inicio'] =
            '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';
      }
      if (instrucciones != null && instrucciones.trim().isNotEmpty) {
        body['instrucciones'] = instrucciones;
      }
      if (urlFoto != null) {
        body['url_foto'] = urlFoto;
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
