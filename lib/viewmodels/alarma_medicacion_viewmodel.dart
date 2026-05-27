import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/recordatorio_service.dart';
import '../services/notificacion_service.dart'; // <- Importamos tu servicio de notificación nativo
import '../views/alarma_medicacion/alarma_medicacion_screen.dart';

class AlarmViewModel extends ChangeNotifier {
  final RecordatorioService _recordatorioService = RecordatorioService();
  final NotificationService _notificationService = NotificationService(); // <- Instanciamos el servicio nativo

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Timer? _alarmTimer;
  final Map<int, String> _alarmasDisparadas = {};

  /// Iniciamos el monitoreo pasándole el context de la app
  void iniciarMonitoreoDeAlarmas(BuildContext context) {
    _alarmTimer?.cancel();

    // Ejecuta la primera revisión inmediata al cargar
    sincronizarYVerificarAlarmas(context);

    // Revisa periódicamente cada 15 segundos
    _alarmTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      sincronizarYVerificarAlarmas(context);
    });
  }

  /// Cancela el temporizador y limpia el historial de ejecuciones
  void detenerMonitoreo() {
    _alarmTimer?.cancel();
    _alarmasDisparadas.clear();
  }

  /// Revisa los horarios locales/remotos y despierta al hardware si coincide el tiempo
  Future<void> sincronizarYVerificarAlarmas(BuildContext context) async {
    try {
      // Obtiene el listado de medicamentos (desde Railway o desde SharedPreferences si no hay señal)
      final listadoMedicamentos = await _recordatorioService.obtenerSoloMedicamentos();
      if (listadoMedicamentos.isEmpty) return;

      // Formateamos la hora actual del dispositivo a "HH:mm" (Ej: "21:00")
      final DateTime ahora = DateTime.now();
      final String horaActualStr = DateFormat('HH:mm').format(ahora);

      for (var medicamento in listadoMedicamentos) {
        final String horaMedicamento = medicamento['hora'] ?? '';
        final int idMedicamento = medicamento['id'] ?? 0;

        if (horaMedicamento.isEmpty) continue;

        // Comparamos hora y minuto exactos
        if (horaMedicamento.trim() == horaActualStr) {

          // Control crítico: evita que la alarma se dispare en bucle dentro del mismo minuto
          if (_alarmasDisparadas[idMedicamento] == horaActualStr) {
            continue;
          }
          _alarmasDisparadas[idMedicamento] = horaActualStr;

          // 1. PASO CLAVE PARA PANTALLA BLOQUEADA:
          // Forzamos al sistema operativo a emitir un aviso sonoro intrusivo de alta prioridad.
          // Esto obligará a Android a encender el display táctil y sacar la app del modo de suspensión profundo.
          await _notificationService.dispararNotificacionPantallaCompleta(medicamento);

          // 2. LANZAMIENTO DE LA SCREEN:
          // Empujamos inmediatamente tu vista rosada de Flutter sobre la interfaz actual.
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AlarmScreen(medicamento: medicamento),
              ),
            );
          }
          print("¡SISTEMA COMBINADO ACTIVADO! Alarma lanzada para: ${medicamento['nombre']} a las $horaActualStr");
        }
      }
    } catch (e) {
      print("Error al verificar horarios de alarmas en el ViewModel: $e");
    }
  }

  @override
  void dispose() {
    detenerMonitoreo();
    super.dispose();
  }
}