import 'package:flutter/material.dart';

class RegisterViewModel extends ChangeNotifier {
  // Paso 1: datos del adulto mayor
  String _nombre = '';
  String _rut = '';
  String _pin = '';

  // Paso 2: datos del cuidador
  String _nombreCuidador = '';
  String _correoCuidador = '';
  String _telefonoCuidador = '';

  // Visibilidad PIN
  bool _pinVisible = false;

  // Errores paso 1
  String? _errorNombre;
  String? _errorRut;
  String? _errorPin;

  // Errores paso 2
  String? _errorNombreCuidador;
  String? _errorCorreo;
  String? _errorTelefono;

  bool _isLoading = false;

  // Getters
  bool get isLoading => _isLoading;
  bool get pinVisible => _pinVisible;

  String? get errorNombre => _errorNombre;
  String? get errorRut => _errorRut;
  String? get errorPin => _errorPin;

  String? get errorNombreCuidador => _errorNombreCuidador;
  String? get errorCorreo => _errorCorreo;
  String? get errorTelefono => _errorTelefono;

  // Getter para habilitar botón Siguiente paso 2
  bool get paso2Completo =>
      _nombreCuidador.isNotEmpty &&
          _correoCuidador.isNotEmpty &&
          _telefonoCuidador.isNotEmpty;

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

  // Registro final
  Future<void> registrar() async {
    _isLoading = true;
    notifyListeners();

    // TODO: reemplazar con llamada real a Railway
    await Future.delayed(const Duration(seconds: 1));

    _isLoading = false;
    notifyListeners();
  }
}
