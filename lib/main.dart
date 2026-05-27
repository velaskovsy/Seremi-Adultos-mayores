import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:seremi_adultos_mayores/viewmodels/add_appointment_viewmodel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:seremi_adultos_mayores/viewmodels/add_activity_viewmodel.dart';
import 'package:seremi_adultos_mayores/viewmodels/add_measurement_viewmodel.dart';
import 'viewmodels/login_viewmodel.dart';
import 'viewmodels/register_viewmodel.dart';
import 'viewmodels/alarma_medicacion_viewmodel.dart';
import 'viewmodels/add_medication_viewmodel.dart';
import 'views/login/login_screen.dart';
import 'package:flutter/services.dart';
import 'services/notificacion_service.dart';
import 'views/alarma_medicacion/alarma_medicacion_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inicialización de Supabase (Se mantiene intacta de tu código)
  await Supabase.initialize(
    url: 'https://wtecnjrxjyynbnjkehso.supabase.co',
    anonKey: 'sb_publishable_gc6MXA9NgoYsWW5u8-6c8w_GzLUwfKR',
  );

  // 2. NUEVO: Inicializar el canal nativo de notificaciones antes de arrancar la app
  await NotificationService().initNotification();

  // 3. NUEVO: Verificar si el sistema operativo abrió la app por la Alarma Intrusiva
  final notificationDetails = await FlutterLocalNotificationsPlugin().getNotificationAppLaunchDetails();

  Widget pantallaInicial = LoginScreen(); // Pantalla por defecto de tu app

  if (notificationDetails?.didNotificationLaunchApp ?? false) {
    final payload = notificationDetails?.notificationResponse?.payload;
    if (payload != null) {
      // Si hay payload, decodificamos el JSON del medicamento y forzamos que abra tu AlarmScreen directamente
      final Map<String, dynamic> medicamentoDatos = jsonDecode(payload);
      pantallaInicial = AlarmScreen(medicamento: medicamentoDatos);
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => RegisterViewModel()),
        ChangeNotifierProvider(create: (_) => AddMedicationViewModel()),
        ChangeNotifierProvider(create: (_) => AddMeasurementViewModel()),
        ChangeNotifierProvider(create: (_) => AddActivityViewModel()),
        ChangeNotifierProvider(create: (_) => AddAppointmentViewModel()),
        // NUEVO: Agregamos el AlarmViewModel a la lista para que puedas usarlo en tus vistas
        ChangeNotifierProvider(create: (_) => AlarmViewModel()),
      ],
      // Pasamos la pantalla calculada (Login o la Alarma) a nuestra app principal
      child: MyApp(pantallaInicial: pantallaInicial),
    ),
  );
}

class MyApp extends StatelessWidget {
  final Widget pantallaInicial; // <- NUEVO: Recibe la pantalla con la que debe arrancar

  const MyApp({Key? key, required this.pantallaInicial}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Seremi Adultos Mayores',
      debugShowCheckedModeBanner: false,
      // Tus traducciones locales se mantienen intactas
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'),
      ],
      builder: (context, child) {
        // Tu configurador de textScaler para mantener fuentes fijas se mantiene intacto
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child!,
        );
      },
      // MODIFICADO: En vez de "home: LoginScreen()", usa la pantalla que calculó el main()
      home: pantallaInicial,
    );
  }
}
