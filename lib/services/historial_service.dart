// lib/services/historial_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

/// Un registro individual del historial (medicamento tomado o medición de presión)
class HistorialItem {
  final int idHistorial;
  final int? idRecordatorio;
  final String tipo; // 'medicamento' | 'medicion'
  final String nombre;
  final String? horaProgramada;
  final String estado; // 'tomado' | 'no_tomado'
  final String? valorPresion;
  final String? nivelPresion; // 'normal' | 'elevado' | 'critico'
  final DateTime fechaHora;

  HistorialItem({
    required this.idHistorial,
    this.idRecordatorio,
    required this.tipo,
    required this.nombre,
    this.horaProgramada,
    required this.estado,
    this.valorPresion,
    this.nivelPresion,
    required this.fechaHora,
  });

  factory HistorialItem.fromJson(Map<String, dynamic> json) {
    return HistorialItem(
      idHistorial:     json['id_historial'] as int,
      idRecordatorio:  json['id_recordatorio'] as int?,
      tipo:            json['tipo'] as String,
      nombre:          json['nombre'] as String,
      horaProgramada:  json['hora_programada'] as String?,
      estado:          json['estado'] as String,
      valorPresion:    json['valor_presion'] as String?,
      nivelPresion:    json['nivel_presion'] as String?,
      fechaHora:       DateTime.parse(json['fecha_hora'] as String).toLocal(),
    );
  }
}

/// Llama a los endpoints del backend para registrar y consultar
/// el historial de cumplimiento (medicamentos tomados, mediciones de presión).
class HistorialService {
  static const String _baseUrl = 'https://servidorappseremi-production.up.railway.app';

  final AuthService _authService = AuthService();

  /// Registra la confirmación de toma de un medicamento.
  /// Fire-and-forget: si falla, solo se loguea y no rompe el flujo del paciente.
  Future<bool> registrarMedicamento({
    int? idRecordatorio,
    required String nombre,
    String? horaProgramada,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$_baseUrl/api/historial/medicamento'),
        headers: {
          'Content-Type':  'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'id_recordatorio': idRecordatorio,
          'nombre':           nombre,
          'hora_programada':  horaProgramada,
        }),
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 201;
    } catch (e) {
      print('❌ HistorialService.registrarMedicamento excepción: $e');
      return false;
    }
  }

  /// Registra una medición de presión realizada. El nivel se calcula en el servidor.
  Future<bool> registrarMedicion({
    int? idRecordatorio,
    String nombre = 'Control de Presión',
    String? horaProgramada,
    required String valorPresion,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$_baseUrl/api/historial/medicion'),
        headers: {
          'Content-Type':  'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'id_recordatorio': idRecordatorio,
          'nombre':           nombre,
          'hora_programada':  horaProgramada,
          'valor_presion':    valorPresion,
        }),
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 201;
    } catch (e) {
      print('❌ HistorialService.registrarMedicion excepción: $e');
      return false;
    }
  }

  /// Obtiene el historial del usuario autenticado.
  /// [tipo] opcional: 'medicamento' o 'medicion' para filtrar.
  Future<List<HistorialItem>> obtenerHistorial({
    DateTime? desde,
    DateTime? hasta,
    String? tipo,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return [];

      String fmt(DateTime d) =>
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

      final params = <String, String>{};
      if (desde != null) params['desde'] = fmt(desde);
      if (hasta != null) params['hasta'] = fmt(hasta);
      if (tipo != null)  params['tipo']  = tipo;

      final uri = Uri.parse('$_baseUrl/api/historial').replace(queryParameters: params);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type':  'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final lista = (data['historial'] as List<dynamic>? ?? []);
        return lista
            .map((e) => HistorialItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print('❌ HistorialService.obtenerHistorial excepción: $e');
      return [];
    }
  }
}
