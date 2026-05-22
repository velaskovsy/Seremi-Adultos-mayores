import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';

class AlarmaViewModel extends ChangeNotifier {
  final int alarmaId;
  final String medicamento;
  final String dosis;
  final String instruccion;
  final String hora;

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  AlarmaViewModel({
    required this.alarmaId,
    required this.medicamento,
    required this.dosis,
    required this.instruccion,
    required this.hora,
  });

  /// Acción principal: Detiene la alarma física y procesa la confirmación
  Future<bool> registrarToma() async {
    if (_isProcessing) return false;

    _isProcessing = true;
    notifyListeners();

    try {
      // 1. Detener el sonido y vibración del teléfono de forma nativa
      await Alarm.stop(alarmaId);

      // 2. Aquí puedes añadir tu lógica de SQLite para guardar el historial
      // await _dbHelper.marcarComoTomado(alarmaId, DateTime.now());

      _isProcessing = false;
      notifyListeners();
      return true; // Éxito
    } catch (e) {
      _isProcessing = false;
      notifyListeners();
      return false; // Error
    }
  }
}