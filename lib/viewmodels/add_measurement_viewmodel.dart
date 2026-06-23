// lib/viewmodels/add_measurement_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/medicion_service.dart';
import '../services/storage_service.dart';
import '../services/alarm_scheduler_service.dart';

class AddMeasurementViewModel extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();
  final MedicionService _medicionService = MedicionService();
  final StorageService _storageService = StorageService();

  // Paso 1: tipo de medición
  String _tipoMedicion = '';
  String? _errorTipoMedicion;

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

  // Estado de carga
  bool _guardando = false;
  String? _errorGuardar;

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
  bool get guardando => _guardando;
  String? get errorGuardar => _errorGuardar;

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

  // ─── Guardar: Modificado para enviar 7 días (cada 24 horas) ────
  Future<bool> guardar() async {
    _guardando = true;
    _errorGuardar = null;
    notifyListeners();

    // 1. Subir la foto una sola vez (si existe) para no duplicar archivos en Supabase
    String? urlFoto;
    if (_fotoInstrumento != null) {
      urlFoto = await _storageService.subirFoto(_fotoInstrumento!, 'mediciones');
    }

    final horasFormateadas = _horas.map((h) {
      final hora = h.hour.toString().padLeft(2, '0');
      final min = h.minute.toString().padLeft(2, '0');
      return '$hora:$min';
    }).toList();

    bool todosExitosos = true;
    // Si _fecha es null, usamos la fecha de hoy por seguridad
    final DateTime fechaBase = _fecha ?? DateTime.now();

    // 2. Ciclo FOR para repetir el guardado por 7 días consecutivos
    for (int i = 0; i < 7; i++) {
      final DateTime fechaRecordatorio = fechaBase.add(Duration(days: i));

      // Formateo simple para el print en consola (YYYY-MM-DD)
      final String fechaString =
          '${fechaRecordatorio.year}-${fechaRecordatorio.month.toString().padLeft(2, '0')}-${fechaRecordatorio.day.toString().padLeft(2, '0')}';

      // ── DEBUG PRINTS EN CONSOLA ──
      debugPrint('==================================================');
      debugPrint('👉 ENVIANDO MEDICIÓN [Iteración ${i + 1} de 7]');
      debugPrint('📅 Fecha cálculo (+${i * 24} hrs): $fechaString');
      debugPrint('📋 Tipo:        $_tipoMedicion');
      debugPrint('⏰ Horas:       $horasFormateadas');
      debugPrint('📸 URL Foto:    $urlFoto');
      debugPrint('==================================================');

      final exito = await _medicionService.crearMedicion(
        tipoMedicion: _tipoMedicion,
        horas: horasFormateadas,
        fecha: fechaRecordatorio,
        instrucciones: _instrucciones.isNotEmpty ? _instrucciones : null,
        urlFoto: urlFoto,
      );

      if (exito) {
        debugPrint('✅ ¡Éxito! Registro para el día $fechaString guardado.\n');
      } else {
        todosExitosos = false;
        debugPrint('❌ ¡ERROR! Falló la inserción del día $fechaString.\n');
      }

      // Pequeña pausa de seguridad (200 milisegundos) para evitar colisiones en ráfaga
      await Future.delayed(const Duration(milliseconds: 200));
    }

    _guardando = false;
    if (!todosExitosos) {
      _errorGuardar = 'Algunos recordatorios no se pudieron guardar. Verifica tu conexión e intenta de nuevo.';
    }
    notifyListeners();

    // ─── NUEVO: Programar alarmas del SO para cada hora de medición ────────────
    if (todosExitosos) {
      try {
        for (final horaStr in horasFormateadas) {
          final int alarmId = (_tipoMedicion + horaStr).hashCode.abs() % 100000 + 500000;
          await AlarmSchedulerService().programarAlarma(
            id: alarmId,
            hora: horaStr,
            tipo: 'medicion',
            nombre: _tipoMedicion,
            repetirDiariamente: true,
          );
          print('✅ Alarma del SO programada para medición: $_tipoMedicion a las $horaStr');
        }
      } catch (e) {
        print('⚠️ No se pudo programar alarma del SO para medición: $e');
      }
    }
    // ──────────────────────────────────────────────────────────────────────────

    return todosExitosos;
  }
}