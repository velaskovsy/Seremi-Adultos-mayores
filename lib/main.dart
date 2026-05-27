import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:seremi_adultos_mayores/viewmodels/add_appointment_viewmodel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:seremi_adultos_mayores/viewmodels/add_activity_viewmodel.dart';
import 'package:seremi_adultos_mayores/viewmodels/add_measurement_viewmodel.dart';
import 'package:alarm/alarm.dart';
import 'viewmodels/login_viewmodel.dart';
import 'viewmodels/register_viewmodel.dart';
import 'viewmodels/alarma_medicacion_viewmodel.dart';
import 'viewmodels/add_medication_viewmodel.dart';
import 'views/login/login_screen.dart';
import 'views/alarma_medicacion/alarma_medicacion_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inicialización de Supabase
  await Supabase.initialize(
    url: 'https://wtecnjrxjyynbnjkehso.supabase.co',
    anonKey: 'sb_publishable_gc6MXA9NgoYsWW5u8-6c8w_GzLUwfKR',
  );

  // 2. Inicializar el plugin alarm (reemplaza a flutter_local_notifications)
  await Alarm.init();

  // 3. Verificar si la app fue abierta por una alarma
  Widget pantallaInicial = LoginScreen();

  final alarmRingPayload = Alarm.ringing;
  if (alarmRingPayload != null && alarmRingPayload.isNotEmpty) {
    // Si hay una alarma sonando al abrir, mostramos directamente la pantalla de alarma.
    // Pasamos los datos del primer medicamento en alarma.
    // El AlarmScreen recibirá el mapa del AlarmSettings más cercano.
    final primeraMedicacion = alarmRingPayload.first;
    pantallaInicial = AlarmScreen(
      medicamento: {
        'id': primeraMedicacion.id,
        'nombre': primeraMedicacion.notificationSettings.title
            .replaceFirst('¡Hora de tu medicación! ', ''),
        'hora': '${primeraMedicacion.dateTime.hour.toString().padLeft(2, '0')}:'
            '${primeraMedicacion.dateTime.minute.toString().padLeft(2, '0')}',
        'detalle': primeraMedicacion.notificationSettings.body
            .replaceFirst('Debes tomar: ', ''),
      },
    );
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
        ChangeNotifierProvider(create: (_) => AlarmViewModel()),
      ],
      child: MyApp(pantallaInicial: pantallaInicial),
    ),
  );
}

class MyApp extends StatefulWidget {
  final Widget pantallaInicial;

  const MyApp({Key? key, required this.pantallaInicial}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  // Escucha alarmas que disparan mientras la app está abierta
  late final StreamSubscription<AlarmSettings> _alarmSubscription;

  @override
  void initState() {
    super.initState();

    _alarmSubscription = Alarm.ringStream.stream.listen((alarmSettings) {
      // Navegar a la pantalla de alarma cuando suena mientras la app está activa
      if (navigatorKey.currentState != null) {
        navigatorKey.currentState!.push(
          MaterialPageRoute(
            builder: (_) => AlarmScreen(
              medicamento: {
                'id': alarmSettings.id,
                'nombre': alarmSettings.notificationSettings.body
                    .replaceFirst('Debes tomar: ', ''),
                'hora':
                    '${alarmSettings.dateTime.hour.toString().padLeft(2, '0')}:'
                    '${alarmSettings.dateTime.minute.toString().padLeft(2, '0')}',
                'detalle': alarmSettings.notificationSettings.body
                    .replaceFirst('Debes tomar: ', ''),
              },
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _alarmSubscription.cancel();
    super.dispose();
  }

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Seremi Adultos Mayores',
      debugShowCheckedModeBanner: false,
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
      home: widget.pantallaInicial,
    );
  }
}