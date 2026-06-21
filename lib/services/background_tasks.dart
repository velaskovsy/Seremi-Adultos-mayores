// lib/services/background_tasks.dart
//
// Tarea periódica de Workmanager. Se encarga de:
//   1) Volver a programar (zonedSchedule) las alarmas del día por si el
//      AlarmManager las perdió (ej: el teléfono se reinició).
//   2) Revisar medicamentos/mediciones vencidos hace 30+ min sin atender,
//      y avisar al cuidador + registrar "no_atendido" — la misma lógica
//      que antes vivía en el Timer.periodic de AlarmViewModel.
//
// Workmanager corre esto en un isolate aparte (sin UI), y lo importante:
// una vez registrada la tarea periódica, Android la vuelve a agendar SOLO
// con que el sistema haga boot, sin necesidad de un BroadcastReceiver
// nativo escrito a mano.

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'recordatorio_service.dart';
import 'notificacion_service.dart';
import 'notificacion_cuidador_service.dart';
import 'historial_service.dart';

const String tareaSincronizacionAlarmas = 'sincronizacion_alarmas_v1';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      await _sincronizarYRevisarPendientes();
    } catch (e) {
      print('❌ Error en tarea de background: $e');
    }
    return Future.value(true);
  });
}

Future<void> _sincronizarYRevisarPendientes() async {
  final recordatorioService = RecordatorioService();
  final notificationService = NotificationService();
  final cuidadorService = NotificacionCuidadorService();
  final historialService = HistorialService();

  await notificationService.initNotification();

  final prefs = await SharedPreferences.getInstance();
  final DateTime ahora = DateTime.now();
  final String fechaHoy = DateFormat('yyyy-MM-dd').format(ahora);

  // ---------- 1) RE-PROGRAMAR ALARMAS (medicamentos + presión) ----------
  final medicamentos = await recordatorioService.obtenerSoloMedicamentos();
  final mediciones = await recordatorioService.obtenerSoloMediciones();

  for (final item in medicamentos) {
    final id = item['id'] ?? 0;
    final yaTomada = prefs.getBool('med_${id}_$fechaHoy') ?? false;
    if (!yaTomada) {
      await notificationService.programarAlarmaDelDia(item, 'medicamento');
    }
  }

  for (final item in mediciones) {
    final id = item['id'] ?? 0;
    final yaTomada = prefs.getBool('presion_${id}_$fechaHoy') ?? false;
    if (!yaTomada) {
      await notificationService.programarAlarmaDelDia(item, 'presion');
    }
  }

  final actividades = await recordatorioService.obtenerSoloActividades();
  for (final item in actividades) {
    await notificationService.programarNotificacionSimpleDelDia(item, 'actividad');
  }

  final citas = await recordatorioService.obtenerSoloCitas();
  for (final item in citas) {
    await notificationService.programarNotificacionSimpleDelDia(item, 'cita');
  }

  // ---------- 2) REVISAR "NO ATENDIDO" (30+ min sin respuesta) ----------
  await _revisarNoAtendidos(
    items: medicamentos,
    prefijo: 'med_',
    tipo: 'medicamento',
    ahora: ahora,
    fechaHoy: fechaHoy,
    prefs: prefs,
    cuidadorService: cuidadorService,
    historialService: historialService,
  );

  await _revisarNoAtendidos(
    items: mediciones,
    prefijo: 'presion_',
    tipo: 'medicion',
    ahora: ahora,
    fechaHoy: fechaHoy,
    prefs: prefs,
    cuidadorService: cuidadorService,
    historialService: historialService,
  );
}

Future<void> _revisarNoAtendidos({
  required List<Map<String, dynamic>> items,
  required String prefijo,
  required String tipo,
  required DateTime ahora,
  required String fechaHoy,
  required SharedPreferences prefs,
  required NotificacionCuidadorService cuidadorService,
  required HistorialService historialService,
}) async {
  for (final item in items) {
    final String hora = item['hora'] ?? '';
    final int id = item['id'] ?? 0;
    if (hora.isEmpty) continue;

    final llaveUnica = '$prefijo$id';
    final yaTomada = prefs.getBool('${llaveUnica}_$fechaHoy') ?? false;
    if (yaTomada) continue;

    final partes = hora.split(':');
    if (partes.length != 2) continue;

    final horaProgramada = DateTime(
      ahora.year, ahora.month, ahora.day,
      int.parse(partes[0]), int.parse(partes[1]),
    );

    final difMinutos = ahora.difference(horaProgramada).inMinutes;
    if (difMinutos < 30) continue;

    final llaveCuidadorNotificado = '${llaveUnica}_cuidador_notificado_$fechaHoy';
    final llaveNoAtendidoRegistrado = '${llaveUnica}_no_atendido_$fechaHoy';

    if (!(prefs.getBool(llaveCuidadorNotificado) ?? false)) {
      await prefs.setBool(llaveCuidadorNotificado, true);
      if (tipo == 'medicamento') {
        await cuidadorService.alertaMedicamento(
          nombreMedicamento: item['nombre'] ?? 'Medicamento',
          horaProgramada: hora,
        );
      } else {
        await cuidadorService.alertaPresion(horaProgramada: hora);
      }
    }

    if (!(prefs.getBool(llaveNoAtendidoRegistrado) ?? false)) {
      await prefs.setBool(llaveNoAtendidoRegistrado, true);
      await historialService.registrarNoAtendido(
        idRecordatorio: id,
        tipo: tipo,
        nombre: item['nombre'] ?? (tipo == 'medicamento' ? 'Medicamento' : 'Control de Presión'),
        horaProgramada: hora,
      );
    }
  }
}
