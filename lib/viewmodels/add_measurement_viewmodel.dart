import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/medicion_service.dart';


class AddMeasurementViewModel extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();

  // Paso 1: tipo de medición
  String _tipoMedicion = '';
  String? _errorTipoMedicion;

  // Lista de mediciones disponibles
  final List<String> tiposMedicion = [
    'Presión arterial',
    'Next',
  ];

  // Paso 2: recordatorio (múltiples horas)
  DateTime? _fecha;
  List<TimeOfDay> _horas = [const TimeOfDay(hour: 8, minute: 0)];

  // Paso 3: fecha y hora de la primera medición
  DateTime? _fechaPrimera;
  TimeOfDay _horaPrimera = const TimeOfDay(hour: 8, minute: 0);

  // Paso 4: instrucciones y foto del instrumento
  String _instrucciones = '';
  XFile? _fotoInstrumento;

  // Getters paso 1
  String get tipoMedicion => _tipoMedicion;
  String? get errorTipoMedicion => _errorTipoMedicion;

  // Getters paso 2
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

  // Getters paso 3
  DateTime? get fechaPrimera => _fechaPrimera;
  TimeOfDay get horaPrimera => _horaPrimera;

  String get fechaPrimeraTexto {
    if (_fechaPrimera == null) return 'MAÑANA';
    final hoy = DateTime.now();
    final manana = DateTime(hoy.year, hoy.month, hoy.day + 1);
    final seleccionada =
    DateTime(_fechaPrimera!.year, _fechaPrimera!.month, _fechaPrimera!.day);
    if (seleccionada == DateTime(hoy.year, hoy.month, hoy.day)) return 'HOY';
    if (seleccionada == manana) return 'MAÑANA';
    return '${_fechaPrimera!.day}/${_fechaPrimera!.month}/${_fechaPrimera!.year}';
  }

  String get horaPrimeraTexto {
    final h = _horaPrimera.hour.toString().padLeft(2, '0');
    final m = _horaPrimera.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  // Getters paso 4
  String get instrucciones => _instrucciones;
  XFile? get fotoInstrumento => _fotoInstrumento;

  // Setters paso 1
  void setTipoMedicion(String value) {
    _tipoMedicion = value;
    _errorTipoMedicion = null;
    notifyListeners();
  }

  // Setters paso 2
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
      notifyListeners();
    }
  }

  // Setters paso 3
  void setFechaPrimera(DateTime fecha) {
    _fechaPrimera = fecha;
    notifyListeners();
  }

  void setHoraPrimera(TimeOfDay hora) {
    _horaPrimera = hora;
    notifyListeners();
  }

  // Setters paso 4
  void setInstrucciones(String value) {
    _instrucciones = value;
    notifyListeners();
  }

  Future<XFile?> tomarFoto(ImageSource source) async {
    final foto = await _picker.pickImage(source: source);
    return foto;
  }

  void setFotoInstrumento(XFile? foto) {
    _fotoInstrumento = foto;
    notifyListeners();
  }

  // Validaciones
  bool validarPaso1() {
    bool valido = true;
    if (_tipoMedicion.isEmpty) {
      _errorTipoMedicion = 'Seleccione un tipo de medición';
      valido = false;
    }
    notifyListeners();
    return valido;
  }

  // Guardar
  Future<void> guardar() async {
    final MedicionService _medicionService = MedicionService();

    Future<void> guardar() async {
      // Convierte las horas a formato "HH:mm"
      final horasFormateadas = _horas.map((h) {
        final hora = h.hour.toString().padLeft(2, '0');
        final min = h.minute.toString().padLeft(2, '0');
        return '$hora:$min';
      }).toList();

      await _medicionService.crearMedicion(
        tipoMedicion: _tipoMedicion,
        horas: horasFormateadas,
        fecha: _fecha,
        instrucciones: _instrucciones.isNotEmpty ? _instrucciones : null,
      );
    }
    await Future.delayed(const Duration(seconds: 1));
  }
}