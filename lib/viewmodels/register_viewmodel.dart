import 'package:flutter/material.dart';

class RegisterViewModel extends ChangeNotifier {
  // Paso 1: datos del adulto mayor
  String _nombre = '';
  String _rut = '';
  String _pin = '';

  // Paso 2: datos del cuidador (opcionales)
  String _nombreCuidador = '';
  String _correoCuidador = '';
  String _telefonoCuidador = '';

  // Errores
  String? _errorNombre;
  String? _errorRut;
  String? _errorPin;
  String? _errorCorreo;

  bool _isLoading = false;
  bool _pinVisible = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorNombre => _errorNombre;
  String? get errorRut => _errorRut;
  String? get errorPin => _errorPin;
  String? get errorCorreo => _errorCorreo;
  bool get pinVisible => _pinVisible;

  void togglePinVisible() {
    _pinVisible = !_pinVisible;
    notifyListeners();
  }

  // Setters del paso 1
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

  // Setters del paso 2
  void setNombreCuidador(String value) {
    _nombreCuidador = value;
    notifyListeners();
  }

  void setCorreoCuidador(String value) {
    _correoCuidador = value;
    _errorCorreo = null;
    notifyListeners();
  }

  void setTelefonoCuidador(String value) {
    _telefonoCuidador = value;
    notifyListeners();
  }

  // Validaciones paso 1
  bool validarPaso1() {
    bool valido = true;

    if (_nombre.isEmpty) {
      _errorNombre = 'Ingrese un nombre o apodo';
      valido = false;
    }
    if (!_rut.contains('-') || _rut.length < 9) {
      _errorRut = 'Formato inválido';
      valido = false;
    }
    if (_pin.length != 4) {
      _errorPin = 'El PIN debe tener 4 números';
      valido = false;
    }

    notifyListeners();
    return valido;
  }

  // Validaciones del paso 2
  bool validarPaso2() {
    bool valido = true;

    if (_correoCuidador.isNotEmpty && !_correoCuidador.contains('@')) {
      _errorCorreo = 'Correo inválido';
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
    await Future.delayed(const Duration(seconds: 2));

    _isLoading = false;
    notifyListeners();
  }
}
