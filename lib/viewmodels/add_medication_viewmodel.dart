import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddMedicationViewModel extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();

  // Paso 1: nombre y dosis
  String _nombre = '';
  String _dosis = '';
  String? _errorNombre;
  String? _errorDosis;

  // Paso 2: fecha y hora
  DateTime? _fecha;
  TimeOfDay _hora = const TimeOfDay(hour: 8, minute: 0);

  // Paso 3: intervalo
  String _intervalo = 'Cada 24 horas';
  final List<String> intervalos = [
    'Cada 24 horas',
    'Cada 12 horas',
    'Cada 8 horas',
    'Cada 6 horas',
    'Cada 4 horas',
    'Cada 3 horas',
    'Cada 2 horas',
    'Cada hora',
  ];

  //  Paso 4: instrucciones y fotos
  String _instrucciones = '';
  XFile? _fotoCaja;
  XFile? _fotoRemedio;

  // Getters
  String get nombre => _nombre;
  String get dosis => _dosis;
  String? get errorNombre => _errorNombre;
  String? get errorDosis => _errorDosis;

  DateTime? get fecha => _fecha;
  TimeOfDay get hora => _hora;

  String get intervalo => _intervalo;

  String get instrucciones => _instrucciones;
  XFile? get fotoCaja => _fotoCaja;
  XFile? get fotoRemedio => _fotoRemedio;

  // Texto de fecha para mostrar en pantalla
  String get fechaTexto {
    if (_fecha == null) return 'Seleccionar';
    final hoy = DateTime.now();
    final manana = DateTime(hoy.year, hoy.month, hoy.day + 1);
    final seleccionada = DateTime(_fecha!.year, _fecha!.month, _fecha!.day);

    if (seleccionada == DateTime(hoy.year, hoy.month, hoy.day)) return 'HOY';
    if (seleccionada == manana) return 'MAÑANA';

    return '${_fecha!.day}/${_fecha!.month}/${_fecha!.year}';
  }

  // Texto de hora para mostrar en pantalla
  String get horaTexto {
    final h = _hora.hour.toString().padLeft(2, '0');
    final m = _hora.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  // Setters paso 1
  void setNombre(String value) {
    _nombre = value;
    _errorNombre = null;
    notifyListeners();
  }

  void setDosis(String value) {
    _dosis = value;
    _errorDosis = null;
    notifyListeners();
  }

  // Setters paso 2
  void setFecha(DateTime fecha) {
    _fecha = fecha;
    notifyListeners();
  }

  void setHora(TimeOfDay hora) {
    _hora = hora;
    notifyListeners();
  }

  // Setters paso 3
  void setIntervalo(String value) {
    _intervalo = value;
    notifyListeners();
  }

  //Setters paso 4
  void setInstrucciones(String value) {
    _instrucciones = value;
    notifyListeners();
  }

  //Foto desde galería o cámara
  Future<XFile?> tomarFoto(ImageSource source) async {
    final foto = await _picker.pickImage(source: source);
    return foto;
  }

  void setFotoCaja(XFile? foto) {
    _fotoCaja = foto;
    notifyListeners();
  }

  void setFotoRemedio(XFile? foto) {
    _fotoRemedio = foto;
    notifyListeners();
  }

  // Validación paso 1
  bool validarPaso1() {
    bool valido = true;

    if (_nombre.isEmpty) {
      _errorNombre = 'Ingrese el nombre del medicamento';
      valido = false;
    }
    if (_dosis.isEmpty) {
      _errorDosis = 'Ingrese la dosis';
      valido = false;
    }

    notifyListeners();
    return valido;
  }

  // Guardar medicamento
  Future<void> guardar() async {
    // TODO: conectar con Railway
    await Future.delayed(const Duration(seconds: 1));
  }
}