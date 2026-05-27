import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import '../services/recordatorio_service.dart';

class AlarmViewModel extends ChangeNotifier {
  final RecordatorioService _recordatorioService = RecordatorioService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Cancela todas las alarmas anteriores y programa las del día actual
  Future<void> sincronizarAlarmasDelDia() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Cancelar todas las alarmas anteriores para no duplicar
      final alarmasActivas = await Alarm.getAlarms();
      for (final alarma in alarmasActivas) {
        await Alarm.stop(alarma.id);
      }

      // 2. Obtener lista de medicamentos del día desde el servidor
      final listadoMedicamentos = await _recordatorioService.obtenerSoloMedicamentos();

      // 3. Programar una alarma real para cada medicamento
      for (var medicamento in listadoMedicamentos) {
        final String horaStr = medicamento['hora'] ?? '';
        if (horaStr.isEmpty) continue;

        final partes = horaStr.split(':');
        if (partes.length < 2) continue;

        final DateTime ahora = DateTime.now();
        DateTime horaAlarma = DateTime(
          ahora.year,
          ahora.month,
          ahora.day,
          int.parse(partes[0]),
          int.parse(partes[1]),
        );

        // Si la hora ya pasó hoy, no programar
        if (!horaAlarma.isAfter(ahora)) continue;

        // Usamos el id numérico del medicamento; si no existe generamos uno
        final int alarmaId = (medicamento['id'] is int)
            ? medicamento['id'] as int
            : medicamento['id'].toString().hashCode.abs() % 100000;

        final alarmSettings = AlarmSettings(
          id: alarmaId,
          dateTime: horaAlarma,
          assetAudioPath: 'assets/sonidos/alarma.mp3',
          loopAudio: true,
          vibrate: true,
          warningNotificationOnKill: true,
          androidFullScreenIntent: true,
          notificationSettings: NotificationSettings(
            title: '¡Hora de tu medicación!',
            body: 'Debes tomar: ${medicamento['nombre'] ?? 'Medicamento'}',
            stopButton: 'Detener alarma',
            icon: 'notification_icon',
          ),
        );

        await Alarm.set(alarmSettings: alarmSettings);
      }
    } catch (e) {
      debugPrint('Error en AlarmViewModel: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}