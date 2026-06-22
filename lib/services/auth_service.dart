// lib/services/auth_service.dart
//
// Login offline-first:
//  - CON internet: valida contra Railway, guarda sesión + pin_hash en SQLite
//  - SIN internet: valida PIN contra hash guardado localmente, usa token cacheado

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../database/db_helper.dart';
import 'connectivity_service.dart';

class AuthResult {
  final bool success;
  final String? error;
  final Map<String, dynamic>? usuario;

  const AuthResult({required this.success, this.error, this.usuario});
}

class AuthService {
  static const String _baseUrl =
      'https://servidorappseremi-production.up.railway.app';

  static const String _tokenKey   = 'auth_token';
  static const String _usuarioKey = 'usuario';

  final DBHelper _db = DBHelper();
  final ConnectivityService _connectivity = ConnectivityService();

  // ── Utilidad: hashea el PIN con SHA-256 ──────────────────────
  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    return sha256.convert(bytes).toString();
  }

  // ─── LOGIN ───────────────────────────────────────────────────
  Future<AuthResult> login(String rut, String pin) async {
    final online = await _connectivity.hayInternet();

    if (online) {
      return await _loginOnline(rut, pin);
    } else {
      return await _loginOffline(rut, pin);
    }
  }

  Future<AuthResult> _loginOnline(String rut, String pin) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'rut': rut, 'pin': pin}),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        // Guardar en SharedPreferences (compatibilidad con código existente)
        await _guardarSesionPrefs(data['token'], data['usuario']);

        // Guardar en SQLite para login offline futuro
        await _db.guardarSesion(
          rut:        rut,
          nombre:     data['usuario']['nombre'] ?? '',
          pinHash:    _hashPin(pin),
          token:      data['token'],
          idCuidador: data['usuario']['id_cuidador'] as int?,
        );

        return AuthResult(success: true, usuario: data['usuario']);
      }

      return AuthResult(
        success: false,
        error: data['error'] ?? 'Error al iniciar sesión',
      );
    } catch (e) {
      // Si falla la red aunque connectivity dijo que había internet,
      // intentar offline como fallback
      return await _loginOffline(rut, pin);
    }
  }

  Future<AuthResult> _loginOffline(String rut, String pin) async {
    final sesion = await _db.getSesion();

    if (sesion == null) {
      return const AuthResult(
        success: false,
        error: 'Sin conexión. Debes iniciar sesión con internet al menos una vez.',
      );
    }

    // Verificar que el RUT coincida con la sesión guardada
    if (sesion['rut'] != rut) {
      return const AuthResult(
        success: false,
        error: 'Sin conexión. Solo puedes usar la cuenta con la que iniciaste sesión antes.',
      );
    }

    // Verificar PIN contra hash local
    final pinHashIngresado = _hashPin(pin);
    if (sesion['pin_hash'] != pinHashIngresado) {
      return const AuthResult(
        success: false,
        error: 'PIN incorrecto.',
      );
    }

    // Login offline exitoso — usar token cacheado
    final usuario = {
      'rut':         sesion['rut'],
      'nombre':      sesion['nombre'],
      'id_cuidador': sesion['id_cuidador'],
    };

    await _guardarSesionPrefs(sesion['token'] as String, usuario);

    return AuthResult(success: true, usuario: usuario);
  }

  // ─── REGISTRO ────────────────────────────────────────────────
  // El registro siempre requiere internet (crea cuenta en Railway).
  Future<AuthResult> register({
    required String nombre,
    required String rut,
    required String pin,
    Map<String, String>? cuidador,
  }) async {
    final online = await _connectivity.hayInternet();
    if (!online) {
      return const AuthResult(
        success: false,
        error: 'Se requiere conexión a internet para crear una cuenta.',
      );
    }

    try {
      final body = <String, dynamic>{
        'nombre': nombre,
        'rut':    rut,
        'pin':    pin,
      };
      if (cuidador != null) body['cuidador'] = cuidador;

      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201) {
        await _guardarSesionPrefs(data['token'], data['usuario']);

        // Guardar en SQLite para poder entrar offline después
        await _db.guardarSesion(
          rut:        rut,
          nombre:     nombre,
          pinHash:    _hashPin(pin),
          token:      data['token'],
          idCuidador: data['usuario']['id_cuidador'] as int?,
        );

        return AuthResult(success: true, usuario: data['usuario']);
      }

      return AuthResult(
        success: false,
        error: data['error'] ?? 'Error al registrarse',
      );
    } catch (e) {
      return const AuthResult(
        success: false,
        error: 'No se pudo conectar con el servidor.',
      );
    }
  }

  // ─── SESIÓN ──────────────────────────────────────────────────
  Future<void> _guardarSesionPrefs(
      String token, Map<String, dynamic> usuario) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_usuarioKey, jsonEncode(usuario));
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<Map<String, dynamic>?> getUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usuarioKey);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<bool> estaLogueado() async {
    final token = await getToken();
    return token != null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_usuarioKey);
    // NO borramos la sesión de SQLite para que pueda volver a entrar offline
  }
}
