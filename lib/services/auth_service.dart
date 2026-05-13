import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Resultado de una operación de auth
class AuthResult {
  final bool success;
  final String? error;
  final Map<String, dynamic>? usuario;

  const AuthResult({required this.success, this.error, this.usuario});
}

class AuthService {
  // ⚠️ Cambia esta URL por la de tu servicio en Railway al desplegarlo
  // Ejemplo: 'https://seremi-api-production.up.railway.app'
  static const String _baseUrl = 'https://servidorappseremi-production.up.railway.app';

  static const String _tokenKey = 'auth_token';
  static const String _usuarioKey = 'usuario';

  // ─── LOGIN ───────────────────────────────────────────────────────────────
  Future<AuthResult> login(String rut, String pin) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'rut': rut, 'pin': pin}),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        // Guardar token y datos del usuario localmente
        await _guardarSesion(data['token'], data['usuario']);
        return AuthResult(success: true, usuario: data['usuario']);
      }

      return AuthResult(
        success: false,
        error: data['error'] ?? 'Error al iniciar sesión',
      );

    } catch (e) {
      return const AuthResult(
        success: false,
        error: 'No se pudo conectar con el servidor. Verifica tu conexión.',
      );
    }
  }

  // ─── REGISTRO ────────────────────────────────────────────────────────────
  Future<AuthResult> register({
    required String nombre,
    required String rut,
    required String pin,
    Map<String, String>? cuidador, // { nombre, correo, telefono }
  }) async {
    try {
      final body = <String, dynamic>{
        'nombre': nombre,
        'rut': rut,
        'pin': pin,
      };
      if (cuidador != null) {
        body['cuidador'] = cuidador;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201) {
        await _guardarSesion(data['token'], data['usuario']);
        return AuthResult(success: true, usuario: data['usuario']);
      }

      // Error controlado del servidor (RUT duplicado, etc.)
      return AuthResult(
        success: false,
        error: data['error'] ?? 'Error al registrarse',
      );

    } catch (e) {
      return const AuthResult(
        success: false,
        error: 'No se pudo conectar con el servidor. Verifica tu conexión.',
      );
    }
  }

  // ─── SESIÓN ──────────────────────────────────────────────────────────────
  Future<void> _guardarSesion(String token, Map<String, dynamic> usuario) async {
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
  }
}
