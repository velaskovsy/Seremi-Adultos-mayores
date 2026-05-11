import 'package:flutter/material.dart';
import '../../core/widgets/app_footer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  // Fecha dinámica del sistema
  String _obtenerFecha() {
    final ahora = DateTime.now();
    const dias = [
      'Lunes', 'Martes', 'Miércoles', 'Jueves',
      'Viernes', 'Sábado', 'Domingo'
    ];
    const meses = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    final dia = dias[ahora.weekday - 1];
    final mes = meses[ahora.month - 1];
    return '$dia, ${ahora.day} de $mes';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
        body: Column(
          children: [

            // HEADER
            Container(
              width: double.infinity,
              height: 135,
              color: const Color(0xFF000080),
              alignment: Alignment.center,
              child: const Text(
                'Nombre\nde la app',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // ── CONTENIDO SCROLLEABLE ────────────────────────
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const SizedBox(height: 20),

                    // ── FECHA ────────────────────────────────
                    Center(
                      child: Text(
                        _obtenerFecha(),
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── PRÓXIMA TAREA ─────────────────────────
                    // TODO: reemplazar con dato real del backend
                    Center(
                      child: Container(
                        width: 344,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD0EFFF),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.blueAccent, width: 1.5),
                        ),
                        child: const Center(
                          child: Text(
                            'Su próxima tarea es a las\n--:--',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 20,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // BOTÓN AÑADIR RECORDATORIO
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              offset: const Offset(4, 6),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: SizedBox(
                          width: 378,
                          height: 92,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            onPressed: () {
                              // TODO: navegar a pantalla de añadir recordatorio
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Color(0xFF4CAF50),
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'AÑADIR RECORDATORIO',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 24,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // HORARIO DEL DÍA
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 17),
                      child: Row(
                        children: const [
                          Icon(Icons.access_time,
                              color: Color(0xFF000080), size: 38),
                          SizedBox(width: 10),
                          Text(
                            'HORARIO DEL DÍA',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 17),
                      child: Divider(color: Colors.black, thickness: 1),
                    ),

                    const SizedBox(height: 12),

                    //  FRANJA MAÑANA
                    _buildFranja(
                      color: const Color(0xFFFFE0B2),
                      icono: Icons.wb_twilight,
                      iconoColor: Colors.orange,
                      titulo: 'MAÑANA',
                      tituloColor: Colors.orange,
                      // TODO: reemplazar con lista real del backend
                      vacio: true,
                      imagenVacio: 'assets/imagenes/mañana.jpg',
                      mensajeVacio: 'No hay eventos\nprogramados',
                    ),

                    const SizedBox(height: 12),

                    // FRANJA TARDE
                    _buildFranja(
                      color: const Color(0xFFE3F2FD),
                      icono: Icons.wb_sunny,
                      iconoColor: Colors.blue,
                      titulo: 'TARDE',
                      tituloColor: Colors.blue,
                      vacio: true,
                      imagenVacio: 'assets/imagenes/dia.jpg',
                      mensajeVacio: 'No hay eventos\nprogramados',
                    ),

                    const SizedBox(height: 12),

                    // ── FRANJA NOCHE ──────────────────────────
                    _buildFranja(
                      color: const Color(0xFFE8EAF6),
                      icono: Icons.nightlight_round,
                      iconoColor: Colors.indigo,
                      titulo: 'NOCHE',
                      tituloColor: Colors.indigo,
                      vacio: true,
                      imagenVacio: 'assets/imagenes/noche.jpg',
                      mensajeVacio: 'No hay eventos\nprogramados',
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── FOOTER ──────────────────────────────────────
            const AppFooter(),
          ],
        ),
    );
  }

  // ── Widget de franja horaria ─────────────────────────────
  Widget _buildFranja({
    required Color color,
    required IconData icono,
    required Color iconoColor,
    required String titulo,
    required Color tituloColor,
    required bool vacio,
    required String imagenVacio,
    required String mensajeVacio,
    List<Widget> tarjetas = const [],
  }) {
    return Column(
    children: [
      // ── Barra de color con título ──
      Container(
        width: double.infinity,
        color: color,
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 16),
        child: Row(
          children: [
            Icon(icono, color: iconoColor, size: 36),
            const SizedBox(width: 10),
            Text(
              titulo,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: tituloColor,
              ),
            ),
          ],
        ),
      ),

      // ── Imagen y mensaje fuera del color ──
      if (vacio)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Image.asset(imagenVacio, width: 80, height: 80,
                  fit: BoxFit.contain),
              const SizedBox(height: 8),
              Text(
                mensajeVacio,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 18,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        )
      else
      // TODO: aquí irán las tarjetas de actividades del backend
        Column(children: tarjetas),
    ],
    );
  }
}