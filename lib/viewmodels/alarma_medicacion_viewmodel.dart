import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:seremi_adultos_mayores/main.dart';
import '../services/recordatorio_service.dart';
import '../services/notificacion_service.dart';
import '../views/alarma_medicacion/alarma_medicacion_screen.dart';
import '../views/alarma_presion/alarma_presion_screen.dart';
import 'package:flutter/services.dart';

class AlarmViewModel extends ChangeNotifier {
  final RecordatorioService _recordatorioService = RecordatorioService();
  final NotificationService _notificationService = NotificationService();
  // Nota: el aviso al cuidador y el registro de "no_atendido" ahora se
  // revisan en background (ver lib/services/background_tasks.dart), no acá.

  static List<String> alarmasSilenciadas = [];
  static bool pantallaAlarmaAbierta = false;

  static final DateTime tiempoInicioApp = DateTime.now();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  static const platform = MethodChannel('salud_mayor/alarma');

  Timer? _alarmTimer;

  void iniciarMonitoreoDeAlarmas() {
    _alarmTimer?.cancel();
    sincronizarYProgramarAlarmas();

    // Re-programa todo cada 5 min, por si cambian datos del server.
    _alarmTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      sincronizarYProgramarAlarmas();
    });
  }

  // 👇 Entrega TODAS las alarmas/recordatorios al sistema operativo
  // (AlarmManager) en vez de vigilarlas en memoria. Así suenan/aparecen
  // aunque la app esté cerrada o el teléfono se haya reiniciado.
  Future<void> sincronizarYProgramarAlarmas() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String fechaHoy = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final listadoMedicamentos = await _recordatorioService.obtenerSoloMedicamentos();
      for (var medicamento in listadoMedicamentos) {
        final int id = medicamento['id'] ?? 0;
        final bool yaTomadaHoy = prefs.getBool("med_${id}_$fechaHoy") ?? false;
        if (yaTomadaHoy || AlarmViewModel.alarmasSilenciadas.contains("med_$id")) continue;
        await _notificationService.programarAlarmaDelDia(medicamento, 'medicamento');
      }

      final listadoMediciones = await _recordatorioService.obtenerSoloMediciones();
      for (var medicion in listadoMediciones) {
        final int id = medicion['id'] ?? 0;
        final bool yaTomadaHoy = prefs.getBool("presion_${id}_$fechaHoy") ?? false;
        if (yaTomadaHoy || AlarmViewModel.alarmasSilenciadas.contains("presion_$id")) continue;
        await _notificationService.programarAlarmaDelDia(medicion, 'presion');
      }

      final listadoActividades = await _recordatorioService.obtenerSoloActividades();
      for (var actividad in listadoActividades) {
        await _notificationService.programarNotificacionSimpleDelDia(actividad, 'actividad');
      }

      final listadoCitas = await _recordatorioService.obtenerSoloCitas();
      for (var cita in listadoCitas) {
        await _notificationService.programarNotificacionSimpleDelDia(cita, 'cita');
      }
    } catch (e) {
      print("Error programando alarmas: $e");
    }
  }

  void detenerMonitoreo() {
    _alarmTimer?.cancel();
  }

  Future<void> sincronizarYVerificarTodo() async {
    // Mantenida solo por compatibilidad con cualquier llamado externo viejo.
    await sincronizarYProgramarAlarmas();
  }


  @override
  void dispose() {
    detenerMonitoreo();
    super.dispose();
  }
}