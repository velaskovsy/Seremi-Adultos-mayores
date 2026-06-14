import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // 👈 IMPORTANTE: Agregado el import de SVG

class DetalleActividadScreen extends StatelessWidget {
  final Map<String, dynamic> actividad;

  const DetalleActividadScreen({
    Key? key,
    required this.actividad,
  }) : super(key: key);

  static const Color colorPrimario = Color(0xFF000080);
  static const Color colorFondo = Colors.white;
  static const Color colorGrisFondo = Color(0xFFF3F4F6);
  static const Color colorGrisBorde = Color(0xFFD1D5DB);
  static const Color botonEditar = Color(0xFF2196F3);
  static const Color botonEliminar = Color(0xFFD32F2F);

  @override
  Widget build(BuildContext context) {
    // ── DATOS REALES ──
    final String nombre = actividad['nombre'] ?? 'Actividad';
    final String hora = actividad['hora'] ?? '00:00';
    final String detalle = actividad['detalle'] ?? '1 vaso';

    return Scaffold(
      backgroundColor: colorFondo,
      body: Column(
        children: [
          // ── HEADER PERSONALIZADO ──
          Container(
            width: double.infinity,
            height: 135,
            color: colorPrimario,
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back, color: Color(0xFF000080), size: 28),
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Detalle del evento',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 62),
                ],
              ),
            ),
          ),

          // ── CONTENIDO PRINCIPAL ──
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    // ── HEADER: ICONO Y NOMBRE ──
                    Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: const Color(0xFFB200FF), // Morado
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.all(16),
                          // 👇 AQUÍ ESTÁ TU SVG 'walking.svg' 👇
                          child: SvgPicture.asset(
                            'assets/imagenes/iconos/walking.svg',
                            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                            // Fallback por si no carga el SVG
                            placeholderBuilder: (context) => const Icon(Icons.directions_walk, color: Colors.white, size: 60),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          nombre,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // ── SECCIÓN: DETALLES ──
                    const Text(
                      'DETALLES',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: colorGrisFondo,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: colorGrisBorde, width: 2),
                      ),
                      child: Column(
                        children: [
                          _buildDetalleFila('Hora del\nrecordatorio', hora),
                          const Divider(color: colorGrisBorde, thickness: 2, height: 0),
                          _buildDetalleFila('Cantidad', detalle),
                        ],
                      ),
                    ),

                    const SizedBox(height: 50),

                    // ── BOTONES DE ACCIÓN ──
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: botonEditar,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 65),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                      ),
                      child: const Text(
                        'Editar recordatorio',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: botonEliminar,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 65),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                      ),
                      child: const Text(
                        'Eliminar recordatorio',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetalleFila(String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              etiqueta,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Flexible(
            child: Text(
              valor,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: colorPrimario,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}