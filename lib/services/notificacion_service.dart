import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz; // Necesario para programar en el futuro

class NotificationService {
  // Patrón Singleton para usar la misma instancia en toda la app
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Se ejecuta en el main.dart al abrir la app para registrar el plugin en Android
  Future<void> initNotification() async {

    // 👇 AQUÍ ESTÁ "LA WEA" AGREGADA 👇
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Santiago')); // Configura la hora exacta de Chile
    // 👆 HASTA AQUÍ 👆

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    // SOLUCIÓN AQUÍ: Se agrega el parámetro nombrado 'settings:'
    await _notificationsPlugin.initialize(
      settings: initializationSettings,
    );
  }

  /// Este es el método que simula la alarma intrusiva
  Future<void> dispararNotificacionPantallaCompleta(Map<String, dynamic> medicamento) async {

    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'medicamentos_channel_id',
      'Recordatorios de Medicación',
      channelDescription: 'Canal de alta prioridad para asegurar la toma de remedios',
      importance: Importance.max, // Máxima importancia
      priority: Priority.high,     // Máxima prioridad

      // ESTAS LÍNEAS TRABAJAN JUNTAS PARA FORZAR EL SALTO DE PANTALLA
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      ongoing: true,

      // CONFIGURACIÓN EXTRA DE VISIBILIDAD (Fuerza a mostrarse sobre todo)
      visibility: NotificationVisibility.public,
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
    // 1. Preparamos los datos que viajarán ocultos en la notificación (Payload)
    // Le ponemos tipo 'medicion_repeticion' para que el main.dart sepa cómo reaccionar
    final payloadData = {
      ...medicionAnterior,
      'tipo': 'medicion_repeticion',
      'nombre': 'Control de Presión (Repetición)',
    };

    const androidDetails = AndroidNotificationDetails(
      'presion_repeticion_channel',
      'Repetición Presión',
      channelDescription: 'Recordatorio para repetir medición de presión',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
    );

    final platformDetails = const NotificationDetails(android: androidDetails);

    // Calculamos la hora exacta
    final horaProgramada = tz.TZDateTime.now(tz.local).add(Duration(minutes: minutos));

    await _notificationsPlugin.zonedSchedule(
      id: 999, // Nombre explícito agregado
      title: '¡Hora de repetir la medición!', // Nombre explícito agregado
      body: 'Han pasado $minutos minutos. Por favor mídase la presión nuevamente.', // Nombre explícito agregado
      scheduledDate: horaProgramada, // Nombre explícito agregado
      notificationDetails: platformDetails, // Nombre explícito agregado
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: jsonEncode(payloadData),
    );
  }
}