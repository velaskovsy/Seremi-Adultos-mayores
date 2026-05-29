import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:seremi_adultos_mayores/viewmodels/add_appointment_viewmodel.dart';
import 'package:seremi_adultos_mayores/viewmodels/alarma_presion_viewmodel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:seremi_adultos_mayores/viewmodels/add_activity_viewmodel.dart';
import 'package:seremi_adultos_mayores/viewmodels/add_measurement_viewmodel.dart';
import 'viewmodels/login_viewmodel.dart';
import 'viewmodels/register_viewmodel.dart';
import 'viewmodels/home_viewmodel.dart';
import 'viewmodels/alarma_medicacion_viewmodel.dart';
import 'viewmodels/add_medication_viewmodel.dart';
import 'views/login/login_screen.dart';
import 'package:flutter/services.dart';
import 'services/notificacion_service.dart';
import 'views/alarma_medicacion/alarma_medicacion_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialización de Supabase
  await Supabase.initialize(
    url: 'https://wtecnjrxjyynbnjkehso.supabase.co',
    anonKey: 'sb_publishable_gc6MXA9NgoYsWW5u8-6c8w_GzLUwfKR',
  );

  // Inicializar el canal nativo de notificaciones
  await NotificationService().initNotification();

  // Verificar si el sistema operativo abrió la app por una Alarma Intrusiva
  final notificationDetails = await FlutterLocalNotificationsPlugin().getNotificationAppLaunchDetails();

  Widget pantallaInicial = LoginScreen();

  if (notificationDetails?.didNotificationLaunchApp ?? false) {
    final payload = notificationDetails?.notificationResponse?.payload;
    if (payload != null) {
      final Map<String, dynamic> datosPayload = jsonDecode(payload);
      //pantallaInicial = AlarmScreen(medicamento: medicamentoDatos);
      // 👇 AQUÍ EVALUAMOS QUÉ TIPO DE NOTIFICACIÓN SE TOCÓ 👇
      if (datosPayload['tipo'] == 'medicion_repeticion' || datosPayload['tipo'] == 'medicion') {
        // Redirige a la pantalla de presión
        pantallaInicial = AlarmaMedicionScreen(medicion: datosPayload);
      } else {
        // Si no es medición, asume que es medicamento normal
        pantallaInicial = AlarmScreen(medicamento: datosPayload);
      }
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
        // Registramos el único AlarmViewModel unificado
        ChangeNotifierProvider(create: (_) => AlarmViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
      ],
      child: MyApp(pantallaInicial: pantallaInicial),
    ),
  );
}

class MyApp extends StatelessWidget {
  final Widget pantallaInicial;

  const MyApp({Key? key, required this.pantallaInicial}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Seremi Adultos Mayores',
      debugShowCheckedModeBanner: false,

      // 2. ASIGNACIÓN CLAVE: Enlazamos la llave global a la aplicación
      navigatorKey: navigatorKey,

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'),
      ],
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child!,
        );
      },
      home: pantallaInicial,
    );
  }
}