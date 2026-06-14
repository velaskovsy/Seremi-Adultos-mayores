// lib/viewmodels/calendario_viewmodel.dart
import 'package:flutter/material.dart';
import '../services/recordatorio_service.dart';

class CalendarioViewModel extends ChangeNotifier {
  final RecordatorioService _service = RecordatorioService();

  DateTime _diaSeleccionado = DateTime.now();
  DateTime _diaFocuseado    = DateTime.now();
  Set<String> _diasConEventos = {};
  List<Map<String, dynamic>> _eventosDelDiaSeleccionado = [];

  bool _cargandoCalendario = true;
  bool _cargandoDia        = false;

  // ── Getters para que la vista los lea ─────────────────────────
  DateTime get diaSeleccionado => _diaSeleccionado;
  DateTime get diaFocuseado => _diaFocuseado;
  List<Map<String, dynamic>> get eventosDelDiaSeleccionado => _eventosDelDiaSeleccionado;
  bool get cargandoCalendario => _cargandoCalendario;
  bool get cargandoDia => _cargandoDia;

  // Al nacer el ViewModel, cargamos los datos inmediatamente
  CalendarioViewModel() {
    cargarPuntitos(_diaFocuseado);
    cargarDia(_diaSeleccionado);
  }

  // ── Helpers de formato internos ───────────────────────────────
  String _formatearFecha(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  (DateTime, DateTime) _rangoParaMes(DateTime mes) {
    final desde = DateTime(mes.year, mes.month - 1, 1);
    final hasta  = DateTime(mes.year, mes.month + 2, 0);
    return (desde, hasta);
  }

  // Función para que el calendario sepa si poner un puntito
  bool tieneEventos(DateTime dia) {
    return _diasConEventos.contains(_formatearFecha(dia));
  }

  // ── Lógica de Negocio ─────────────────────────────────────────
  Future<void> cargarPuntitos(DateTime mes) async {
    _cargandoCalendario = true;
    notifyListeners();

    final rango = _rangoParaMes(mes);
    final dias = await _service.obtenerDiasConEventos(rango.$1, rango.$2);

    _diasConEventos = dias.toSet();
    _cargandoCalendario = false;
    notifyListeners();
  }

  Future<void> cargarDia(DateTime dia) async {
    _cargandoDia = true;
    _eventosDelDiaSeleccionado = [];
    notifyListeners();

    final data = await _service.obtenerDia(dia);

    final List<Map<String, dynamic>> eventos = [];
    if (data != null) {
      final franjas = data['franjas'] as Map<String, dynamic>;
      for (final franja in ['manana', 'tarde', 'noche']) {
        final lista = franjas[franja] as List<dynamic>? ?? [];
        eventos.addAll(lista.map((e) => Map<String, dynamic>.from(e as Map)));
      }
      // Ordenar por hora ascendente
      eventos.sort((a, b) => (a['hora'] as String).compareTo(b['hora'] as String));
    }

    _eventosDelDiaSeleccionado = eventos;
    _cargandoDia = false;
    notifyListeners();
  }

  // ── Interacciones del usuario ─────────────────────────────────
  void cambiarMes(DateTime nuevaFecha) {
    _diaFocuseado = nuevaFecha;
    cargarPuntitos(nuevaFecha);
  }

  void seleccionarDia(DateTime seleccionado, DateTime focuseado) {
    _diaSeleccionado = seleccionado;
    _diaFocuseado = focuseado;
    cargarDia(seleccionado);
  }
}