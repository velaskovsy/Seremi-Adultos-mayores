// lib/views/alarma_medicacion/alarma_medicacion_screen.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:async'; // 👈 1. IMPORTAMOS EL TEMPORIZADOR
import 'package:flutter/material.dart';
import '../../services/voice_service.dart';
import '../../services/notificacion_service.dart';
import '../../viewmodels/alarma_medicacion_viewmodel.dart'; // 👈 1. IMPORTAMOS EL RADAR PARA LA LISTA NEGRA

class AlarmScreen extends StatefulWidget {
  final Map<String, dynamic> medicamento;

  const AlarmScreen({super.key, required this.medicamento});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  final VoiceService _voiceService = VoiceService();

  // 👇 2. VARIABLE DEL RELOJ DE ARENA
  Timer? _autoCloseTimer;

  @override
  void initState() {
    super.initState();

    // 👇 1. CERRAMOS EL CANDADO (Para que el radar no apile otra)
    AlarmViewModel.pantallaAlarmaAbierta = true;

    // 🔥 Captura el momento exacto en que la pantalla aparece y habla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reproducirAlarmaPorVoz();
    });

    // 👇 2. INICIAMOS LA CUENTA REGRESIVA DE 59 SEGUNDOS
    _autoCloseTimer = Timer(const Duration(seconds: 59), () {
      if (mounted) {
        print("⏳ El usuario no contestó en 60 segundos. Cerrando pantalla para permitir reintento...");
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    // ABRIMOS EL CANDADO (Para liberar al radar de nuevo)
    AlarmViewModel.pantallaAlarmaAbierta = false;

    // MATAMOS EL RELOJ SI LA PANTALLA SE CIERRA MANUALMENTE
    _autoCloseTimer?.cancel();

    // Si la pantalla se destruye, matamos la IA
    _voiceService.detener();

    // 👇 LA SOLUCIÓN AL AUDIO FANTASMA: Apagamos el ruido de Android si se acaba el tiempo
    NotificationService().apagarAlarmas();

    super.dispose();
  }

  void _reproducirAlarmaPorVoz() {
    final String nombre        = widget.medicamento['nombre']        ?? 'Medicamento';
    final String dosis         = widget.medicamento['dosis'] ?? '';
    final String instrucciones = widget.medicamento['instrucciones'] ?? '';

    String mensaje = "Atención. Es hora de tomar tu medicamento: $nombre. ";
    if (dosis.trim().isNotEmpty)         mensaje += "Dosis: $dosis. ";
    if (instrucciones.trim().isNotEmpty) mensaje += "Instrucciones: $instrucciones.";

    _voiceService.hablar(mensaje);
  }

  @override
  Widget build(BuildContext context) {
    final String hora          = widget.medicamento['hora']          ?? '--:--';
    final String nombre        = widget.medicamento['nombre']        ?? 'Medicamento';
    final String dosis         = widget.medicamento['dosis'] ?? '';
    final String instrucciones = widget.medicamento['instrucciones'] ?? '';
    final String? urlCaja      = widget.medicamento['url_foto_caja'];
    final String? urlRemedio   = widget.medicamento['url_foto_remedio'];

    return Scaffold(
      backgroundColor: const Color(0xFFFFC5C5), // Fondo rosado
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Sección Superior
              Column(
                children: [
                  const SizedBox(height: 20),
                  const Icon(Icons.error_outline, color: Colors.red, size: 80),
                  const SizedBox(height: 10),
                  const Text(
                    '¡ALARMA!',
                    style: TextStyle(color: Colors.red, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD2E3FC), // Celeste
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: Text(
                      hora,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),

              // Tarjeta Blanca Central
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        nombre.toUpperCase(),
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      if (dosis.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFCEE0FF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            dosis,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D1B3E)),
                          ),
                        ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: const [
                          Text('CAJA', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('PASTILLA', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: _buildImage(urlCaja)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildImage(urlRemedio)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Botón Verde Inferior
              SizedBox(
                width: double.infinity,
                height: 65,
                child: ElevatedButton(
                    onPressed: () async {
                      final int id = widget.medicamento['id'] ?? 0;
                      final String llaveUnica = "med_$id";

                      // 1. Lo guardamos en la RAM (rápido)
                      AlarmViewModel.alarmasSilenciadas.add(llaveUnica);

                      // 👇 2. LA CURA DEL ALZHEIMER: Lo guardamos en el Disco Duro 👇
                      final prefs = await SharedPreferences.getInstance();
                      final String fechaHoy = DateFormat('yyyy-MM-dd').format(DateTime.now());
                      await prefs.setBool("${llaveUnica}_$fechaHoy", true);

                      // 3. Apagamos todo y cerramos
                      _voiceService.detener();
                      await NotificationService().apagarAlarmas();

                      if (mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1AA23A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text(
                    'SÍ, YA LO TOMÉ',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String? url) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: (url != null && url.isNotEmpty)
            ? Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image))
            : const Center(child: Icon(Icons.medication, size: 50, color: Colors.grey)),
      ),
    );
  }
}