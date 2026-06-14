import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DetalleMedicamentoScreen extends StatelessWidget {
  final Map<String, dynamic> medicamento;

  const DetalleMedicamentoScreen({
    Key? key,
    required this.medicamento,
  }) : super(key: key);

  static const Color colorPrimario = Color(0xFF000080);
  static const Color colorFondo = Colors.white;
  static const Color colorGrisFondo = Color(0xFFF3F4F6);
  static const Color colorGrisBorde = Color(0xFFD1D5DB);
  static const Color botonEditar = Color(0xFF2196F3);
  static const Color botonEliminar = Color(0xFFD32F2F);

  @override
  Widget build(BuildContext context) {
    // ── DATOS REALES (vienen todos desde el endpoint /hoy) ──
    final String nombre        = medicamento['nombre']           ?? '';
    final String hora          = medicamento['hora']             ?? '00:00';
    final String dosis         = medicamento['dosis']            ?? '';
    final String frecuencia    = medicamento['frecuencia']       ?? '';
    final String instrucciones = medicamento['instrucciones']    ?? '';
    final String fotoCaja      = medicamento['url_foto_caja']    ?? '';
    final String fotoRemedio   = medicamento['url_foto_remedio'] ?? '';

    return Scaffold(
      backgroundColor: colorFondo,
      body: Column(
        children: [
          // ── HEADER PERSONALIZADO (Estilo Home) ──
          Container(
            width: double.infinity,
            height: 135,
            color: colorPrimario,
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Row(
                children: [
                  // Botón Volver
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
                        child: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF000080),
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                  // Título centrado
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
                  // Espaciador invisible
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
                            color: const Color(0xFF00E600),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: SvgPicture.asset(
                            'assets/imagenes/iconos/medicines.svg',
                            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                            placeholderBuilder: (context) => const Icon(Icons.medication, color: Colors.white, size: 60),
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

                    const SizedBox(height: 30),

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
                          // 👇 AQUÍ ESTÁ EL TERCER CUADRITO DE LA HORA 👇
                          _buildDetalleFila('Hora del\nrecordatorio', hora),
                          const Divider(color: colorGrisBorde, thickness: 2, height: 0),
                          _buildDetalleFila('Dosis', dosis),
                          const Divider(color: colorGrisBorde, thickness: 2, height: 0),
                          _buildDetalleFila('Frecuencia', frecuencia),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ── SECCIÓN: INSTRUCCIONES ──
                    if (instrucciones.isNotEmpty) ...[
                      const Text(
                        'INSTRUCCIONES',
                        style: TextStyle(
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
                          border: Border.all(color: Colors.black, width: 3),
                        ),
                        child: Text(
                          instrucciones,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: colorPrimario,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],

                    // ── SECCIÓN: FOTOS ──
                    const Text(
                      'FOTOS',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildFotoCard('CAJA', fotoCaja),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildFotoCard('REMEDIO', fotoRemedio),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // ── BOTONES DE ACCIÓN ──
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: botonEditar,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 65),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4, // 👈 Sombras listas
                      ),
                      child: const Text(
                        'Editar recordatorio',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold), // 👈 Textos en Bold
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
                        elevation: 4, // 👈 Sombras listas
                      ),
                      child: const Text(
                        'Eliminar recordatorio',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold), // 👈 Textos en Bold
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
          // 👈 El Expanded previene que se rompa el diseño con textos largos como "Hora del recordatorio"
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

  Widget _buildFotoCard(String etiqueta, String rutaFoto) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: colorGrisFondo,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade500, width: 2),
      ),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: rutaFoto.isNotEmpty
                  ? ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child: Image.network(
                        rutaFoto,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        loadingBuilder: (context, child, progress) =>
                            progress == null ? child : const CircularProgressIndicator(),
                        errorBuilder: (context, error, stack) =>
                            Icon(Icons.broken_image_outlined, size: 50, color: Colors.grey.shade500),
                      ),
                    )
                  : Icon(Icons.camera_alt_outlined, size: 50, color: Colors.grey.shade500),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade500, width: 2)),
            ),
            child: Text(
              etiqueta,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorPrimario,
              ),
            ),
          ),
        ],
      ),
    );
  }
}