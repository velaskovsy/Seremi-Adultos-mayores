import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

/// Llama a los endpoints del backend para notificar al cuidador via WhatsApp.
/// Todos los métodos son fire-and-forget: si falla, solo loguean en consola
/// y no rompen el flujo del paciente.
class NotificacionCuidadorService {
  static const String _baseUrl = 'https://servidorappseremi-production.up.railway.app';

  final AuthService _authService = AuthService();

  /// Helper: hace el POST al backend con JWT y body JSON.
  /// Retorna true si el servidor respondió { enviado: true }.
  Future<bool> _post(String endpoint, Map<String, dynamic> body) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        print('⚠️  NotificacionCuidador: sin token, no se puede notificar');
        return false;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/api/notificaciones/$endpoint'),
        headers: {
          'Content-Type':  'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        final enviado = data['enviado'] as bool? ?? false;
        if (enviado) {
          print('✅ WhatsApp al cuidador enviado ($endpoint)');
        } else {
          // enviado=false significa que no tiene cuidador con teléfono — no es error
          print('ℹ️  WhatsApp no enviado ($endpoint): ${data['mensaje'] ?? data['error']}');
        }
        return enviado;
      }

      print('❌ Error del servidor ($endpoint): ${data['error']}');
      return false;

    } catch (e) {
      // Timeout, sin internet, etc. — no romper el flujo del paciente
      print('❌ NotificacionCuidador excepción ($endpoint): $e');
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════════
  // Trigger 1 — Paciente no tomó su medicamento en 30 minutos
  // ══════════════════════════════════════════════════════════════
  Future<void> alertaMedicamento({
    required String nombreMedicamento,
    required String horaProgramada,
  }) async {
    await _post('alerta-medicamento', {
      'nombreMedicamento': nombreMedicamento,
      'horaProgramada':    horaProgramada,
    });
  }

  // ══════════════════════════════════════════════════════════════
  // Trigger 2 — Paciente no midió su presión en 30 minutos
  // ══════════════════════════════════════════════════════════════
  Future<void> alertaPresion({required String horaProgramada}) async {
    await _post('alerta-presion', {'horaProgramada': horaProgramada});
  }

  // ══════════════════════════════════════════════════════════════
  // Trigger 3 — Segunda medición sigue crítica o elevada
  // nivel: 'critico' | 'elevado'
  // ══════════════════════════════════════════════════════════════
  Future<void> presionCritica({
    required String valorPresion,
    required String nivel,
  }) async {
    await _post('presion-critica', {
      'valorPresion': valorPresion,
      'nivel':        nivel,
    });
  }

  // ══════════════════════════════════════════════════════════════
  // Trigger 4 — Paciente presionó botón de emergencias
  // ══════════════════════════════════════════════════════════════
  Future<void> emergencia() async {
    await _post('emergencia', {});
  }
}
