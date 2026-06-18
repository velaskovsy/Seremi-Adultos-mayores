import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../../services/notificacion_service.dart';
import '../../services/historial_service.dart';
import '../../viewmodels/alarma_medicacion_viewmodel.dart';

class InstruccionMedicamentoScreen extends StatefulWidget {
  final Map<String, dynamic> medicamento;

  const InstruccionMedicamentoScreen({Key? key, required this.medicamento}) : super(key: key);

  @override
  State<InstruccionMedicamentoScreen> createState() => _InstruccionMedicamentoScreenState();
}

class _InstruccionMedicamentoScreenState extends State<InstruccionMedicamentoScreen> {
  final FlutterTts flutterTts = FlutterTts();
  final HistorialService _historialService = HistorialService();

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

    String nombre = widget.medicamento['nombre'] ?? '';
    String dosis = widget.medicamento['dosis'] ?? widget.medicamento['detalle'] ?? '';
    String instrucciones = widget.medicamento['instrucciones'] ?? '';

    String textoALeer = "Es hora de tu medicamento. $nombre. ";
    if (dosis.trim().isNotEmpty) {
      textoALeer += "Dosis: $dosis. ";
    }
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

  Future<void> _confirmarToma() async {
    flutterTts.stop();

    final int id = widget.medicamento['id'] ?? 0;
    final String llaveUnica = "med_$id";

    AlarmViewModel.alarmasSilenciadas.add(llaveUnica);

    final prefs = await SharedPreferences.getInstance();
    final String fechaHoy = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await prefs.setBool("${llaveUnica}_$fechaHoy", true);

    print("✅ Registro guardado con éxito: ${widget.medicamento['nombre']}");

    // Registramos la confirmación en el backend para que aparezca en el
    // Historial. Fire-and-forget: si falla (sin internet, etc.) no bloquea
    // al usuario, ya quedó guardado localmente arriba.
    _historialService.registrarMedicamento(
      idRecordatorio: id,
      nombre: widget.medicamento['nombre'] ?? 'Medicamento',
      horaProgramada: widget.medicamento['hora'],
    );

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String nombre = widget.medicamento['nombre'] ?? '';
    final String dosis = widget.medicamento['dosis'] ?? widget.medicamento['detalle'] ?? '';
    final String instrucciones = widget.medicamento['instrucciones'] ?? '';

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
              'Hora de tu Medicamento',
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
                  const Icon(Icons.medication, size: 100, color: Color(0xFF4CAF50)),
                  const SizedBox(height: 30),

                  Text(
                    nombre,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black),
                  ),

                  const SizedBox(height: 15),

                  if (dosis.isNotEmpty)
                    Text(
                      dosis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 32, color: Color(0xFF000080), fontWeight: FontWeight.w500),
                    ),

                  if (instrucciones.isNotEmpty) ...[
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orangeAccent),
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
                        backgroundColor: const Color(0xFF4CAF50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 6,
                      ),
                      onPressed: _confirmarToma,
                      child: const Text(
                        'YA LO TOMÉ',
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