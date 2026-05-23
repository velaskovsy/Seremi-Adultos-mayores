// lib/viewmodels/add_medication_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/medicamento_service.dart';
import '../services/storage_service.dart';

class AddMedicationViewModel extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();
  final MedicamentoService _medicamentoService = MedicamentoService();
  final StorageService _storageService = StorageService();

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

  // Paso 4: instrucciones y fotos
  String _instrucciones = '';
  XFile? _fotoCaja;
  XFile? _fotoRemedio;

  // Estado de carga
  bool _guardando = false;
  String? _errorGuardar;

  // ─── Getters ──────────────────────────────────────────────

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

  bool get guardando => _guardando;
  String? get errorGuardar => _errorGuardar;

  String get fechaTexto {
    if (_fecha == null) return 'Seleccionar';
    final hoy = DateTime.now();
    final manana = DateTime(hoy.year, hoy.month, hoy.day + 1);
    final seleccionada = DateTime(_fecha!.year, _fecha!.month, _fecha!.day);
    if (seleccionada == DateTime(hoy.year, hoy.month, hoy.day)) return 'HOY';
    if (seleccionada == manana) return 'MAÑANA';
    return '${_fecha!.day}/${_fecha!.month}/${_fecha!.year}';
  }

  String get horaTexto {
    final h = _hora.hour.toString().padLeft(2, '0');
    final m = _hora.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  // ─── Setters paso 1 ───────────────────────────────────────

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

  // ─── Setters paso 2 ───────────────────────────────────────

  void setFecha(DateTime fecha) {
    _fecha = fecha;
    notifyListeners();
  }

  void setHora(TimeOfDay hora) {
    _hora = hora;
    notifyListeners();
  }

  // ─── Setters paso 3 ───────────────────────────────────────

  void setIntervalo(String value) {
    _intervalo = value;
    notifyListeners();
  }

  // ─── Setters paso 4 ───────────────────────────────────────

  void setInstrucciones(String value) {
    _instrucciones = value;
    notifyListeners();
  }

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

  // ─── Validación paso 1 ────────────────────────────────────

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

  // ─── Guardar: sube fotos a Supabase y guarda en Railway ───

  Future<bool> guardar() async {
    _guardando = true;
    _errorGuardar = null;
    notifyListeners();

    // Subir fotos a Supabase (opcionales)
    String? urlFotoCaja;
    String? urlFotoRemedio;

    if (_fotoCaja != null) {
      urlFotoCaja = await _storageService.subirFoto(_fotoCaja!, 'medicamentos');
    }
    if (_fotoRemedio != null) {
      urlFotoRemedio = await _storageService.subirFoto(_fotoRemedio!, 'medicamentos');
    }

    final exito = await _medicamentoService.crearMedicamento(
      nombre: _nombre,
      dosis: _dosis,
      hora: horaTexto,
      fecha: _fecha,
      intervalo: _intervalo,
      instrucciones: _instrucciones.trim().isNotEmpty ? _instrucciones : null,
      urlFotoCaja: urlFotoCaja,
      urlFotoRemedio: urlFotoRemedio,
    );

    _guardando = false;
    if (!exito) {
      _errorGuardar = 'No se pudo guardar. Verifica tu conexión e intenta de nuevo.';
    }
    notifyListeners();

    return exito;
  }
}
