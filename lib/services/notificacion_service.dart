import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import '../main.dart';
import '../viewmodels/alarma_presion_viewmodel.dart' hide AlarmaMedicionScreen;
import '../views/alarma_medicacion/alarma_medicacion_screen.dart';
import '../views/alarma_presion/alarma_presion_screen.dart' show AlarmaMedicionScreen;

class NotificationService {
  static int ultimoIdProcesado = -1; // para evitar pantallas duplicadas
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Santiago'));

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        final String? payload = response.payload;

        if (payload != null) {
          final Map<String, dynamic> datosPayload = jsonDecode(payload);

          // REVISIÓN DEL GUARDIA
          final int currentId = datosPayload['id'] ?? 0;
          if (NotificationService.ultimoIdProcesado == currentId) {
            print('Ignorando doble orden. La pantalla ya fue abierta.');
            return; // Corta la ejecución aquí para no abrir la segunda pantalla
          }
          NotificationService.ultimoIdProcesado = currentId; // Registramos que ya lo procesamos
          // FIN REVISIÓN

          if (datosPayload['tipo'] == 'medicion_repeticion' || datosPayload['tipo'] == 'medicion') {
            navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (_) => AlarmaMedicionScreen(medicion: datosPayload),
              ),
            );
          }
          // else para validación
          else if (datosPayload['tipo'] == 'medicamento') {
            navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (_) => AlarmScreen(medicamento: datosPayload),
              ),
            );
          }
          // Agregamos nuestra nueva actividad para que el sistema la reconozca
          else if (datosPayload['tipo'] == 'actividad') {
            print('El usuario tocó la notificación de actividad (Agua).');
          }

          // AGREGAMOS ESTE NUEVO BLOQUE PARA LA CITA
          else if (datosPayload['tipo'] == 'cita') {
            print('El usuario tocó la notificación de la Cita Médica.');
          }
        }
      },
    );
  }

  Future<void> dispararNotificacionPantallaCompleta(
      Map<String, dynamic> item,
      String tipoAlarma,
      {int intento = 1}) async {

    bool esAgresiva = intento >= 2;

    // 1. PATRÓN SUAVE
    final Int64List vibracionSuave = Int64List.fromList([0, 500, 1000, 500, 1000, 500]);

    // 2. PATRÓN AGRESIVO
    final Int64List vibracionAgresiva = Int64List.fromList([0, 2000, 200, 2000, 200, 3000]);

    final Int64List patronElegido = esAgresiva ? vibracionAgresiva : vibracionSuave;
    final Int32List banderaInsistente = Int32List.fromList(<int>[4]);

    String tituloNotificacion = (tipoAlarma == 'presion')
        ? '¡Hora de tu medición!'
        : '¡Hora de tu medicación!';

    String cuerpoNotificacion = (tipoAlarma == 'presion')
        ? 'Debes medirte: ${item['nombre']}'
        : 'Debes tomar: ${item['nombre']}';

    // 👇 LA MAGIA ESTÁ AQUÍ: Nombres de canales distintos 👇
    String channelId = esAgresiva ? 'canal_agresivo_v1' : 'canal_suave_v1';
    String channelName = esAgresiva ? 'Alarmas de Emergencia' : 'Alarmas Normales';

    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId, // 👈 Usamos la variable dinámica
      channelName, // 👈 Usamos la variable dinámica
      channelDescription: 'Canal de alta prioridad para asegurar la toma',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      visibility: NotificationVisibility.public,
      playSound: true,
      sound: const UriAndroidNotificationSound('content://settings/system/alarm_alert'),
      enableVibration: true,
      vibrationPattern: patronElegido, // 👈 Ahora sí lo va a respetar
      additionalFlags: banderaInsistente,

      ongoing: true,
      autoCancel: false,
    );

    NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      id: item['id'] ?? 0,
      title: tituloNotificacion,
      body: cuerpoNotificacion,
      notificationDetails: platformDetails,
      payload: jsonEncode(item),
    );
  }

  // 👇 NUEVO: programa UNA alarma (medicamento o presión) directamente en el
  // AlarmManager del sistema, para que suene aunque la app esté cerrada.
  // Reemplaza la lógica del Timer.periodic que vigilaba la hora en memoria.
  Future<void> programarAlarmaDelDia(Map<String, dynamic> item, String tipoAlarma) async {
    final String hora = item['hora'] ?? '';
    final int id = item['id'] ?? 0;
    if (hora.isEmpty) return;

    final partes = hora.split(':');
    if (partes.length != 2) return;

    final ahora = tz.TZDateTime.now(tz.local);
    tz.TZDateTime horaProgramada = tz.TZDateTime(
      tz.local, ahora.year, ahora.month, ahora.day,
      int.parse(partes[0]), int.parse(partes[1]),
    );

    // Si la hora ya pasó hoy, no la reprogramamos para mañana acá:
    // el listado "de hoy" se vuelve a pedir cada día desde la API.
    if (horaProgramada.isBefore(ahora)) return;

    final Int64List patronVibracion = Int64List.fromList([0, 500, 1000, 500, 1000, 500]);
    final Int32List banderaInsistente = Int32List.fromList(<int>[4]);

    String titulo = (tipoAlarma == 'presion') ? '¡Hora de tu medición!' : '¡Hora de tu medicación!';
    String cuerpo = (tipoAlarma == 'presion')
        ? 'Debes medirte: ${item['nombre']}'
        : 'Debes tomar: ${item['nombre']}';

    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'canal_alarma_programada_v1',
      'Alarmas Programadas',
      channelDescription: 'Canal de alta prioridad para asegurar la toma',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      visibility: NotificationVisibility.public,
      playSound: true,
      sound: const UriAndroidNotificationSound('content://settings/system/alarm_alert'),
      enableVibration: true,
      vibrationPattern: patronVibracion,
      additionalFlags: banderaInsistente,
      ongoing: true,
      autoCancel: false,
    );

    final platformDetails = NotificationDetails(android: androidDetails);

    final payload = {
      ...item,
      'tipo': tipoAlarma == 'presion' ? 'medicion' : 'medicamento',
    };

    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: titulo,
      body: cuerpo,
      scheduledDate: horaProgramada,
      notificationDetails: platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: jsonEncode(payload),
    );
    // El aviso de "no atendido" a los 30 min y la notificación al cuidador
    // se revisan en background vía Workmanager (ver background_tasks.dart),
    // no acá: una notificación local sola no puede "avisar al cuidador" sin
    // que el usuario la toque.
  }

  Future<void> programarRepeticionPresion(Map<String, dynamic> medicionAnterior, int minutos) async {
    final payloadData = {
      ...medicionAnterior,
      'tipo': 'medicion_repeticion',
      'nombre': 'Control de Presión (Repetición)',
    };

    final Int64List patronVibracion = Int64List.fromList([0, 1000, 500, 1000]);
    final Int32List banderaInsistente = Int32List.fromList(<int>[4]);

    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'presion_repeticion_channel_v6', // 👈 _v6
      'Repetición Presión',
      channelDescription: 'Recordatorio para repetir medición de presión',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
      playSound: true,
      sound: const UriAndroidNotificationSound('content://settings/system/alarm_alert'),
      enableVibration: true,
      vibrationPattern: patronVibracion,
      additionalFlags: banderaInsistente,

      // 👇 MAGIA ANTI-DESLIZAMIENTO 👇
      ongoing: true,
      autoCancel: false,
    );

    final platformDetails = NotificationDetails(android: androidDetails);

    final horaProgramada = tz.TZDateTime.now(tz.local).add(Duration(minutes: minutos));

    await _notificationsPlugin.zonedSchedule(
      id: 999,
      title: '¡Hora de repetir la medición!',
      body: 'Han pasado $minutos minutos. Por favor mídase la presión nuevamente.',
      scheduledDate: horaProgramada,
      notificationDetails: platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: jsonEncode(payloadData),
    );
  }

  // 👇 NUEVO: versión programada (zonedSchedule) de las notificaciones simples
  // de actividad/cita, para que salten aunque la app esté cerrada o el
  // teléfono se haya reiniciado. Mismo estilo visual que mostrarNotificacionEstiloWhatsapp.
  Future<void> programarNotificacionSimpleDelDia(Map<String, dynamic> item, String tipo) async {
    final String hora = item['hora'] ?? '';
    if (hora.isEmpty) return;

    final partes = hora.split(':');
    if (partes.length != 2) return;

    final ahora = tz.TZDateTime.now(tz.local);
    final horaProgramada = tz.TZDateTime(
      tz.local, ahora.year, ahora.month, ahora.day,
      int.parse(partes[0]), int.parse(partes[1]),
    );
    if (horaProgramada.isBefore(ahora)) return;

    // Offset para no chocar con ids de medicamentos/mediciones
    final int idBase = item['id'] ?? 0;
    final int id = tipo == 'cita' ? idBase + 3000000 : idBase + 2000000;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'canal_actividades_v1',
      'Actividades Simples',
      channelDescription: 'Notificaciones normales estilo mensaje',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    String titulo = '¡Recordatorio!';
    if (tipo == 'cita') {
      titulo = '📅 ¡Tienes una Cita Médica!';
    } else if (tipo == 'actividad') {
      titulo = '💧 ¡Hora de tu Actividad!';
    }

    String cuerpo = item['nombre'] ?? 'Revisa tu aplicación';
    if (item['detalle'] != null) {
      cuerpo = '$cuerpo: ${item['detalle']}';
    }

    final payload = {...item, 'tipo': tipo};

    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: titulo,
      body: cuerpo,
      scheduledDate: horaProgramada,
      notificationDetails: const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: jsonEncode(payload),
    );
  }

  Future<void> apagarAlarmas() async {
    // ⚠️ Ya NO usa cancelAll(): con zonedSchedule, eso borraría también las
    // alarmas futuras del día (no solo la que está sonando ahora).
    // Si se llama sin id, no hace nada (compatibilidad con llamadas viejas).
  }

  // Corta el sonido/vibración de UNA alarma puntual y su aviso de "no atendido" asociado.
  Future<void> apagarAlarma(int id) async {
    await _notificationsPlugin.cancel(id: id);
    await _notificationsPlugin.cancel(id: id + 900000); // aviso de no atendido
  }

  // Función que tira el mensaje instantáneamente
  Future<void> mostrarNotificacionEstiloWhatsapp(Map<String, dynamic> datosEvento) async {
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'canal_actividades_v1',
        'Actividades Simples',
        channelDescription: 'Notificaciones normales estilo mensaje',
        importance: Importance.max, // Máxima para que baje desde arriba
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      );

      const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

      String titulo = '¡Recordatorio!';
      if (datosEvento['tipo'] == 'cita') {
        titulo = '📅 ¡Tienes una Cita Médica!';
      } else if (datosEvento['tipo'] == 'actividad') {
        titulo = '💧 ¡Hora de tu Actividad!';
      }

      String cuerpo = datosEvento['nombre'] ?? 'Revisa tu aplicación';

      // Si tiene detalle (ej: "1 vaso"), lo agregamos al mensaje
      if (datosEvento['detalle'] != null) {
        cuerpo = '$cuerpo: ${datosEvento['detalle']}';
      }

      await _notificationsPlugin.show(
        id: datosEvento['id'] ?? DateTime.now().millisecond,
        title: titulo,
        body: cuerpo,
        notificationDetails: platformDetails,
        payload: jsonEncode(datosEvento),
      );

      print('✅ Notificación programada con éxito');
    } catch (e) {
      print('❌ Error al mostrar notificación simple: $e');
    }
  }
}