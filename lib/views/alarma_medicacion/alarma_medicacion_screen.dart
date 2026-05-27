import 'package:flutter/material.dart';

class AlarmScreen extends StatelessWidget {
  final Map<String, dynamic> medicamento;

  const AlarmScreen({super.key, required this.medicamento});

  @override
  Widget build(BuildContext context) {
    final String hora = medicamento['hora'] ?? '--:--';
    final String nombre = medicamento['nombre'] ?? 'Medicamento';
    final String detalle = medicamento['detalle'] ?? '';
    final String? urlCaja = medicamento['url_foto_caja'];
    final String? urlRemedio = medicamento['url_foto_remedio'];

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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCEE0FF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          detalle,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D1B3E)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
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
                  onPressed: () => Navigator.of(context).pop(),
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