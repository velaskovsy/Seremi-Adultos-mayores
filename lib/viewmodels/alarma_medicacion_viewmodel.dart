import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:seremi_adultos_mayores/main.dart';
import '../services/recordatorio_service.dart';
import '../services/notificacion_service.dart';
import '../views/alarma_medicacion/alarma_medicacion_screen.dart';
import '../views/alarma_presion/alarma_presion_screen.dart'; // Tu nueva interfaz del mockup
import 'package:flutter/services.dart';

class AlarmViewModel extends ChangeNotifier {
  final RecordatorioService _recordatorioService = RecordatorioService();
  final NotificationService _notificationService = NotificationService();

  static List<String> alarmasSilenciadas = [];
  static bool pantallaAlarmaAbierta = false;

  static final DateTime tiempoInicioApp = DateTime.now();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  static const platform = MethodChannel('salud_mayor/alarma');

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
      final String fechaHoy = DateFormat('yyyy-MM-dd').format(ahora); // 👈 NUEVO

      // 👈 CARGAMOS EL DISCO DURO
      final prefs = await SharedPreferences.getInstance();

      // ==========================================
      // BARRIDO 1: BUSCAR MEDICAMENTOS
      // ==========================================
      final listadoMedicamentos = await _recordatorioService.obtenerSoloMedicamentos();
      for (var medicamento in listadoMedicamentos) {
        final String hora = medicamento['hora'] ?? '';
        final int id = medicamento['id'] ?? 0;
        final String llaveUnica = "med_$id";

        // Revisar la RAM y el Disco Duro
        bool yaTomadaHoy = prefs.getBool("${llaveUnica}_$fechaHoy") ?? false;
        if (yaTomadaHoy || AlarmViewModel.alarmasSilenciadas.contains(llaveUnica)) {
          continue; // Si ya la tomó hoy físicamente, la ignoramos para siempre
        }

        if (hora.isNotEmpty) {
          final partes = hora.split(':');
          if (partes.length == 2) {
            DateTime horaProgramada = DateTime(ahora.year, ahora.month, ahora.day, int.parse(partes[0]), int.parse(partes[1]));

            if (horaProgramada.isBefore(AlarmViewModel.tiempoInicioApp)) {
              continue;
            }

            // 👇 EL PARCHE: Creamos un "ahora" pero le ponemos los segundos en CERO
            DateTime ahoraLimpio = DateTime(ahora.year, ahora.month, ahora.day, ahora.hour, ahora.minute);

            // Si todavía no es la hora, saltamos inmediatamente para evitar disparos en el min 59
            if (ahoraLimpio.isBefore(horaProgramada)) continue;

            // Ahora sí hacemos la resta matemática segura
            int difMinutos = ahoraLimpio.difference(horaProgramada).inMinutes;

            // BUCLE INFINITO (RF-04)
            // difMinutos >= 0 : Que sea de ahora o del pasado.
            // difMinutos <= 30 : ¡EL LÍMITE! Si pasaron más de 30 minutos, ya fue, no la dispares.
            // difMinutos % 5 == 0 : Insiste cada 5 minutos dentro de ese margen.
            if (difMinutos >= 0 && difMinutos <= 30 && difMinutos % 1 == 0) {

              String llaveDisparo = "${llaveUnica}_$difMinutos";

              // 2. EL FRENO ANTI-DOMINÓ: Si ya disparamos esta alarma en este minuto, detenemos TODO el bucle.
              if (_alarmasDisparadas[llaveDisparo] == horaActualStr) {
                break;
              }

              _alarmasDisparadas[llaveDisparo] = horaActualStr;

              try {
                await platform.invokeMethod('traerAlFrente');
              } catch (e) {
                print("No se pudo maximizar la app: $e");
              }

              NotificationService.ultimoIdProcesado = id;
              await _notificationService.dispararNotificacionPantallaCompleta(medicamento);

              if (!AlarmViewModel.pantallaAlarmaAbierta) {
                // 👇 3. CERRAMOS EL CANDADO INMEDIATAMENTE ANTES DE DIBUJAR
                AlarmViewModel.pantallaAlarmaAbierta = true;

                navigatorKey.currentState?.push(
                    MaterialPageRoute(builder: (_) => AlarmScreen(medicamento: medicamento))
                );
              } else {
                print("La pantalla ya está abierta, solo sonará el aviso.");
              }
              print("¡Alarma lanzada! (Minuto de reintento: $difMinutos)");

              // 👇 4. EL FRENO ANTI-METRALLETA: Rompemos el bucle for. Solo procesamos UNA pastilla a la vez.
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

        // 👇 LA NUEVA REGLA: Revisar la RAM y el Disco Duro 👇
        bool yaTomadaHoy = prefs.getBool("${llaveUnica}_$fechaHoy") ?? false;
        if (yaTomadaHoy || AlarmViewModel.alarmasSilenciadas.contains(llaveUnica)) {
          continue; // Si ya la tomó hoy físicamente, la ignoramos para siempre
        }

        if (hora.isNotEmpty) {
          final partes = hora.split(':');
          if (partes.length == 2) {
            DateTime horaProgramada = DateTime(ahora.year, ahora.month, ahora.day, int.parse(partes[0]), int.parse(partes[1]));

            // 👇 EL ESCUDO DE DESTRUCCIÓN MASIVA 👇
            // Ignora alarmas del pasado previas a abrir la app
            if (horaProgramada.isBefore(AlarmViewModel.tiempoInicioApp)) {
              continue;
            }

            DateTime ahoraLimpio = DateTime(ahora.year, ahora.month, ahora.day, ahora.hour, ahora.minute);

            if (ahoraLimpio.isBefore(horaProgramada)) continue;

            int difMinutos = ahoraLimpio.difference(horaProgramada).inMinutes;

            // 👇 EL MURO Y EL BUCLE PARA LA PRESIÓN
            // (Ojo: Lo tienes configurado en <= 1 para tus pruebas. Para producción súbelo a <= 30)
            if (difMinutos >= 0 && difMinutos <= 1 && difMinutos % 1 == 0) {

              String llaveDisparo = "${llaveUnica}_$difMinutos";

              // Freno anti-dominó
              if (_alarmasDisparadas[llaveDisparo] == horaActualStr) {
                break;
              }
              _alarmasDisparadas[llaveDisparo] = horaActualStr;

              try {
                await platform.invokeMethod('traerAlFrente');
              } catch (e) {
                print("No se pudo maximizar la app: $e");
              }

              NotificationService.ultimoIdProcesado = id;
              await _notificationService.dispararNotificacionPantallaCompleta(medicion);

              // 👇 EL CANDADO
              if (!AlarmViewModel.pantallaAlarmaAbierta) {
                AlarmViewModel.pantallaAlarmaAbierta = true;

                navigatorKey.currentState?.push(
                  MaterialPageRoute(builder: (_) => AlarmaMedicionScreen(medicion: medicion)),
                );
              } else {
                print("La pantalla de presión ya está abierta, solo sonará el aviso.");
              }

              print("¡Alarma de Presión lanzada! (Minuto de reintento: $difMinutos)");

              // Freno anti-metralleta
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

          // Dispara el mensaje estilo WhatsApp. ¡Sin abrir pantallas!
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

          // Reutilizamos exactamente la misma función de notificación simple que usamos para el agua
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