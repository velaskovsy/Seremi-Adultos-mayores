// lib/views/alarma_medicacion/alarma_medicacion_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';

import '../../services/notificacion_service.dart';
import '../../viewmodels/alarma_medicacion_viewmodel.dart';
import '../Instrucciones/instrucciones_medicamento_screen.dart';

class AlarmScreen extends StatefulWidget {
  final Map<String, dynamic> medicamento;

  const AlarmScreen({super.key, required this.medicamento});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  // VARIABLE DEL RELOJ DE ARENA
  Timer? _autoCloseTimer;

  // Una bandera para controlar si vamos a la otra pantalla o si se cerró por tiempo
  bool _goingToInstructions = false;

  @override
  void initState() {
    super.initState();

    // CERRAMOS EL CANDADO al iniciar
    AlarmViewModel.pantallaAlarmaAbierta = true;

    // INICIAMOS LA CUENTA REGRESIVA DE 59 SEGUNDOS
    _autoCloseTimer = Timer(const Duration(seconds: 59), () {
      if (mounted) {
        print("⏳ El usuario no contestó en 60 segundos. Cerrando pantalla para permitir reintento...");
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    // MATAMOS EL RELOJ
    _autoCloseTimer?.cancel();

    // Si la pantalla muere porque nos fuimos a las instrucciones, NO tocamos el candado.
    if (!_goingToInstructions) {
      AlarmViewModel.pantallaAlarmaAbierta = false;
      print("🔒 Candado abierto porque la alarma expiró o se cerró sin atender.");
    } else {
      print("🛡️ Candado protegido. El control pasa a la pantalla de instrucciones.");
    }

    // Apagamos el ruido de Android
    NotificationService().apagarAlarmas();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String hora          = widget.medicamento['hora']          ?? '--:--';
    final String nombre        = widget.medicamento['nombre']        ?? 'Medicamento';
    final String dosis         = widget.medicamento['dosis'] ?? '';
    final String? urlCaja      = widget.medicamento['url_foto_caja'];
    final String? urlRemedio   = widget.medicamento['url_foto_remedio'];

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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        nombre.toUpperCase(),
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
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

              // Botón Verde
              SizedBox(
                width: double.infinity,
                height: 80,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1AA23A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    // 👇 ¡AQUÍ ESTÁ LA SOLUCIÓN! 👇
                    // Le avisamos INMEDIATAMENTE al radar que ya estamos atendiendo este remedio
                    // para que no vuelva a disparar el sonido en el próximo ciclo de fondo.
                    final int id = widget.medicamento['id'] ?? 0;
                    final String llaveUnica = "med_$id";
                    AlarmViewModel.alarmasSilenciadas.add(llaveUnica);

                    setState(() {
                      _goingToInstructions = true;
                    });

                    _autoCloseTimer?.cancel();

                    // Saltamos a la fase pacífica de instrucciones
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => InstruccionMedicamentoScreen(
                          medicamento: widget.medicamento,
                        ),
                      ),
                    );
                  },
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