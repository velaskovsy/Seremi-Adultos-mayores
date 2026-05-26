import 'package:flutter/material.dart';
import '../services/recordatorio_service.dart';

class HomeViewModel extends ChangeNotifier {

  final RecordatorioService _service = RecordatorioService();

  Map<String, dynamic>? data;

  bool isLoading = false;

  Future<void> cargar() async {

    isLoading = true;
    notifyListeners();

    data = await _service.obtenerHoy();

    isLoading = false;
    notifyListeners();
  }
}