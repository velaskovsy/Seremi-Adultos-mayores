import 'package:flutter/material.dart';
import '../services/recordatorio_service.dart';

class HomeViewModel extends ChangeNotifier {
  final RecordatorioService _service = RecordatorioService();

  RecordatoriosHoy? _data;
  bool    _isLoading = false;
  String? _error;

  RecordatoriosHoy? get data      => _data;
  bool              get isLoading => _isLoading;
  String?           get error     => _error;

  String get proximaTarea {
    if (_data?.proximaTarea == null) return '--:--';
    return _data!.proximaTarea!;
  }

  Future<void> cargar() async {
    _isLoading = true;
    _error     = null;
    notifyListeners();

    final result = await _service.obtenerHoy();

    _isLoading = false;
    if (result != null) {
      _data  = result;
      _error = null;
    } else {
      _error = 'No se pudieron cargar los recordatorios';
    }
    notifyListeners();
  }
}