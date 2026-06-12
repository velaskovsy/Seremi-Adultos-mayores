import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DetalleCitaMedicaScreen extends StatelessWidget {
  final Map<String, dynamic> cita;

  const DetalleCitaMedicaScreen({
    Key? key,
    required this.cita,
  }) : super(key: key);

  static const Color colorPrimario = Color(0xFF000080);
  static const Color colorFondo = Colors.white;
  static const Color colorGrisFondo = Color(0xFFF3F4F6);
  static const Color colorGrisBorde = Color(0xFFD1D5DB);
  static const Color botonEditar = Color(0xFF2196F3);
  static const Color botonEliminar = Color(0xFFD32F2F);

  @override
  Widget build(BuildContext context) {
    // ── DATOS REALES / HARDCODEADOS ──
    final String nombre = 'Cita médica'; // Lo forzamos como en el diseño
    final String hora = cita['hora'] ?? '07:00';

    // Tratamos de sacarlos de la base de datos, si no vienen, usamos los del diseño
    final String lugar = cita['lugar'] ?? 'Clínica los Carrera';
    final String profesional = cita['profesional'] ?? 'Doctor Juan García';
    final String notas = cita['notas'] ?? 'Ir en ayuna';

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
                            color: const Color(0xFF2196F3), // Azul claro como en la foto
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.all(16),
                          // 👇 AQUÍ ESTÁ TU SVG DE CALENDARIO 👇
                          child: SvgPicture.asset(
                            'assets/imagenes/iconos/i-schedule_school_date_time.svg',
                            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                            placeholderBuilder: (context) => const Icon(Icons.calendar_month, color: Colors.white, size: 60),
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

                    // ── SECCIÓN: HORARIO ──
                    const Text(
                      'HORARIO',
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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Text(
                                'Hora del\nrecordatorio',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Flexible(
                              child: Text(
                                hora,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: colorPrimario,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ── SECCIÓN: LUGAR ──
                    _buildCajaTexto('LUGAR', lugar),

                    // ── SECCIÓN: PROFESIONAL ──
                    _buildCajaTexto('PROFESIONAL DE LA\nSALUD', profesional),

                    // ── SECCIÓN: NOTAS ──
                    _buildCajaTexto('NOTAS', notas),

                    const SizedBox(height: 20),

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

  // 👇 Este es el constructor que arma todas tus cajas idénticas
  Widget _buildCajaTexto(String titulo, String contenido) {
    if (contenido.isEmpty) return const SizedBox.shrink(); // Si no hay datos, no la dibuja

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black, width: 3), // Borde grueso
          ),
          child: Text(
            contenido,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: colorPrimario, // Texto azul oscuro
            ),
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}