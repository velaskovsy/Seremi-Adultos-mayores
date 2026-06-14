import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:seremi_adultos_mayores/main.dart';
import '../services/recordatorio_service.dart';
import '../services/notificacion_service.dart';
import '../services/notificacion_cuidador_service.dart'; // ✅ NUEVO
import '../views/alarma_medicacion/alarma_medicacion_screen.dart';
import '../views/alarma_presion/alarma_presion_screen.dart';
import 'package:flutter/services.dart';

class AlarmViewModel extends ChangeNotifier {
  final RecordatorioService _recordatorioService = RecordatorioService();
  final NotificationService _notificationService = NotificationService();
  final NotificacionCuidadorService _cuidadorService = NotificacionCuidadorService(); // ✅ NUEVO

  static List<String> alarmasSilenciadas = [];
  static bool pantallaAlarmaAbierta = false;

  static final DateTime tiempoInicioApp = DateTime.now();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  static const platform = MethodChannel('salud_mayor/alarma');

  Timer? _alarmTimer;

  final Map<String, String> _alarmasDisparadas = {};

  // ✅ NUEVO: registro de qué alarmas ya notificaron al cuidador (para no repetir)
  final Set<String> _cuidadoresNotificados = {};

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
    _cuidadoresNotificados.clear(); // ✅ NUEVO
  }

  Future<void> sincronizarYVerificarTodo() async {
    try {
      final DateTime ahora = DateTime.now();
      final String horaActualStr = DateFormat('HH:mm').format(ahora);
      final String fechaHoy = DateFormat('yyyy-MM-dd').format(ahora);

      final prefs = await SharedPreferences.getInstance();

      // ==========================================
      // BARRIDO 1: BUSCAR MEDICAMENTOS
      // ==========================================
      final listadoMedicamentos = await _recordatorioService.obtenerSoloMedicamentos();
      for (var medicamento in listadoMedicamentos) {
        final String hora = medicamento['hora'] ?? '';
        final int id = medicamento['id'] ?? 0;
        final String llaveUnica = "med_$id";

        bool yaTomadaHoy = prefs.getBool("${llaveUnica}_$fechaHoy") ?? false;
        if (yaTomadaHoy || AlarmViewModel.alarmasSilenciadas.contains(llaveUnica)) {
          continue;
        }

        if (hora.isNotEmpty) {
          final partes = hora.split(':');
          if (partes.length == 2) {
            DateTime horaProgramada = DateTime(ahora.year, ahora.month, ahora.day,
                int.parse(partes[0]), int.parse(partes[1]));

            if (horaProgramada.isBefore(AlarmViewModel.tiempoInicioApp)) continue;

            DateTime ahoraLimpio = DateTime(ahora.year, ahora.month, ahora.day,
                ahora.hour, ahora.minute);

            if (ahoraLimpio.isBefore(horaProgramada)) continue;

            int difMinutos = ahoraLimpio.difference(horaProgramada).inMinutes;

            if (difMinutos >= 0 && difMinutos <= 30 && difMinutos % 1 == 0) {

              String llaveDisparo = "${llaveUnica}_$difMinutos";

              if (_alarmasDisparadas[llaveDisparo] == horaActualStr) break;
              _alarmasDisparadas[llaveDisparo] = horaActualStr;

              // ✅ NUEVO: Trigger 1 — al minuto 30 sin respuesta, avisar al cuidador
              if (difMinutos == 30) {
                final String llaveCuidador = "${llaveUnica}_cuidador_notificado_$fechaHoy";
                if (!_cuidadoresNotificados.contains(llaveCuidador)) {
                  _cuidadoresNotificados.add(llaveCuidador);
                  print('📲 Notificando al cuidador por medicamento no tomado: ${medicamento['nombre']}');
                  _cuidadorService.alertaMedicamento(
                    nombreMedicamento: medicamento['nombre'] ?? 'Medicamento',
                    horaProgramada: hora,
                  );
                }
              }

              try {
                await platform.invokeMethod('traerAlFrente');
              } catch (e) {
                print("No se pudo maximizar la app: $e");
              }

              NotificationService.ultimoIdProcesado = id;
              final int intento = difMinutos == 0 ? 1 : 2;
              await _notificationService.dispararNotificacionPantallaCompleta(
                  medicamento, 'medicamento', intento: intento);

              if (!AlarmViewModel.pantallaAlarmaAbierta) {
                AlarmViewModel.pantallaAlarmaAbierta = true;
                navigatorKey.currentState?.push(
                    MaterialPageRoute(builder: (_) => AlarmScreen(medicamento: medicamento))
                );
              } else {
                print("La pantalla ya está abierta, solo sonará el aviso.");
              }
              print("¡Alarma lanzada! (Minuto de reintento: $difMinutos)");
              break;
            }
          }
        }
      }

      // ==========================================
      // BARRIDO 2: BUSCAR MEDICIONES DE PRESIÓN
      // ==========================================
      final listadoMediciones = await _recordatorioService.obtenerSoloMediciones();
      for (var medicion in listadoMediciones) {
        final String hora = medicion['hora'] ?? '';
        final int id = medicion['id'] ?? 0;
        final String llaveUnica = "presion_$id";

        bool yaTomadaHoy = prefs.getBool("${llaveUnica}_$fechaHoy") ?? false;
        if (yaTomadaHoy || AlarmViewModel.alarmasSilenciadas.contains(llaveUnica)) {
          continue;
        }

        if (hora.isNotEmpty) {
          final partes = hora.split(':');
          if (partes.length == 2) {
            DateTime horaProgramada = DateTime(ahora.year, ahora.month, ahora.day,
                int.parse(partes[0]), int.parse(partes[1]));

            if (horaProgramada.isBefore(AlarmViewModel.tiempoInicioApp)) continue;

            DateTime ahoraLimpio = DateTime(ahora.year, ahora.month, ahora.day,
                ahora.hour, ahora.minute);

            if (ahoraLimpio.isBefore(horaProgramada)) continue;

            int difMinutos = ahoraLimpio.difference(horaProgramada).inMinutes;

            if (difMinutos >= 0 && difMinutos <= 30 && difMinutos % 1 == 0) {

              String llaveDisparo = "${llaveUnica}_$difMinutos";

              if (_alarmasDisparadas[llaveDisparo] == horaActualStr) break;
              _alarmasDisparadas[llaveDisparo] = horaActualStr;

              // ✅ NUEVO: Trigger 2 — al minuto 30 sin respuesta, avisar al cuidador
              if (difMinutos == 30) {
                final String llaveCuidador = "${llaveUnica}_cuidador_notificado_$fechaHoy";
                if (!_cuidadoresNotificados.contains(llaveCuidador)) {
                  _cuidadoresNotificados.add(llaveCuidador);
                  print('📲 Notificando al cuidador por presión no medida');
                  _cuidadorService.alertaPresion(horaProgramada: hora);
                }
              }

              try {
                await platform.invokeMethod('traerAlFrente');
              } catch (e) {
                print("No se pudo maximizar la app: $e");
              }

              NotificationService.ultimoIdProcesado = id;
              final int intento = difMinutos == 0 ? 1 : 2;
              await _notificationService.dispararNotificacionPantallaCompleta(
                  medicion, 'presion', intento: intento);

              if (!AlarmViewModel.pantallaAlarmaAbierta) {
                AlarmViewModel.pantallaAlarmaAbierta = true;
                navigatorKey.currentState?.push(
                  MaterialPageRoute(builder: (_) => AlarmaMedicionScreen(medicion: medicion)),
                );
              } else {
                print("La pantalla de presión ya está abierta, solo sonará el aviso.");
              }

              print("¡Alarma de Presión lanzada! (Minuto de reintento: $difMinutos)");
              break;
            }
          }
        }
      }

      // ==========================================
      // BARRIDO 3: BUSCAR ACTIVIDADES (HIDRATACIÓN)
      // ==========================================
      final listadoActividades = await _recordatorioService.obtenerSoloActividades();
      for (var actividad in listadoActividades) {
        final String hora = actividad['hora'] ?? '';
        final int id = actividad['id'] ?? 0;
        final String llaveUnica = "actividad_${id}";

        if (hora.isNotEmpty && hora.trim() == horaActualStr) {
          if (_alarmasDisparadas[llaveUnica] == horaActualStr) continue;
          _alarmasDisparadas[llaveUnica] = horaActualStr;
          await _notificationService.mostrarNotificacionEstiloWhatsapp(actividad);
          print("¡Notificación simple de Actividad enviada!");
        }
      }

      // ==========================================
      // BARRIDO 4: BUSCAR CITAS MÉDICAS
      // ==========================================
      final listadoCitas = await _recordatorioService.obtenerSoloCitas();
      for (var cita in listadoCitas) {
        final String hora = cita['hora'] ?? '';
        final int id = cita['id'] ?? 0;
        final String llaveUnica = "cita_${id}";

        if (hora.isNotEmpty && hora.trim() == horaActualStr) {
          if (_alarmasDisparadas[llaveUnica] == horaActualStr) continue;
          _alarmasDisparadas[llaveUnica] = horaActualStr;
          await _notificationService.mostrarNotificacionEstiloWhatsapp(cita);
          print("¡Notificación simple de Cita Médica enviada!");
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
