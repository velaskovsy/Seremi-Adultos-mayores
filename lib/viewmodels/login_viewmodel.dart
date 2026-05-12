import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  String _rut = '';
  String _pin = '';
  bool _isLoading = false;
  bool _pinVisible = false;
  String? _errorRut;
  String? _errorPin;
  String? _errorGeneral; // Para errores del servidor

  bool get isLoading => _isLoading;
  bool get pinVisible => _pinVisible;
  String? get errorRut => _errorRut;
  String? get errorPin => _errorPin;
  String? get errorGeneral => _errorGeneral;

  void setRut(String value) {
    _rut = value;
    _errorRut = null;
    _errorGeneral = null;
    notifyListeners();
  }

  void setPin(String value) {
    if (value.length <= 4 && RegExp(r'^\d*$').hasMatch(value)) {
      _pin = value;
      _errorPin = null;
      _errorGeneral = null;
      notifyListeners();
    }
  }

  void togglePinVisible() {
    _pinVisible = !_pinVisible;
    notifyListeners();
  }

  bool _validarRut() {
    if (_rut.isEmpty) {
      _errorRut = 'Ingrese su RUT';
      return false;
    }
    final regex = RegExp(r'^\d{7,8}-[\dkK]$');
    if (!regex.hasMatch(_rut)) {
      _errorRut = 'Formato inválido. Ejemplo: 12345678-9';
      return false;
    }
    return true;
  }

  bool _validarPin() {
    if (_pin.isEmpty) {
      _errorPin = 'Ingrese su contraseña';
      return false;
    }
    if (_pin.length != 4) {
      _errorPin = 'La contraseña debe tener 4 números';
      return false;
    }
    return true;
  }

  /// Retorna true si el login fue exitoso
  Future<bool> login() async {
    _errorRut = null;
    _errorPin = null;
    _errorGeneral = null;

    final rutValido = _validarRut();
    final pinValido = _validarPin();
    if (!rutValido || !pinValido) {
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    final result = await _authService.login(_rut, _pin);

    _isLoading = false;

    if (result.success) {
      notifyListeners();
      return true;
    } else {
      _errorGeneral = result.error;
      notifyListeners();
      return false;
    }
  }
}
