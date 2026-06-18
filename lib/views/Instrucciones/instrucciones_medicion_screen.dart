import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../services/notificacion_service.dart';
import '../../viewmodels/alarma_medicacion_viewmodel.dart';
import '../add measurement/add_measurement_presion_after_alarm.dart';

class InstruccionPresionScreen extends StatefulWidget {
  final Map<String, dynamic> medicion;

  const InstruccionPresionScreen({Key? key, required this.medicion}) : super(key: key);

  @override
  State<InstruccionPresionScreen> createState() => _InstruccionPresionScreenState();
}

class _InstruccionPresionScreenState extends State<InstruccionPresionScreen> {
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();

    AlarmViewModel.pantallaAlarmaAbierta = true;

    NotificationService().apagarAlarmas();
    _iniciarTTS();
  }

  Future<void> _iniciarTTS() async {
    await flutterTts.setLanguage("es-ES");
    await flutterTts.setSpeechRate(0.45);

    String nombre = widget.medicion['nombre'] ?? 'Presión Arterial';
    String instrucciones = widget.medicion['detalle'] ?? widget.medicion['instrucciones'] ?? '';

    String textoALeer = "Es hora de tu medición de $nombre. ";
    if (instrucciones.trim().isNotEmpty) {
      textoALeer += "Instrucciones: $instrucciones.";
    }

    await flutterTts.speak(textoALeer);
  }

  Future<void> _repetirAudio() async {
    await flutterTts.stop();
    await _iniciarTTS();
  }

  @override
  void dispose() {
    AlarmViewModel.pantallaAlarmaAbierta = false;
    flutterTts.stop();
    super.dispose();
  }

  void _irAMedir() {
    flutterTts.stop();

    // Rescatamos los textos de la notificación en minúsculas
    String tipoRecibido = widget.medicion['tipo']?.toString().toLowerCase() ?? '';
    String detalleRecibido = widget.medicion['detalle']?.toString().toLowerCase() ?? '';
    String nombreRecibido = widget.medicion['nombre']?.toString().toLowerCase() ?? '';

    // Buscamos de forma exhaustiva si es una repetición
    bool esRep = tipoRecibido.contains('repetic') ||
        detalleRecibido.contains('repetic') ||
        nombreRecibido.contains('repetic');

    print("🔎 Evaluando envío al teclado - ¿Es repetición?: $esRep");

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AddMeasurementPresionAfterAlarm(
          esRepeticion: esRep,
          idRecordatorio: widget.medicion['id'] as int?,
          nombreMedicion: widget.medicion['nombre'] ?? 'Control de Presión',
          horaProgramada: widget.medicion['hora'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String nombre = widget.medicion['nombre'] ?? 'Presión Arterial';
    final String instrucciones = widget.medicion['detalle'] ?? widget.medicion['instrucciones'] ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── HEADER PERSONALIZADO (Sin flecha) ──
          Container(
            width: double.infinity,
            height: 135,
            color: const Color(0xFF000080),
            padding: const EdgeInsets.only(top: 40),
            alignment: Alignment.center,
            child: const Text(
              'Hora de tu Medición',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // ── CONTENIDO PRINCIPAL ──
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.monitor_heart, size: 100, color: Color(0xFFE53935)),
                  const SizedBox(height: 30),

                  Text(
                    nombre,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black),
                  ),

                  if (instrucciones.trim().isNotEmpty) ...[
                    const SizedBox(height: 25),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.redAccent),
                      ),
                      child: Text(
                        "Instrucciones: $instrucciones",
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 30, color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],

                  const SizedBox(height: 25),
                  OutlinedButton.icon(
                    onPressed: _repetirAudio,
                    icon: const Icon(Icons.replay_circle_filled, size: 36, color: Color(0xFF000080)),
                    label: const Text(
                      'Volver a escuchar',
                      style: TextStyle(fontSize: 24, color: Color(0xFF000080), fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF000080), width: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),

                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    height: 85,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 6,
                      ),
                      onPressed: _irAMedir,
                      child: const Text(
                        'IR A MEDIR',
                        style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    "O di 'Confirmar' en voz alta",
                    style: TextStyle(fontSize: 22, color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}