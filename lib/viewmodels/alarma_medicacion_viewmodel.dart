import 'package:flutter/material.dart';
// Asegúrate de importar correctamente tus servicios:
import '../services/recordatorio_service.dart';
import '../services/notificacion_service.dart';

class AlarmViewModel extends ChangeNotifier {
  final RecordatorioService _recordatorioService = RecordatorioService();
  final NotificationService _notificationService = NotificationService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Método principal que descarga los datos y activa las alarmas
  Future<void> sincronizarAlarmasDelDia() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Obtenemos la lista que ya filtramos en el servicio
      final listadoMedicamentos = await _recordatorioService.obtenerSoloMedicamentos();

      // 2. Revisamos los horarios de cada medicamento
      for (var medicamento in listadoMedicamentos) {
        final String horaStr = medicamento['hora'] ?? ''; // Ej: "14:30"
        if (horaStr.isEmpty) continue;

        // Convertimos el String "14:30" a un objeto DateTime real de hoy
        final partes = horaStr.split(':');
        final DateTime ahora = DateTime.now();
        final DateTime horaAlarma = DateTime(
            ahora.year, ahora.month, ahora.day,
            int.parse(partes[0]), int.parse(partes[1])
        );

        // Si la hora de la pastilla aún no ha pasado, programamos el salto de pantalla
        if (horaAlarma.isAfter(ahora)) {
          await _notificationService.dispararNotificacionPantallaCompleta(medicamento);
        }
      }
    } catch (e) {
      print("Error en AlarmViewModel: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}