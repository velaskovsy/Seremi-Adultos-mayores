import 'package:flutter/material.dart';
import '../services/cita_medica_service.dart';

class AddAppointmentViewModel extends ChangeNotifier {
  final CitaMedicaService _service = CitaMedicaService();

  // ── Paso 1: fecha, hora y lugar ──────────────────────────
  DateTime? _fecha;
  TimeOfDay _hora = const TimeOfDay(hour: 8, minute: 0);
  String _lugar = '';
  String? _errorLugar;

  // ── Paso 2: profesional y notas ──────────────────────────
  String _profesional = '';
  String _notas = '';
  String? _errorProfesional;

  bool _guardando = false;
  String? _errorGuardar;

  // ── Getters paso 1 ───────────────────────────────────────
  DateTime? get fecha => _fecha;
  TimeOfDay get hora => _hora;
  String get lugar => _lugar;
  String? get errorLugar => _errorLugar;

  String get fechaTexto {
    if (_fecha == null) return 'Seleccionar';
    final hoy = DateTime.now();
    final manana = DateTime(hoy.year, hoy.month, hoy.day + 1);
    final sel = DateTime(_fecha!.year, _fecha!.month, _fecha!.day);
    if (sel == DateTime(hoy.year, hoy.month, hoy.day)) return 'HOY';
    if (sel == manana) return 'MAÑANA';
    return '${_fecha!.day.toString().padLeft(2, '0')}/${_fecha!.month.toString().padLeft(2, '0')}/${_fecha!.year.toString().substring(2)}';
  }

  String get horaTexto {
    final h = _hora.hour.toString().padLeft(2, '0');
    final m = _hora.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String get fechaISO {
    if (_fecha == null) return '';
    return '${_fecha!.year}-${_fecha!.month.toString().padLeft(2, '0')}-${_fecha!.day.toString().padLeft(2, '0')}';
  }

  // ── Getters paso 2 ───────────────────────────────────────
  String get profesional => _profesional;
  String get notas => _notas;
  String? get errorProfesional => _errorProfesional;
  bool get guardando => _guardando;
  String? get errorGuardar => _errorGuardar;

  // ── Setters paso 1 ───────────────────────────────────────
  void setFecha(DateTime fecha) {
    _fecha = fecha;
    notifyListeners();
  }

  void setHora(TimeOfDay hora) {
    _hora = hora;
    notifyListeners();
  }

  void setLugar(String value) {
    _lugar = value;
    _errorLugar = null;
    notifyListeners();
  }

  // ── Setters paso 2 ───────────────────────────────────────
  void setProfesional(String value) {
    _profesional = value;
    _errorProfesional = null;
    notifyListeners();
  }

  void setNotas(String value) {
    _notas = value;
    notifyListeners();
  }

  // ── Validación paso 1 ────────────────────────────────────
  bool validarPaso1() {
    bool valido = true;

    if (_fecha == null) {
      valido = false;
    }
    if (_lugar.trim().isEmpty) {
      _errorLugar = 'Ingrese el lugar de la cita';
      valido = false;
    }

    notifyListeners();
    return valido;
  }

  // ── Validación paso 2 ────────────────────────────────────
  bool validarPaso2() {
    if (_profesional.trim().isEmpty) {
      _errorProfesional = 'Ingrese el nombre del profesional';
      notifyListeners();
      return false;
    }
    return true;
  }

  // ── Guardar (Con Prints detallados por cada día) ─────────
  Future<bool> guardar() async {
    _guardando = true;
    _errorGuardar = null;
    notifyListeners();

    bool todosExitosos = true;

    for (int i = 0; i < 7; i++) {
      final DateTime fechaRecordatorio = _fecha!.add(Duration(days: i));

      // Formateamos la fecha en formato YYYY-MM-DD para el print
      final String fechaFormateada =
          '${fechaRecordatorio.year}-${fechaRecordatorio.month.toString().padLeft(2, '0')}-${fechaRecordatorio.day.toString().padLeft(2, '0')}';

      // ── PRINT DE CONTROL: Aquí ves qué se está enviando exactamente ──
      debugPrint('==================================================');
      debugPrint('👉 ENVIANDO RECORDATORIO [Iteración ${i + 1} de 7]');
      debugPrint('📅 Fecha calculada: $fechaFormateada');
      debugPrint('⏰ Hora:            $horaTexto');
      debugPrint('📍 Lugar:           $_lugar');
      debugPrint('👤 Profesional:     $_profesional');
      debugPrint('📝 Notas:           ${_notas.trim().isNotEmpty ? _notas : 'null'}');
      debugPrint('==================================================');

      final exito = await _service.crearCita(
        fecha: fechaRecordatorio,
        hora: horaTexto,
        lugar: _lugar,
        profesional: _profesional,
        notas: _notas.trim().isNotEmpty ? _notas : null,
      );

      if (exito) {
        debugPrint('✅ ¡Éxito! Recordatorio del día $fechaFormateada guardado correctamente.\n');
      } else {
        todosExitosos = false;
        debugPrint('❌ ¡ERROR! El servicio falló al guardar el día $fechaFormateada.\n');
      }

      // Pequeña pausa para no saturar el backend en la ráfaga
      await Future.delayed(const Duration(milliseconds: 200));
    }

    _guardando = false;
    if (!todosExitosos) {
      _errorGuardar = 'Algunos recordatorios no se pudieron guardar. Verifica tu conexión.';
    }
    notifyListeners();

    return todosExitosos;
  }
}