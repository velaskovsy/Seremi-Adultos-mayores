// lib/services/alarm_scheduler_service.dart
//
// Servicio que programa alarmas usando zonedSchedule de flutter_local_notifications.
// Las alarmas programadas aquí:
//   ✅ Funcionan con la app cerrada
//   ✅ Sobreviven al reinicio del teléfono
//   ✅ Son gestionadas 100% por el Sistema Operativo Android

import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'dart:typed_data';

class AlarmSchedulerService {
  static final AlarmSchedulerService _instance = AlarmSchedulerService._internal();
  factory AlarmSchedulerService() => _instance;
  AlarmSchedulerService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  // ─────────────────────────────────────────────────────────────
  // INICIALIZACIÓN (llamar una sola vez en main())
  // ─────────────────────────────────────────────────────────────
  Future<void> init() async {
    tz.initializeTimeZones();
    final String zonaLocal = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(zonaLocal));
  }

  // ─────────────────────────────────────────────────────────────
  // PROGRAMAR ALARMA PARA UN RECORDATORIO
  // Llama a este método cuando el usuario guarda/edita un recordatorio.
  // tipo: 'medicamento' | 'medicion' | 'actividad' | 'cita'
  // ─────────────────────────────────────────────────────────────
  Future<void> programarAlarma({
    required int id,
    required String hora,        // formato "HH:mm"
    required String tipo,
    required String nombre,
    String? dosis,
    String? detalle,
    Map<String, dynamic>? extraPayload,
    bool repetirDiariamente = true,
  }) async {
    // Cancelar cualquier alarma previa con este mismo id
    await _plugin.cancel(id);

    final partes = hora.split(':');
    if (partes.length != 2) return;

    final int hh = int.tryParse(partes[0]) ?? 0;
    final int mm = int.tryParse(partes[1]) ?? 0;

    // Construir la primera fecha/hora programada
    final ahora = tz.TZDateTime.now(tz.local);
    tz.TZDateTime horaProgramada = tz.TZDateTime(
      tz.local,
      ahora.year, ahora.month, ahora.day,
      hh, mm,
    );

    // Si ya pasó hoy, programar para mañana
    if (horaProgramada.isBefore(ahora)) {
      horaProgramada = horaProgramada.add(const Duration(days: 1));
    }

    // Payload que recibe la notificación (contiene todos los datos del recordatorio)
    final payload = <String, dynamic>{
      'id':     id,
      'tipo':   tipo,
      'nombre': nombre,
      if (dosis != null)   'dosis':   dosis,
      if (detalle != null) 'detalle': detalle,
      'hora':   hora,
      ...?extraPayload,
    };

    final androidDetails = _buildAndroidDetails(tipo, nombre, dosis ?? detalle ?? '');

    if (repetirDiariamente) {
      // Alarma diaria: el SO la reprograma automáticamente cada día
      await _plugin.zonedSchedule(
        id,
        _titulo(tipo),
        _cuerpo(tipo, nombre, dosis ?? detalle ?? ''),
        horaProgramada,
        NotificationDetails(android: androidDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time, // ← repite CADA DÍA a la misma hora
        payload: jsonEncode(payload),
      );
    } else {
      // Alarma de una sola vez
      await _plugin.zonedSchedule(
        id,
        _titulo(tipo),
        _cuerpo(tipo, nombre, dosis ?? detalle ?? ''),
        horaProgramada,
        NotificationDetails(android: androidDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: jsonEncode(payload),
      );
    }

    print('✅ Alarma programada: id=$id tipo=$tipo hora=$hora repetir=$repetirDiariamente');
  }

  // ─────────────────────────────────────────────────────────────
  // CANCELAR UNA ALARMA ESPECÍFICA (NO TODAS)
  // Usar este método al apagar/atender una alarma individual
  // ─────────────────────────────────────────────────────────────
  Future<void> cancelarAlarma(int id) async {
    await _plugin.cancel(id);
    print('🔕 Alarma cancelada: id=$id');
  }

  // ─────────────────────────────────────────────────────────────
  // CANCELAR TODAS LAS ALARMAS DE UN GRUPO
  // Usar cuando el usuario elimina todos los recordatorios de un grupo
  // ─────────────────────────────────────────────────────────────
  Future<void> cancelarAlarmasPorIds(List<int> ids) async {
    for (final id in ids) {
      await _plugin.cancel(id);
    }
    print('🔕 ${ids.length} alarmas canceladas');
  }

  // ─────────────────────────────────────────────────────────────
  // RE-PROGRAMAR TODAS LAS ALARMAS DEL DÍA
  // Llamado por el WorkManager al encender el teléfono
  // para rescatar alarmas que se perdieron por el reinicio
  // ─────────────────────────────────────────────────────────────
  Future<void> reprogramarTodasLasAlarmas(
      List<Map<String, dynamic>> recordatorios) async {
    print('🔄 Re-programando ${recordatorios.length} alarmas tras reinicio...');
    for (final r in recordatorios) {
      final int? id = r['id'] as int?;
      final String? hora = r['hora'] as String?;
      final String? tipo = r['tipo'] as String?;
      final String? nombre = r['nombre'] as String?;
      if (id == null || hora == null || tipo == null || nombre == null) continue;

      await programarAlarma(
        id: id,
        hora: hora,
        tipo: tipo,
        nombre: nombre,
        dosis: r['dosis'] as String?,
        detalle: r['detalle'] as String?,
        extraPayload: Map<String, dynamic>.from(r),
        repetirDiariamente: (r['frecuencia'] == 'diaria'),
      );
    }
    print('✅ Re-programación completa');
  }

  // ─────────────────────────────────────────────────────────────
  // HELPERS PRIVADOS
  // ─────────────────────────────────────────────────────────────

  String _titulo(String tipo) {
    switch (tipo) {
      case 'medicamento': return '💊 ¡Hora de tu medicación!';
      case 'medicion':    return '🩺 ¡Hora de tu medición!';
      case 'actividad':   return '💧 ¡Hora de tu actividad!';
      case 'cita':        return '📅 ¡Tienes una cita médica!';
      default:            return '⏰ Recordatorio';
    }
  }

  String _cuerpo(String tipo, String nombre, String extra) {
    switch (tipo) {
      case 'medicamento': return 'Debes tomar: $nombre${extra.isNotEmpty ? " ($extra)" : ""}';
      case 'medicion':    return 'Debes medirte: $nombre';
      case 'actividad':   return '$nombre${extra.isNotEmpty ? ": $extra" : ""}';
      case 'cita':        return 'Tienes cita: $nombre';
      default:            return nombre;
    }
  }

  AndroidNotificationDetails _buildAndroidDetails(
      String tipo, String nombre, String extra) {

    final bool esAlarmaFuerteUrgente =
        tipo == 'medicamento' || tipo == 'medicion';

    final Int64List vibracion = esAlarmaFuerteUrgente
        ? Int64List.fromList([0, 1000, 300, 1000, 300, 2000])
        : Int64List.fromList([0, 500, 200, 500]);

    final Int32List flags = Int32List.fromList([4]); // FLAG_INSISTENT

    if (esAlarmaFuerteUrgente) {
      return AndroidNotificationDetails(
        'canal_alarma_medicacion_v2',
        'Alarmas de Medicación y Medición',
        channelDescription: 'Alarmas críticas que suenan aunque el teléfono esté bloqueado',
        importance: Importance.max,
        priority: Priority.high,
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
        audioAttributesUsage: AudioAttributesUsage.alarm,
        visibility: NotificationVisibility.public,
        playSound: true,
        sound: const UriAndroidNotificationSound('content://settings/system/alarm_alert'),
        enableVibration: true,
        vibrationPattern: vibracion,
        additionalFlags: flags,
        ongoing: true,
        autoCancel: false,
      );
    } else {
      // Actividades y citas: notificación normal (estilo WhatsApp)
      return AndroidNotificationDetails(
        'canal_actividades_citas_v2',
        'Recordatorios de Actividades y Citas',
        channelDescription: 'Notificaciones normales para actividades y citas médicas',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        vibrationPattern: vibracion,
      );
    }
  }
}
