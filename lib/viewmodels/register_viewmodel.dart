import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  // Paso 1: adulto mayor
  String _nombre = '';
  String _rut = '';
  String _pin = '';

  // Paso 2: cuidador
  String _nombreCuidador = '';
  String _correoCuidador = '';
  String _telefonoCuidador = '';

  bool _pinVisible = false;

  // Errores paso 1
  String? _errorNombre;
  String? _errorRut;
  String? _errorPin;

  // Errores paso 2
  String? _errorNombreCuidador;
  String? _errorCorreo;
  String? _errorTelefono;

  // Error general del servidor
  String? _errorGeneral;

  bool _isLoading = false;

  bool get isLoading => _isLoading;
  bool get pinVisible => _pinVisible;
  String? get errorNombre => _errorNombre;
  String? get errorRut => _errorRut;
  String? get errorPin => _errorPin;
  String? get errorNombreCuidador => _errorNombreCuidador;
  String? get errorCorreo => _errorCorreo;
  String? get errorTelefono => _errorTelefono;
  String? get errorGeneral => _errorGeneral;

  // Setters paso 1
  void setNombre(String value) {
    _nombre = value;
    _errorNombre = null;
    notifyListeners();
  }

  void setRut(String value) {
    _rut = value;
    _errorRut = null;
    notifyListeners();
  }

  void setPin(String value) {
    if (value.length <= 4 && RegExp(r'^\d*$').hasMatch(value)) {
      _pin = value;
      _errorPin = null;
      notifyListeners();
    }
  }

  void togglePinVisible() {
    _pinVisible = !_pinVisible;
    notifyListeners();
  }

  // Setters paso 2
  void setNombreCuidador(String value) {
    _nombreCuidador = value;
    _errorNombreCuidador = null;
    notifyListeners();
  }

  void setCorreoCuidador(String value) {
    _correoCuidador = value;
    _errorCorreo = null;
    notifyListeners();
  }

  void setTelefonoCuidador(String value) {
    _telefonoCuidador = value;
    _errorTelefono = null;
    notifyListeners();
  }

  // Validaciones paso 1
  bool validarPaso1() {
    bool valido = true;
    if (_nombre.isEmpty) {
      _errorNombre = 'Ingrese un nombre o apodo';
      valido = false;
    }
    final regex = RegExp(r'^\d{7,8}-[\dkK]$');
    if (_rut.isEmpty) {
      _errorRut = 'Ingrese su RUT';
      valido = false;
    } else if (!regex.hasMatch(_rut)) {
      _errorRut = 'Formato inválido. Ejemplo: 12345678-9';
      valido = false;
    }
    if (_pin.isEmpty) {
      _errorPin = 'Ingrese su contraseña';
      valido = false;
    } else if (_pin.length != 4) {
      _errorPin = 'El PIN debe tener 4 números';
      valido = false;
    }
    notifyListeners();
    return valido;
  }

  // Validaciones paso 2
  bool validarPaso2() {
    bool valido = true;
    if (_nombreCuidador.isEmpty) {
      _errorNombreCuidador = 'Ingrese el nombre del cuidador';
      valido = false;
    }
    if (_correoCuidador.isEmpty) {
      _errorCorreo = 'Ingrese el correo del cuidador';
      valido = false;
    } else if (!_correoCuidador.contains('@')) {
      _errorCorreo = 'Correo inválido';
      valido = false;
    }
    if (_telefonoCuidador.isEmpty) {
      _errorTelefono = 'Ingrese el teléfono del cuidador';
      valido = false;
    }
    notifyListeners();
    return valido;
  }

  /// Registra al adulto mayor con o sin cuidador.
  /// [conCuidador] true si viene del Step2 con datos, false si presionó "Omitir"
  /// Retorna true si el registro fue exitoso
  Future<bool> registrar({bool conCuidador = false}) async {
    _errorGeneral = null;
    _isLoading = true;
    notifyListeners();

    Map<String, String>? datosCuidador;
    if (conCuidador) {
      datosCuidador = {
        'nombre': _nombreCuidador,
        'correo': _correoCuidador,
        'telefono': _telefonoCuidador,
      };
    }

    final result = await _authService.register(
      nombre: _nombre,
      rut: _rut,
      pin: _pin,
      cuidador: datosCuidador,
    );

    _isLoading = false;

    if (result.success) {
      notifyListeners();
      return true;
    } else {
      // Si el error es "RUT ya registrado", mostrarlo en el campo de RUT
      if (result.error != null && result.error!.contains('RUT')) {
        _errorRut = result.error;
      } else {
        _errorGeneral = result.error;
      }
      notifyListeners();
      return false;
    }
  }
}
