import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/auth_service.dart';
import '../../services/notificacion_cuidador_service.dart'; // ✅ NUEVO
import '../home/home_screen.dart';

class AlertaCriticaPresionAltaScreen extends StatefulWidget {
  final String presionString;

  const AlertaCriticaPresionAltaScreen({
    Key? key,
    required this.presionString,
  }) : super(key: key);

  @override
  State<AlertaCriticaPresionAltaScreen> createState() =>
      _AlertaCriticaPresionAltaScreenState();
}

class _AlertaCriticaPresionAltaScreenState
    extends State<AlertaCriticaPresionAltaScreen> {
  String? _telefonoCuidador;
  bool _cargando = true;

  // ✅ NUEVO: para no mandar el WhatsApp de emergencia más de una vez
  bool _emergenciaEnviada = false;

  @override
  void initState() {
    super.initState();
    _cargarTelefonoCuidador();
  }

  Future<void> _cargarTelefonoCuidador() async {
    final usuario = await AuthService().getUsuario();
    setState(() {
      _telefonoCuidador = usuario?['telefono_cuidador'] as String?; // ✅ campo nuevo del login
      _cargando = false;
    });
  }

  Future<void> _llamar(String telefono) async {
    final uri = Uri.parse('tel:$telefono');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  // ✅ NUEVO: llama al cuidador Y manda WhatsApp de emergencia
  Future<void> _accionEmergencia() async {
    // WhatsApp solo se manda una vez aunque el paciente presione varias veces
    if (!_emergenciaEnviada) {
      _emergenciaEnviada = true;
      NotificacionCuidadorService().emergencia();
    }

    // Si tiene teléfono, abre la app de llamadas
    if (_telefonoCuidador != null && _telefonoCuidador!.isNotEmpty) {
      await _llamar(_telefonoCuidador!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFC5C5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: _cargando
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    // ── SECCIÓN SUPERIOR ──────────────────────
                    Column(
                      children: [
                        const SizedBox(height: 20),
                        const Icon(Icons.error_outline, color: Colors.red, size: 90),
                        const SizedBox(height: 10),
                        const Text(
                          '¡ALERTA\nCRÍTICA!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    // ── TARJETA CENTRAL ───────────────────────
                    Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFDFDF),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: Colors.red, width: 2),
                              ),
                              child: Text(
                                '${widget.presionString} mmHg',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Por favor, mantenga la calma y tome asiento. Necesita asistencia médica ahora mismo.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black87,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── BOTONES ───────────────────────────────
                    Column(
                      children: [

                        // ✅ MODIFICADO: botón cuidador ahora también manda WhatsApp
                        // Se muestra siempre (antes solo si tenía teléfono)
                        // Si no tiene teléfono, igual manda el WhatsApp
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: SizedBox(
                            width: double.infinity,
                            height: 65,
                            child: ElevatedButton.icon(
                              onPressed: _accionEmergencia,
                              icon: const Icon(Icons.phone, color: Colors.white, size: 28),
                              label: const Text(
                                'LLAMAR A CUIDADOR',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF000080),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                          ),
                        ),

                        // Botón llamar emergencias (siempre visible)
                        SizedBox(
                          width: double.infinity,
                          height: 65,
                          child: ElevatedButton.icon(
                            onPressed: () => _llamar('131'),
                            icon: const Icon(Icons.emergency, color: Colors.white, size: 28),
                            label: const Text(
                              'LLAMAR A EMERGENCIAS',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        TextButton(
                          onPressed: () => Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const HomeScreen()),
                            (route) => false,
                          ),
                          child: const Text(
                            'Volver al inicio',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black54,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
