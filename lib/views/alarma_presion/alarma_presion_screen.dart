// lib/views/alarma_presion/alarma_medicion_screen.dart (o la ruta donde lo tengas)
import 'dart:async';
import 'package:flutter/material.dart';

import '../../services/notificacion_service.dart';
import '../../viewmodels/alarma_medicacion_viewmodel.dart'; // IMPORTAMOS EL VIEWMODEL PARA EL CANDADO

// 👇 IMPORTAMOS LA NUEVA PANTALLA PACÍFICA DE INSTRUCCIONES 👇
import '../Instrucciones/instrucciones_medicion_screen.dart';

class AlarmaMedicionScreen extends StatefulWidget {
  final Map<String, dynamic> medicion;

  const AlarmaMedicionScreen({Key? key, required this.medicion}) : super(key: key);

  @override
  State<AlarmaMedicionScreen> createState() => _AlarmaMedicionScreenState();
}

class _AlarmaMedicionScreenState extends State<AlarmaMedicionScreen> {
  // VARIABLE DEL RELOJ DE ARENA
  Timer? _autoCloseTimer;

  // 👇 BANDERA PARA PROTEGER EL CANDADO AL CAMBIAR DE PANTALLA 👇
  bool _goingToInstructions = false;

  @override
  void initState() {
    super.initState();

    // CERRAMOS EL CANDADO
    AlarmViewModel.pantallaAlarmaAbierta = true;

    // INICIAMOS LA CUENTA REGRESIVA DE 59 SEGUNDOS
    _autoCloseTimer = Timer(const Duration(seconds: 59), () {
      if (mounted) {
        print("⏳ El usuario no contestó la presión en 59 segundos. Cerrando...");
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    // MATAMOS EL RELOJ
    _autoCloseTimer?.cancel();

    // 👇 PROTEGEMOS EL CANDADO SI VAMOS A LAS INSTRUCCIONES 👇
    if (!_goingToInstructions) {
      AlarmViewModel.pantallaAlarmaAbierta = false;
      print("🔒 Candado abierto porque la alarma expiró o se cerró sin atender.");
    } else {
      print("🛡️ Candado protegido. El control de la presión pasa a la pantalla de instrucciones.");
    }

    // Apagamos SOLO esta alarma (no cancela las del resto del día)
    final int id = widget.medicion['id'] ?? 0;
    NotificationService().apagarAlarma(id);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String hora = widget.medicion['hora'] ?? '--:--';
    final String nombre = widget.medicion['nombre'] ?? 'MÍDASE LA PRESIÓN';
    final String detalle = widget.medicion['detalle'] ?? 'Instrumento';
    final String? urlFoto = widget.medicion['url_foto_remedio']; // Ojo si tu variable se llama distinto para presión

    return Scaffold(
      backgroundColor: const Color(0xFFFFC5C5),
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
                  const Icon(Icons.notifications_active, color: Colors.red, size: 80),
                  const SizedBox(height: 10),
                  const Text(
                    '¡ALARMA!',
                    style: TextStyle(color: Colors.red, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD2E3FC),
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
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        nombre.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        detalle,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFF0D1B3E)),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: (urlFoto != null && urlFoto.isNotEmpty)
                              ? Image.network(
                            urlFoto,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                          )
                              : const Center(
                            child: Icon(Icons.monitor_heart, size: 70, color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // =========================================================
              // BOTÓN VERDE "ATENDER RECORDATORIO"
              // =========================================================
              SizedBox(
                width: double.infinity,
                height: 80, // Lo hice un poco más alto para accesibilidad
                child: ElevatedButton(
                  onPressed: () {
                    // 👇 1. AGREGAMOS LA PRESIÓN A LA LISTA NEGRA DEL RADAR INMEDIATAMENTE 👇
                    final int id = widget.medicion['id'] ?? 0;
                    AlarmViewModel.alarmasSilenciadas.add("presion_$id");

                    // 2. ACTIVAMOS LA BANDERA PARA NO ABRIR EL CANDADO AL MORIR
                    setState(() {
                      _goingToInstructions = true;
                    });

                    // 3. MATAMOS EL TEMPORIZADOR DE ESTA PANTALLA
                    _autoCloseTimer?.cancel();

                    // 👇 4. VIAJAMOS A LA PANTALLA PACÍFICA DE INSTRUCCIONES 👇
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => InstruccionPresionScreen(
                          medicion: widget.medicion,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1AA23A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 3,
                  ),
                  child: const Text(
                    'ATENDER\nRECORDATORIO',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}