import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class RecordatorioItem {
  final int id;
  final String tipo;
  final String color;
  final String nombre;
  final String? detalle;
  final String hora;

  const RecordatorioItem({
    required this.id,
    required this.tipo,
    required this.color,
    required this.nombre,
    this.detalle,
    required this.hora,
  });

  factory RecordatorioItem.fromJson(Map<String, dynamic> json) {
    return RecordatorioItem(
      id:      json['id']     as int,
      tipo:    json['tipo']   as String,
      color:   json['color']  as String,
      nombre:  json['nombre'] as String,
      detalle: json['detalle'] as String?,
      hora:    json['hora']   as String,
    );
  }
}

class RecordatoriosHoy {
  final String? proximaTarea;
  final List<RecordatorioItem> manana;
  final List<RecordatorioItem> tarde;
  final List<RecordatorioItem> noche;

  const RecordatoriosHoy({
    this.proximaTarea,
    required this.manana,
    required this.tarde,
    required this.noche,
  });
}

class RecordatorioService {
  static const String _baseUrl =
      'https://servidorappseremi-production.up.railway.app';

  final AuthService _authService = AuthService();

  Future<RecordatoriosHoy?> obtenerHoy() async {
    final token = await _authService.getToken();
    if (token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/recordatorios/hoy'),
        headers: {
          'Content-Type':  'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data    = jsonDecode(response.body) as Map<String, dynamic>;
        final franjas = data['franjas']           as Map<String, dynamic>;

        List<RecordatorioItem> parsear(String franja) {
          final lista = franjas[franja] as List<dynamic>? ?? [];
          return lista
              .map((e) => RecordatorioItem.fromJson(e as Map<String, dynamic>))
              .toList();
        }

        return RecordatoriosHoy(
          proximaTarea: data['proxima_tarea'] as String?,
          manana:       parsear('manana'),
          tarde:        parsear('tarde'),
          noche:        parsear('noche'),
        );
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}