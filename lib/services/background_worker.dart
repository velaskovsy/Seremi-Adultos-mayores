// lib/services/background_worker.dart
//
// Vigilante en segundo plano usando WorkManager.
// Se ejecuta automáticamente cada 15 minutos aunque la app esté cerrada.
// Hace dos cosas:
//   1. Rescata alarmas perdidas tras reinicio del teléfono
//   2. Detecta alarmas no atendidas y notifica al cuidador

import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'dart:convert';

import '../database/db_helper.dart';
import '../services/alarm_scheduler_service.dart';
import '../services/notificacion_cuidador_service.dart';
import '../services/historial_service.dart';
import '../services/auth_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PUNTO DE ENTRADA DEL WORKER (debe ser una función de nivel superior,
// no un método de clase, para que Dart la encuentre en segundo plano)
// ─────────────────────────────────────────────────────────────────────────────
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    print('🔧 WorkManager ejecutando tarea: $taskName');

    try {
      // Inicializar timezone (necesario en cada proceso separado)
      tz.initializeTimeZones();
      final String zona = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zona));

      switch (taskName) {
        case BackgroundWorker.TASK_RESCATAR_ALARMAS:
          await _rescatarAlarmasTrasReinicio();
          break;
        case BackgroundWorker.TASK_VIGILAR_NO_ATENDIDOS:
          await _vigilarAlarmasNoAtendidas();
          break;
        default:
          // Tarea periódica general: hace ambas cosas
          await _rescatarAlarmasTrasReinicio();
          await _vigilarAlarmasNoAtendidas();
      }
    } catch (e) {
      print('❌ Error en WorkManager: $e');
    }

    return Future.value(true);
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// TAREA 1: Reprogramar alarmas perdidas tras reinicio
// ─────────────────────────────────────────────────────────────────────────────
Future<void> _rescatarAlarmasTrasReinicio() async {
  try {
    final authService = AuthService();
    final usuario = await authService.getUsuario();
    final rut = usuario?['rut'] as String?;
    if (rut == null) return;

    final db = DBHelper();
    final recordatoriosHoy = await db.getRecordatoriosHoy(rut);

    if (recordatoriosHoy.isEmpty) return;

    // Filtrar solo medicamentos y mediciones (los que necesitan alarma fuerte)
    final alarmas = recordatoriosHoy.where((r) {
      final tipo = r['tipo'] as String?;
      return tipo == 'medicamento' || tipo == 'medicion';
    }).map((r) => <String, dynamic>{
      'id':        r['id_railway'] ?? r['id_local'],
      'tipo':      r['tipo'],
      'nombre':    r['nombre'],
      'hora':      r['hora_inicio'],
      'dosis':     r['dosis'],
      'detalle':   r['detalle'],
      'frecuencia': r['frecuencia'],
    }).toList();

    // Verificar qué alarmas ya fueron atendidas hoy (guardado en SharedPreferences)
    final prefs = await SharedPreferences.getInstance();
    final hoy = _soloFecha(DateTime.now());
    final alarmasPendientes = alarmas.where((a) {
      final id = a['id']?.toString() ?? '';
      final String tipo = a['tipo'] as String? ?? '';
      final String llaveUnica = (tipo == 'medicamento') ? 'med_$id' : 'presion_$id';
      return !(prefs.getBool("${llaveUnica}_$hoy") ?? false);
    }).toList();

    if (alarmasPendientes.isEmpty) return;

    print('🔄 Rescatando ${alarmasPendientes.length} alarmas tras reinicio...');
    await AlarmSchedulerService().reprogramarTodasLasAlarmas(alarmasPendientes);
    print('✅ Alarmas rescatadas correctamente');
  } catch (e) {
    print('❌ Error rescatando alarmas: $e');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAREA 2: Detectar alarmas no atendidas y avisar al cuidador
// ─────────────────────────────────────────────────────────────────────────────
Future<void> _vigilarAlarmasNoAtendidas() async {
  try {
    final authService = AuthService();
    final usuario = await authService.getUsuario();
    final rut = usuario?['rut'] as String?;
    if (rut == null) return;

    final db = DBHelper();
    final prefs = await SharedPreferences.getInstance();
    final ahora = DateTime.now();
    final hoy = _soloFecha(ahora);

    final recordatoriosHoy = await db.getRecordatoriosHoy(rut);

    for (final r in recordatoriosHoy) {
      final tipo = r['tipo'] as String?;
      if (tipo != 'medicamento' && tipo != 'medicion') continue;

      final int id = (r['id_railway'] ?? r['id_local']) as int;
      // ⚠️ IMPORTANTE: usar el mismo prefijo que AlarmViewModel para que las llaves coincidan
      // AlarmViewModel usa "med_$id" para medicamentos y "presion_$id" para mediciones
      final String llaveUnica = (tipo == 'medicamento') ? 'med_$id' : 'presion_$id';
      final String hora = r['hora_inicio'] as String? ?? '';
      if (hora.isEmpty) continue;

      // ¿Ya fue atendida hoy?
      final yaTomada = prefs.getBool("${llaveUnica}_$hoy") ?? false;
      if (yaTomada) continue;

      // ¿Cuántos minutos han pasado desde la hora programada?
      final partes = hora.split(':');
      if (partes.length != 2) continue;
      final horaProgramada = DateTime(
        ahora.year, ahora.month, ahora.day,
        int.tryParse(partes[0]) ?? 0,
        int.tryParse(partes[1]) ?? 0,
      );
      final difMinutos = ahora.difference(horaProgramada).inMinutes;

      // Si pasaron 30 minutos sin atender → notificar al cuidador (solo una vez)
      if (difMinutos >= 30) {
        final String llaveCuidador = "${llaveUnica}_cuidador_notificado_$hoy";
        final yaNotificado = prefs.getBool(llaveCuidador) ?? false;
        if (!yaNotificado) {
          await prefs.setBool(llaveCuidador, true);

          print('📲 [WorkManager] Notificando cuidador: ${r['nombre']}');
          final cuidadorService = NotificacionCuidadorService();
          if (tipo == 'medicamento') {
            await cuidadorService.alertaMedicamento(
              nombreMedicamento: r['nombre'] as String? ?? 'Medicamento',
              horaProgramada: hora,
            );
          } else {
            await cuidadorService.alertaPresion(horaProgramada: hora);
          }

          // Registrar en historial como "no_atendido"
          final String llaveHistorial = "${llaveUnica}_no_atendido_$hoy";
          final yaRegistrado = prefs.getBool(llaveHistorial) ?? false;
          if (!yaRegistrado) {
            await prefs.setBool(llaveHistorial, true);
            final historialService = HistorialService();
            await historialService.registrarNoAtendido(
              idRecordatorio: id,
              tipo: tipo,
              nombre: r['nombre'] as String? ?? tipo,
              horaProgramada: hora,
            );
          }
        }
      }
    }
  } catch (e) {
    print('❌ Error vigilando no atendidos: $e');
  }
}

String _soloFecha(DateTime dt) =>
    '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

// ─────────────────────────────────────────────────────────────────────────────
// CLASE GESTORA: registra y lanza el WorkManager
// ─────────────────────────────────────────────────────────────────────────────
class BackgroundWorker {
  static const String TASK_PERIODICA         = 'tarea_vigilante_alarmas';
  static const String TASK_RESCATAR_ALARMAS  = 'rescatar_alarmas_reinicio';
  static const String TASK_VIGILAR_NO_ATENDIDOS = 'vigilar_no_atendidos';

  /// Llamar una sola vez en main() antes de runApp()
  static Future<void> inicializar() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false, // ← cambiar a true para ver logs en tiempo real
    );
    print('✅ WorkManager inicializado');
  }

  /// Registra la tarea periódica cada 15 minutos.
  /// Llamar en main() tras inicializar().
  static Future<void> registrarTareaPeriodica() async {
    await Workmanager().registerPeriodicTask(
      TASK_PERIODICA,          // nombre único (clave de registro)
      TASK_PERIODICA,          // nombre de la tarea que recibe callbackDispatcher
      frequency: const Duration(minutes: 15),
      initialDelay: const Duration(minutes: 1),
      constraints: Constraints(
        networkType: NetworkType.not_required, // funciona sin internet
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
      existingWorkPolicy: ExistingWorkPolicy.keep, // no duplicar si ya está registrada
    );
    print('✅ Tarea periódica registrada (cada 15 min)');
  }

  /// Ejecutar inmediatamente una vez (útil al detectar boot completado)
  static Future<void> ejecutarRescateInmediato() async {
    await Workmanager().registerOneOffTask(
      '${TASK_RESCATAR_ALARMAS}_${DateTime.now().millisecondsSinceEpoch}',
      TASK_RESCATAR_ALARMAS,
      initialDelay: const Duration(seconds: 5),
    );
  }
}
