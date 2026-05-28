import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// SOLUCIÓN DEFINITIVA AL UNDEFINED: Importación absoluta de tu proyecto corporativo
import 'package:seremi_adultos_mayores/main.dart';

import '../services/recordatorio_service.dart';
import '../services/notificacion_service.dart';
import '../views/alarma_medicacion/alarma_medicacion_screen.dart';
import '../views/alarma_presion/alarma_presion_screen.dart'; // Tu nueva interfaz del mockup

class AlarmViewModel extends ChangeNotifier {
  final RecordatorioService _recordatorioService = RecordatorioService();
  final NotificationService _notificationService = NotificationService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Timer? _alarmTimer;

  // Registro de alarmas disparadas para que no colapsen en el mismo minuto
  final Map<String, String> _alarmasDisparadas = {};

  /// Inicia el bucle central de 15 segundos
  void iniciarMonitoreoDeAlarmas() {
    _alarmTimer?.cancel();
    sincronizarYVerificarTodo();

    _alarmTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      sincronizarYVerificarTodo();
    });
  }

  void detenerMonitoreo() {
    _alarmTimer?.cancel();
    _alarmasDisparadas.clear();
  }

  Future<void> sincronizarYVerificarTodo() async {
    try {
      final DateTime ahora = DateTime.now();
      final String horaActualStr = DateFormat('HH:mm').format(ahora);

      // ==========================================
      // BARRIDO 1: BUSCAR MEDICAMENTOS
      // ==========================================
      final listadoMedicamentos = await _recordatorioService.obtenerSoloMedicamentos();
      for (var medicamento in listadoMedicamentos) {
        final String hora = medicamento['hora'] ?? '';
        final int id = medicamento['id'] ?? 0;
        final String llaveUnica = "med_${id}";

        if (hora.isNotEmpty && hora.trim() == horaActualStr) {
          if (_alarmasDisparadas[llaveUnica] == horaActualStr) continue;
          _alarmasDisparadas[llaveUnica] = horaActualStr;

          await _notificationService.dispararNotificacionPantallaCompleta(medicamento);

          navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (_) => AlarmScreen(medicamento: medicamento)),
          );
          print("¡Pantalla de Medicamento abierta con éxito!");
        }
      }

      // ==========================================
      // BARRIDO 2: BUSCAR MEDICIONES DE PRESIÓN
      // ==========================================
      final listadoMediciones = await _recordatorioService.obtenerSoloMediciones();
      for (var medicion in listadoMediciones) {
        final String hora = medicion['hora'] ?? '';
        final int id = medicion['id'] ?? 0;
        final String llaveUnica = "presion_${id}";

        if (hora.isNotEmpty && hora.trim() == horaActualStr) {
          if (_alarmasDisparadas[llaveUnica] == horaActualStr) continue;
          _alarmasDisparadas[llaveUnica] = horaActualStr;

          await _notificationService.dispararNotificacionPantallaCompleta(medicion);

          // Lanza la pantalla de presión del mockup de forma segura
          navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (_) => AlarmaMedicionScreen(medicion: medicion)),
          );
          print("¡Pantalla de Medición de Presión abierta con éxito!");
        }
      }

    } catch (e) {
      print("Error en el bucle continuo de alarmas: $e");
    }
  }

  @override
  void dispose() {
    detenerMonitoreo();
    super.dispose();
  }
}