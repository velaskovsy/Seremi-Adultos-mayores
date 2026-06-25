// lib/viewmodels/add_medication_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
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
  String? _errorHora;
  String? get errorHora => _errorHora;

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

  // Edición: si no es null, guardar() actualiza este grupo en vez de crear uno nuevo
  String? _grupoIdEditando;

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

  bool get guardando => _guardando;
  String? get errorGuardar => _errorGuardar;
  bool get modoEdicion => _grupoIdEditando != null;

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
    if (hora.hour < 6 || hora.hour >= 23) {
      _errorHora = 'Solo puedes programar entre las 6:00 y las 23:00 hrs';
      notifyListeners();
      return;
    }
    _errorHora = null;
    _hora = hora;
    notifyListeners();
  }

  // Setters paso 3

  void setIntervalo(String value) {
    _intervalo = value;
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

  void setFotoCaja(XFile? foto) {
    _fotoCaja = foto;
    notifyListeners();
  }

  void setFotoRemedio(XFile? foto) {
    _fotoRemedio = foto;
    notifyListeners();
  }

  int _obtenerHorasIntervalo(String textoIntervalo) {
    switch (textoIntervalo) {
      case 'Cada hora':     return 1;
      case 'Cada 2 horas':   return 2;
      case 'Cada 3 horas':   return 3;
      case 'Cada 4 horas':   return 4;
      case 'Cada 6 horas':   return 6;
      case 'Cada 8 horas':   return 8;
      case 'Cada 12 horas':  return 12;
      case 'Cada 24 horas':  return 24;
      default:               return 24; // Por defecto un día
    }
  }

  // Precarga de datos para editar un grupo existente

  void cargarParaEditar({
    required String grupoId,
    required String nombre,
    required String dosis,
    required String hora,
    String? intervalo,
    String? instrucciones,
  }) {
    _grupoIdEditando = grupoId;
    _nombre = nombre;
    _dosis = dosis;

    final partes = hora.split(':');
    _hora = TimeOfDay(
      hour: int.tryParse(partes[0]) ?? 8,
      minute: int.tryParse(partes.length > 1 ? partes[1] : '0') ?? 0,
    );

    if (intervalo != null && intervalos.contains(intervalo)) {
      _intervalo = intervalo;
    }
    _instrucciones = instrucciones ?? '';
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

  // Guardar: sube fotos a Supabase y guarda en Railway
  // Si _grupoIdEditando no es null, reemplaza ese grupo (editar);
  // si es null, crea un grupo nuevo (alta normal).

  Future<bool> guardar() async {
    _guardando = true;
    _errorGuardar = null;
    notifyListeners();

    // 1. Subir fotos a Supabase (opcionales)
    String? urlFotoCaja;
    String? urlFotoRemedio;

    if (_fotoCaja != null) {
      urlFotoCaja = await _storageService.subirFoto(_fotoCaja!, 'medicamentos');
    }
    if (_fotoRemedio != null) {
      urlFotoRemedio = await _storageService.subirFoto(_fotoRemedio!, 'medicamentos');
    }

    // 2. Establecer la fecha y hora inicial combinadas
    // Si _fecha es null por alguna razón, usamos el día de hoy
    final fechaBase = _fecha ?? DateTime.now();
    DateTime fechaRegistroActual = DateTime(
      fechaBase.year,
      fechaBase.month,
      fechaBase.day,
      _hora.hour,
      _hora.minute,
    );

    // 3. Definir el límite temporal (1 semana desde la fecha inicial)
    final DateTime fechaLimite = fechaRegistroActual.add(const Duration(days: 7));

    // 4. Obtener las horas que se deben sumar en cada ciclo
    int horasASumar = _obtenerHorasIntervalo(_intervalo);

    // 5. Un solo grupo_id para todas las tomas de este medicamento.
    //    En edición se reutiliza el mismo grupo; en alta se genera uno nuevo.
    final String grupoId = _grupoIdEditando ?? const Uuid().v4();

    bool todosExitosos = true;
    bool esPrimeraIteracion = true;

    // 6. Bucle iterativo para generar y guardar los registros
    while (fechaRegistroActual.isBefore(fechaLimite)) {

      // Formateamos la hora en formato HH:mm para el registro individual actual
      final h = fechaRegistroActual.hour.toString().padLeft(2, '0');
      final m = fechaRegistroActual.minute.toString().padLeft(2, '0');
      final String horaFormateada = '$h:$m';

      bool exitoRegistro;

      if (_grupoIdEditando != null && esPrimeraIteracion) {
        // La primera toma reemplaza (PUT) todas las tomas futuras del grupo
        exitoRegistro = await _medicamentoService.editarGrupoMedicamento(
          grupoId: grupoId,
          nombre: _nombre,
          dosis: _dosis,
          hora: horaFormateada,
          fecha: fechaRegistroActual,
          intervalo: _intervalo,
          instrucciones: _instrucciones.trim().isNotEmpty ? _instrucciones : null,
          urlFotoCaja: urlFotoCaja,
          urlFotoRemedio: urlFotoRemedio,
        );
      } else {
        // El resto de las tomas (o todas, si es alta nueva) se crean normalmente
        exitoRegistro = await _medicamentoService.crearMedicamento(
          nombre: _nombre,
          dosis: _dosis,
          hora: horaFormateada,
          grupoId: grupoId,
          fecha: fechaRegistroActual,
          intervalo: _intervalo,
          instrucciones: _instrucciones.trim().isNotEmpty ? _instrucciones : null,
          urlFotoCaja: urlFotoCaja,
          urlFotoRemedio: urlFotoRemedio,
        );
      }

      esPrimeraIteracion = false;

      if (!exitoRegistro) {
        todosExitosos = false;
      }

      // El motor de Dart avanza la fecha automáticamente controlando cambios de día/mes
      fechaRegistroActual = fechaRegistroActual.add(Duration(hours: horasASumar));
    }

    _guardando = false;
    if (!todosExitosos) {
      _errorGuardar = 'Algunos recordatorios no se pudieron guardar de forma completa.';
    }
    notifyListeners();

    return todosExitosos;
  }
}