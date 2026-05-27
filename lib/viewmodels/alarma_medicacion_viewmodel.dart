import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/recordatorio_service.dart';
import '../views/alarma_medicacion/alarma_medicacion_screen.dart'; // Asegúrate de que la ruta a tu vista sea la correcta

class AlarmViewModel extends ChangeNotifier {
  final RecordatorioService _recordatorioService = RecordatorioService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Timer? _alarmTimer;
  final Map<int, String> _alarmasDisparadas = {};

  /// Iniciamos el monitoreo pasándole el context de la app
  void iniciarMonitoreoDeAlarmas(BuildContext context) {
    _alarmTimer?.cancel();

    // Ejecuta la primera revisión inmediata
    sincronizarYVerificarAlarmas(context);

    // Revisa cada 15 segundos
    _alarmTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      sincronizarYVerificarAlarmas(context);
    });
  }

  void detenerMonitoreo() {
    _alarmTimer?.cancel();
    _alarmasDisparadas.clear();
  }

  Future<void> sincronizarYVerificarAlarmas(BuildContext context) async {
    try {
      final listadoMedicamentos = await _recordatorioService.obtenerSoloMedicamentos();
      if (listadoMedicamentos.isEmpty) return;

      final DateTime ahora = DateTime.now();
      final String horaActualStr = DateFormat('HH:mm').format(ahora);

      for (var medicamento in listadoMedicamentos) {
        final String horaMedicamento = medicamento['hora'] ?? '';
        final int idMedicamento = medicamento['id'] ?? 0;

        if (horaMedicamento.isEmpty) continue;

        // Comparamos hora y minuto
        if (horaMedicamento.trim() == horaActualStr) {

          // Control para que salte una sola vez en este minuto
          if (_alarmasDisparadas[idMedicamento] == horaActualStr) {
            continue;
          }
          _alarmasDisparadas[idMedicamento] = horaActualStr;

          // ¡SOLUCIÓN AQUÍ! En lugar de lanzar una notificación,
          // obligamos a Flutter a abrir tu AlarmScreen encima de todo.
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AlarmScreen(medicamento: medicamento),
              ),
            );
          }
          print("¡PANTALLA DE ALARMA LANZADA DIRECTAMENTE para: ${medicamento['nombre']}!");
        }
      }
    } catch (e) {
      print("Error al verificar horarios de alarmas: $e");
    }
  }

  @override
  void dispose() {
    detenerMonitoreo();
    super.dispose();
  }
}