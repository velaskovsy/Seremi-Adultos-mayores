import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  // Patrón Singleton para usar la misma instancia en toda la app
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Se ejecuta en el main.dart al abrir la app para registrar el plugin en Android
  Future<void> initNotification() async {
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
      importance: Importance.max,
      priority: Priority.high,

      // CONFIGURACIÓN NATIVA PARA LA ALARMA
      fullScreenIntent: true, // <- ESTO HACE QUE SALTE LA PANTALLA COMPLETA
      category: AndroidNotificationCategory.alarm,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      ongoing: true, // Bloquea que el usuario la borre deslizando
    );

    NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    // SOLUCIÓN ERROR 3 y 4: El método .show() ahora obliga a nombrar todos sus argumentos
    await _notificationsPlugin.show(
      id: medicamento['id'] ?? 0,
      title: '¡Hora de tu medicación!',
      body: 'Debes tomar: ${medicamento['nombre']}',
      notificationDetails: platformDetails,
      payload: jsonEncode(medicamento), // Guardamos el JSON para que la vista lo lea al abrirse
    );
  }
}