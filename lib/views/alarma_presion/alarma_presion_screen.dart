import 'package:flutter/material.dart';
import '../../services/voice_service.dart'; // Importa tu servicio de voz

class AlarmaMedicionScreen extends StatefulWidget {
  final Map<String, dynamic> medicion;

  const AlarmaMedicionScreen({Key? key, required this.medicion}) : super(key: key);

  @override
  State<AlarmaMedicionScreen> createState() => _AlarmaMedicionScreenState();
}

class _AlarmaMedicionScreenState extends State<AlarmaMedicionScreen> {
  final VoiceService _voiceService = VoiceService(); // Integración de voz

  @override
  void initState() {
    super.initState();
    _dispararVozGuia();
  }

  /// Activa la guía por voz para el adulto mayor al abrir la pantalla
  void _dispararVozGuia() async {
    final String nombre = widget.medicion['nombre'] ?? 'Mídase la presión';
    final String detalle = widget.medicion['detalle'] ?? 'Instrumento';

    // Frase personalizada y pausada ideal para accesibilidad
    await _voiceService.hablar("Atención. ¡Hora de tu alarma! Es momento de: $nombre. Por favor, utiliza el $detalle.");
  }

  @override
  void dispose() {
    _voiceService.detener(); // Detiene el audio inmediatamente si el usuario cierra antes de que termine
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Extracción segura de datos con respaldos por defecto
    final String hora = widget.medicion['hora'] ?? '--:--';
    final String nombre = widget.medicion['nombre'] ?? 'MÍDASE LA PRESIÓN';
    final String detalle = widget.medicion['detalle'] ?? 'Instrumento';
    final String? urlFoto = widget.medicion['url_foto_remedio']; // Reutilizamos el campo de imagen

    return Scaffold(
      backgroundColor: const Color(0xFFFFC5C5), // Fondo rosado exacto de la imagen de alarma
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Sección Superior (Icono + ¡ALARMA! + Hora celeste)
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
                  // Óvalo celeste del mockup para destacar el horario
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD2E3FC), // Celeste pastel exacto
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.black, width: 2), // Borde definido como en la imagen
                    ),
                    child: Text(
                      hora,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),

              // Tarjeta Blanca Central del Mockup
              Card(
                color: Colors.white,
                elevation: 2, // Leve sombra para resaltar del fondo rosado
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // La tarjeta se ajusta a su contenido
                    children: [
                      Text(
                        nombre.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      const SizedBox(height: 12),
                      // Subtítulo del dispositivo (Ej: Instrumento / Tensiómetro)
                      Text(
                        detalle,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFF0D1B3E)),
                      ),
                      const SizedBox(height: 15),
                      // Imagen grande central de la medición (tensiómetro)
                      Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[100], // Fondo de carga neutro
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

              // Botón Verde Inferior "YA LA MEDÍ"
              SizedBox(
                width: double.infinity,
                height: 65,
                child: ElevatedButton(
                  onPressed: () {
                    _voiceService.detener(); // Detiene el audio de la guía al confirmar
                    Navigator.of(context).pop(); // Cierra la pantalla de alarma
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1AA23A), // Verde vibrante exacto de la imagen de alarma
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // Botón redondeado
                    elevation: 3,
                  ),
                  child: const Text(
                    'YA LA MEDÍ',
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