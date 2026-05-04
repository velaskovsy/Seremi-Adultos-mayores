import 'package:flutter/material.dart';

class LoginViewModel extends ChangeNotifier {
  // Las variables se escriben con un _ porque son privadas
  String _rut = '';
  String _pin = '';
  bool _isLoading = false;
  bool _pinVisible = false;
  String? _errorRut;
  String? _errorPin;

  // Getters (la View solo puede leer)
  bool get isLoading => _isLoading;
  bool get pinVisible => _pinVisible;
  String? get errorRut => _errorRut;
  String? get errorPin => _errorPin;

  // Actualiza el RUT mientras el usuario escribe
  void setRut(String value) {
    _rut = value;
    _errorRut = null; // Limpia el error al volver a escribir
    notifyListeners();
  }

  // Actualiza el PIN, el cual solo acepta números y máximo 4 dígitos
  void setPin(String value) {
    if (value.length <= 4 && RegExp(r'^\d*$').hasMatch(value)) {
      _pin = value;
      _errorPin = null; // Limpia el error al volver a escribir
      notifyListeners();
    }
  }

  // Muestra u oculta el PIN
  void togglePinVisible() {
    _pinVisible = !_pinVisible;
    notifyListeners();
  }

  // Valida el formato del RUT
  bool _validarRut() {
    if (_rut.isEmpty) {
      _errorRut = 'Ingrese su RUT';
      return false;
    }
    if (!_rut.contains('-') || _rut.length < 9) {
      _errorRut = 'Formato inválido';
      return false;
    }
    return true;
  }

  // Valida que el PIN tenga exactamente 4 dígitos
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

  // Lógica principal del login
  Future<void> login() async {
    // Limpia errores anteriores
    _errorRut = null;
    _errorPin = null;

    // Valida ambos campos antes de llamar al servidor
    final rutValido = _validarRut();
    final pinValido = _validarPin();

    if (!rutValido || !pinValido) {
      notifyListeners();
      return;
    }

    // Todo válido: muestra loading y llama al servidor
    _isLoading = true;
    notifyListeners();

    // TODO: reemplazar con llamada real a Railway
    // final usuario = await _authService.login(_rut, _pin);
    await Future.delayed(const Duration(seconds: 2)); // Simulación temporal

    _isLoading = false;
    notifyListeners();
  }
}
