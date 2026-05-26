import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:seremi_adultos_mayores/viewmodels/add_appointment_viewmodel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:seremi_adultos_mayores/viewmodels/add_activity_viewmodel.dart';
import 'package:seremi_adultos_mayores/viewmodels/add_measurement_viewmodel.dart';
import 'viewmodels/login_viewmodel.dart';
import 'viewmodels/register_viewmodel.dart';
import 'viewmodels/add_medication_viewmodel.dart';
import 'views/login/login_screen.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://wtecnjrxjyynbnjkehso.supabase.co',
    anonKey: 'sb_publishable_gc6MXA9NgoYsWW5u8-6c8w_GzLUwfKR',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => RegisterViewModel()),
        ChangeNotifierProvider(create: (_) => AddMedicationViewModel()),
        ChangeNotifierProvider(create: (_) => AddMeasurementViewModel()),
        ChangeNotifierProvider(create: (_) => AddActivityViewModel()),
        ChangeNotifierProvider(create: (_) => AddAppointmentViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
            textScaler: TextScaler.linear(1.0),
          ),
          child: child!,
        );
      },
      home: LoginScreen(),
    );
  }
}
