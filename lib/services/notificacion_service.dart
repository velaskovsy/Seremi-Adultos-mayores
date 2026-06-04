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

          if (datosPayload['tipo'] == 'medicion_repeticion' || datosPayload['tipo'] == 'medicion') {
            navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (_) => AlarmaMedicionScreen(medicion: datosPayload),
              ),
            );
          } else {
            navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (_) => AlarmScreen(medicamento: datosPayload),
              ),
            );
          }
        }
      },
    );
  }

  Future<void> dispararNotificacionPantallaCompleta(Map<String, dynamic> medicamento) async {
    final Int64List patronVibracion = Int64List.fromList([0, 1000, 500, 1000]);
    final Int32List banderaInsistente = Int32List.fromList(<int>[4]);

    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'medicamentos_channel_id_v6', // 👈 _v6
      'Recordatorios de Medicación',
      channelDescription: 'Canal de alta prioridad para asegurar la toma de remedios',
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

      // 👇 MAGIA ANTI-DESLIZAMIENTO 👇
      ongoing: true,      // Hace que la notificación sea "fija"
      autoCancel: false,  // Evita que desaparezca al tocarla
    );

    NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      id: medicamento['id'] ?? 0,
      title: '¡Hora de tu medicación!',
      body: 'Debes tomar: ${medicamento['nombre']}',
      notificationDetails: platformDetails,
      payload: jsonEncode(medicamento),
    );
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

  // 👇 NUEVA FUNCIÓN PARA EL BOTÓN VERDE 👇
  Future<void> apagarAlarmas() async {
    // Destruye todas las notificaciones activas para cortar el sonido/vibración
    await _notificationsPlugin.cancelAll();
  }

  Future<void> programarNotificacionNormal(Map<String, dynamic> datosEvento, DateTime fechaHoraProgramada) async {

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'canal_eventos_normales_v1', // ID distinto para que no se mezcle con las alarmas
      'Citas y Actividades',
      channelDescription: 'Notificaciones simples para recordatorios del día',

      // Con Importance y Priority en High, sale la tarjetita arriba y suena,
      // pero el usuario puede deslizarla para borrarla sin problemas.
      importance: Importance.high,
      priority: Priority.high,

      // Sonido y vibración estándar de Android (no usa alarma pesada)
      playSound: true,
      enableVibration: true,

      // ❌ IMPORTANTE: No le ponemos fullScreenIntent, ni ongoing, ni bucle.
    );

    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    // Convertimos la fecha normal a la fecha con zona horaria que exige la librería
    final horaTz = tz.TZDateTime.from(fechaHoraProgramada, tz.local);

    // Determinamos el título según el tipo
    String titulo = '¡Recordatorio!';
    if (datosEvento['tipo'] == 'cita') titulo = '📅 Tienes una Cita Médica';
    if (datosEvento['tipo'] == 'actividad') titulo = '🏃‍♂️ Hora de tu Actividad';

    await _notificationsPlugin.zonedSchedule(
      id: datosEvento['id'] ?? DateTime.now().millisecond, // Usa el ID del evento o uno aleatorio
      title: titulo,
      body: datosEvento['nombre'] ?? 'Revisa tu calendario para más detalles.',
      scheduledDate: horaTz,
      notificationDetails: platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: jsonEncode(datosEvento),
    );
  }
}