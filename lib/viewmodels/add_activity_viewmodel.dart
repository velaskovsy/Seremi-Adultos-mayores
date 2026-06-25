// lib/viewmodels/add_activity_viewmodel.dart
import 'package:flutter/material.dart';
import '../services/activity_service.dart';

class AddActivityViewModel extends ChangeNotifier {

  // ── Paso 1: tipo de actividad ────────────────────────────
  String _tipoActividad = '';
  String? _errorTipoActividad;

  final List<String> tiposActividad = [
    'Hidratarse',
    // TODO: agregar más actividades aquí
  ];

  // Paso 2: fecha y horas
  DateTime? _fecha;
  List<TimeOfDay> _horas = [const TimeOfDay(hour: 8, minute: 0)];

  // ── Paso 3: cantidad por hora (solo Hidratarse por ahora) ─
  // Mapa de índice de hora → cantidad de vasos
  Map<int, String> _cantidadPorHora = {};

  final List<String> opcionesVasos = [
    '1 vaso',
    '2 vasos',
    '3 vasos',
    '4 vasos',
    '5 vasos',
    '6 vasos',
  ];

  // Estado de carga
  bool _guardando = false;

  // ── Getters paso 1 ───────────────────────────────────────
  String get tipoActividad => _tipoActividad;
  String? get errorTipoActividad => _errorTipoActividad;

  // ── Getters paso 2 ───────────────────────────────────────
  DateTime? get fecha => _fecha;
  List<TimeOfDay> get horas => List.unmodifiable(_horas);

  String get fechaTexto {
    if (_fecha == null) return 'MAÑANA';
    final hoy = DateTime.now();
    final manana = DateTime(hoy.year, hoy.month, hoy.day + 1);
    final seleccionada = DateTime(_fecha!.year, _fecha!.month, _fecha!.day);
    if (seleccionada == DateTime(hoy.year, hoy.month, hoy.day)) return 'HOY';
    if (seleccionada == manana) return 'MAÑANA';
    return '${_fecha!.day}/${_fecha!.month}/${_fecha!.year}';
  }

  String horaTexto(TimeOfDay hora) {
    final h = hora.hour.toString().padLeft(2, '0');
    final m = hora.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  // ── Getters paso 3 ───────────────────────────────────────
  Map<int, String> get cantidadPorHora => Map.unmodifiable(_cantidadPorHora);
  bool get guardando => _guardando;

  String cantidadEnIndice(int index) {
    return _cantidadPorHora[index] ?? '1 vaso';
  }

  // ── Setters paso 1 ───────────────────────────────────────
  void setTipoActividad(String value) {
    _tipoActividad = value;
    _errorTipoActividad = null;
    notifyListeners();
  }

  // ── Setters paso 2 ───────────────────────────────────────
  void setFecha(DateTime fecha) {
    _fecha = fecha;
    notifyListeners();
  }

  void setHoraEnIndice(int index, TimeOfDay hora) {
    if (index >= 0 && index < _horas.length) {
      _horas[index] = hora;
      notifyListeners();
    }
  }

  void agregarHora() {
    _horas.add(const TimeOfDay(hour: 8, minute: 0));
    notifyListeners();
  }

  void eliminarHora(int index) {
    if (_horas.length > 1) {
      _horas.removeAt(index);
      _cantidadPorHora.remove(index);
      // Reordena el mapa
      final nuevo = <int, String>{};
      _cantidadPorHora.forEach((k, v) {
        if (k < index) nuevo[k] = v;
        if (k > index) nuevo[k - 1] = v;
      });
      _cantidadPorHora = nuevo;
      notifyListeners();
    }
  }

  // ── Setters paso 3 ───────────────────────────────────────
  void setCantidadEnIndice(int index, String cantidad) {
    _cantidadPorHora[index] = cantidad;
    notifyListeners();
  }

  // ── Validaciones ─────────────────────────────────────────
  bool validarPaso1() {
    if (_tipoActividad.isEmpty) {
      _errorTipoActividad = 'Seleccione una actividad';
      notifyListeners();
      return false;
    }
    return true;
  }

// ── Guardar: conectado a Railway ─────────────────────────
  Future<bool> guardar() async {
    _guardando = true;
    notifyListeners();

    // Convierte horas a "HH:mm" y construye mapa hora → cantidad
    final horasFormateadas = <String>[];
    final cantidadMapeada = <String, String>{};

    for (int i = 0; i < _horas.length; i++) {
      final horaStr = horaTexto(_horas[i]);
      horasFormateadas.add(horaStr);

      // 👇 LA CORRECCIÓN 👇
      // Si el usuario no tocó nada (no existe en el mapa), obligamos a que se
      // guarde el valor por defecto que estaba viendo en la pantalla.
      final String cantidadSeleccionada = _cantidadPorHora[i] ?? '1 vaso';
      cantidadMapeada[horaStr] = cantidadSeleccionada;
    }

    final exito = await ActivityService().crearActividad(
      tipoActividad: _tipoActividad,
      horas: horasFormateadas,
      fecha: _fecha,
      cantidadPorHora: cantidadMapeada.isNotEmpty ? cantidadMapeada : null,
    );

    _guardando = false;
    notifyListeners();

    return exito;
  }
}
