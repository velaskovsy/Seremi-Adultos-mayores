// lib/services/activity_service.dart — offline-first
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../database/db_helper.dart';
import 'auth_service.dart';
import 'connectivity_service.dart';

class ActivityService {
  static const String _baseUrl =
      'https://servidorappseremi-production.up.railway.app';

  final DBHelper _db = DBHelper();
  final AuthService _authService = AuthService();
  final ConnectivityService _connectivity = ConnectivityService();

  String _soloFecha(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  Future<bool> crearActividad({
    required String tipoActividad,
    required List<String> horas,
    DateTime? fecha,
    Map<String, String>? cantidadPorHora,
  }) async {
    final usuario = await _authService.getUsuario();
    final rut = usuario?['rut'] as String?;
    if (rut == null) return false;
    final token = await _authService.getToken();
    if (token == null) return false;

    final payload = <String, dynamic>{
      'tipoActividad': tipoActividad,
      'horas':         horas,
    };
    if (fecha != null) payload['fecha_inicio'] = _soloFecha(fecha);
    if (cantidadPorHora != null && cantidadPorHora.isNotEmpty)
      payload['cantidadPorHora'] = cantidadPorHora;

    final online = await _connectivity.hayInternet();

    if (online) {
      try {
        final response = await http.post(
          Uri.parse('$_baseUrl/api/recordatorios/actividad'),
          headers: {
            'Content-Type':  'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(payload),
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 201) {
          for (final hora in horas) {
            await _db.insertarRecordatorio({
              'rut_usuario':  rut,
              'tipo':         'actividad',
              'nombre':       tipoActividad,
              'hora_inicio':  hora,
              'detalle':      cantidadPorHora?[hora],
              'frecuencia':   fecha != null ? 'unica' : 'diaria',
              'fecha_unica':  fecha != null ? _soloFecha(fecha) : null,
              'sincronizado': 1,
              'activo':       1,
              'creado_en':    DateTime.now().toIso8601String(),
            });
          }
          return true;
        }
      } catch (_) {}
    }

    // Offline
    for (final hora in horas) {
      final idLocal = await _db.insertarRecordatorio({
        'rut_usuario':  rut,
        'tipo':         'actividad',
        'nombre':       tipoActividad,
        'hora_inicio':  hora,
        'detalle':      cantidadPorHora?[hora],
        'frecuencia':   fecha != null ? 'unica' : 'diaria',
        'fecha_unica':  fecha != null ? _soloFecha(fecha) : null,
        'sincronizado': 0,
        'activo':       1,
        'creado_en':    DateTime.now().toIso8601String(),
      });
      await _db.encolarOperacion(
        operacion:  'crear_actividad',
        payload:    payload,
        idLocalRef: idLocal,
      );
    }
    return true;
  }

  Future<bool> editarActividad({
    required int id,
    required String hora,
    String? detalle,
  }) async {
    final token = await _authService.getToken();
    if (token == null) return false;

    final body = <String, dynamic>{'hora': hora};
    if (detalle != null && detalle.trim().isNotEmpty)
      body['detalle'] = detalle.trim();

    final idLocal = await _db.getIdLocalPorRailway(id);
    if (idLocal != null) {
      await _db.actualizarRecordatorio(idLocal, {
        'hora_inicio':  hora,
        'detalle':      detalle,
        'sincronizado': 0,
      });
    }

    final online = await _connectivity.hayInternet();
    if (online) {
      try {
        final res = await http.put(
          Uri.parse('$_baseUrl/api/recordatorios/$id'),
          headers: {
            'Content-Type':  'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(body),
        ).timeout(const Duration(seconds: 10));
        if (res.statusCode == 200 && idLocal != null) {
          await _db.actualizarRecordatorio(idLocal, {'sincronizado': 1});
        }
        return res.statusCode == 200;
      } catch (_) {}
    }

    await _db.encolarOperacion(
      operacion: 'editar_recordatorio',
      payload:   {'id_railway': id, ...body},
    );
    return true;
  }

  Future<bool> eliminarActividad(int id) async {
    final token = await _authService.getToken();
    if (token == null) return false;

    final idLocal = await _db.getIdLocalPorRailway(id);
    if (idLocal != null) await _db.eliminarRecordatorio(idLocal);

    final online = await _connectivity.hayInternet();
    if (online) {
      try {
        final res = await http.delete(
          Uri.parse('$_baseUrl/api/recordatorios/$id'),
          headers: {
            'Content-Type':  'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 10));
        return res.statusCode == 200;
      } catch (_) {}
    }

    await _db.encolarOperacion(
      operacion: 'eliminar_recordatorio',
      payload:   {'id_railway': id},
    );
    return true;
  }
}
