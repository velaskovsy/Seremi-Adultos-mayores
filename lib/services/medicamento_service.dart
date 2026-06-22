// lib/services/medicamento_service.dart — offline-first
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../database/db_helper.dart';
import 'auth_service.dart';
import 'connectivity_service.dart';

class MedicamentoService {
  static const String _baseUrl =
      'https://servidorappseremi-production.up.railway.app';

  final DBHelper _db = DBHelper();
  final AuthService _authService = AuthService();
  final ConnectivityService _connectivity = ConnectivityService();
  final _uuid = const Uuid();

  String _soloFecha(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  // ── Crear ─────────────────────────────────────────────────────
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
    final usuario = await _authService.getUsuario();
    final rut = usuario?['rut'] as String?;
    if (rut == null) return false;

    final token = await _authService.getToken();
    if (token == null) return false;

    final payload = <String, dynamic>{
      'nombre':      nombre,
      'dosis':       dosis,
      'hora_primera': hora,
      'grupo_id':    grupoId,
    };
    if (fecha != null)        payload['fecha_inicio']   = _soloFecha(fecha);
    if (intervalo != null && intervalo.trim().isNotEmpty)
                              payload['intervalo']       = intervalo;
    if (instrucciones != null && instrucciones.trim().isNotEmpty)
                              payload['instrucciones']   = instrucciones;
    if (urlFotoCaja != null)   payload['url_foto_caja']   = urlFotoCaja;
    if (urlFotoRemedio != null) payload['url_foto_remedio'] = urlFotoRemedio;

    final online = await _connectivity.hayInternet();

    if (online) {
      try {
        final response = await http.post(
          Uri.parse('$_baseUrl/api/recordatorios/medicamento'),
          headers: {
            'Content-Type':  'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(payload),
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 201) {
          // Guardar también en SQLite con sincronizado=1
          final idLocal = await _db.insertarRecordatorio({
            'rut_usuario':      rut,
            'tipo':             'medicamento',
            'nombre':           nombre,
            'dosis':            dosis,
            'hora_inicio':      hora,
            'frecuencia':       fecha != null ? 'unica' : 'diaria',
            'fecha_unica':      fecha != null ? _soloFecha(fecha) : null,
            'intervalo':        intervalo,
            'instrucciones':    instrucciones,
            'url_foto_caja':    urlFotoCaja,
            'url_foto_remedio': urlFotoRemedio,
            'grupo_id':         grupoId,
            'sincronizado':     1,
            'activo':           1,
            'creado_en':        DateTime.now().toIso8601String(),
          });
          // Intentar extraer el id_railway de la respuesta
          try {
            final data = jsonDecode(response.body);
            final ids = data['ids'] as List<dynamic>?;
            if (ids != null && ids.isNotEmpty) {
              await _db.marcarRecordatorioSincronizado(idLocal, ids.first as int);
            }
          } catch (_) {}
          return true;
        }
      } catch (_) {}
    }

    // Offline: guardar en SQLite + encolar
    final idLocal = await _db.insertarRecordatorio({
      'rut_usuario':      rut,
      'tipo':             'medicamento',
      'nombre':           nombre,
      'dosis':            dosis,
      'hora_inicio':      hora,
      'frecuencia':       fecha != null ? 'unica' : 'diaria',
      'fecha_unica':      fecha != null ? _soloFecha(fecha) : null,
      'intervalo':        intervalo,
      'instrucciones':    instrucciones,
      'url_foto_caja':    urlFotoCaja,
      'url_foto_remedio': urlFotoRemedio,
      'grupo_id':         grupoId,
      'sincronizado':     0,
      'activo':           1,
      'creado_en':        DateTime.now().toIso8601String(),
    });

    await _db.encolarOperacion(
      operacion:  'crear_medicamento',
      payload:    payload,
      idLocalRef: idLocal,
    );

    return true; // el usuario no nota la diferencia
  }

  // ── Editar ────────────────────────────────────────────────────
  Future<bool> editarMedicamento({
    required int id, // id de Railway (o id_local si es offline)
    required String hora,
    String? instrucciones,
    String? urlFotoCaja,
    String? urlFotoRemedio,
  }) async {
    final token = await _authService.getToken();
    if (token == null) return false;

    final body = <String, dynamic>{'hora': hora};
    if (instrucciones != null && instrucciones.trim().isNotEmpty)
      body['instrucciones'] = instrucciones.trim();
    if (urlFotoCaja != null)   body['url_foto_caja']   = urlFotoCaja;
    if (urlFotoRemedio != null) body['url_foto_remedio'] = urlFotoRemedio;

    // Actualizar en SQLite siempre
    final idLocal = await _db.getIdLocalPorRailway(id);
    if (idLocal != null) {
      await _db.actualizarRecordatorio(idLocal, {
        'hora_inicio':      hora,
        'instrucciones':    instrucciones,
        'url_foto_caja':    urlFotoCaja,
        'url_foto_remedio': urlFotoRemedio,
        'sincronizado':     0,
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

    // Encolar edición para cuando haya internet
    await _db.encolarOperacion(
      operacion: 'editar_recordatorio',
      payload:   {'id_railway': id, ...body},
    );
    return true;
  }

  // ── Eliminar ──────────────────────────────────────────────────
  Future<bool> eliminarMedicamento(int id) async {
    final token = await _authService.getToken();
    if (token == null) return false;

    // Eliminar de SQLite siempre (soft delete)
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
