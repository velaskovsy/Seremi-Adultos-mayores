// lib/services/medicamento_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class MedicamentoService {
  static const String _baseUrl =
      'https://servidorappseremi-production.up.railway.app';

  final AuthService _authService = AuthService();

  Future<bool> crearMedicamento({
    required String nombre,
    required String dosis,
    required String hora,
    required String grupoId,
    DateTime? fecha,
    String? intervalo,
    String? instrucciones,
    String? urlFotoCaja,
    String? urlFotoRemedio,
  }) async {
    final token = await _authService.getToken();
    if (token == null) return false;

    try {
      final body = <String, dynamic>{
        'nombre': nombre,
        'dosis': dosis,
        'hora_primera': hora,
        'grupo_id': grupoId,
      };

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
      if (urlFotoCaja != null) {
        body['url_foto_caja'] = urlFotoCaja;
      }
      if (urlFotoRemedio != null) {
        body['url_foto_remedio'] = urlFotoRemedio;
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

  /// Reemplaza todas las tomas futuras de un grupo de medicamento por una
  /// nueva toma (usado por el viewmodel en un bucle, igual que al crear).
  Future<bool> editarGrupoMedicamento({
    required String grupoId,
    required String nombre,
    required String dosis,
    required String hora,
    DateTime? fecha,
    String? intervalo,
    String? instrucciones,
    String? urlFotoCaja,
    String? urlFotoRemedio,
  }) async {
    final token = await _authService.getToken();
    if (token == null) return false;

    try {
      final body = <String, dynamic>{
        'nombre': nombre,
        'dosis': dosis,
        'hora_primera': hora,
      };

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
      if (urlFotoCaja != null) {
        body['url_foto_caja'] = urlFotoCaja;
      }
      if (urlFotoRemedio != null) {
        body['url_foto_remedio'] = urlFotoRemedio;
      }

      final response = await http.put(
        Uri.parse('$_baseUrl/api/recordatorios/grupo/$grupoId'),
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

  /// Elimina (desactiva) todas las tomas futuras de un grupo de medicamento.
  Future<bool> eliminarGrupoMedicamento(String grupoId) async {
    final token = await _authService.getToken();
    if (token == null) return false;

    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/recordatorios/grupo/$grupoId'),
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