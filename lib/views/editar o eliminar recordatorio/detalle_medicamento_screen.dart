import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DetalleMedicamentoScreen extends StatelessWidget {
  // Ahora es explícitamente un medicamento
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
    // Extraemos los datos apuntando a la variable correcta
    final String nombre = medicamento['nombre'] ?? 'Desconocido';
    final String dosis = medicamento['dosis'] ?? '';
    final String hora = medicamento['hora'] ?? '--:--';
    final String frecuencia = medicamento['frecuencia'] ?? 'Única vez';
    final String instrucciones = medicamento['instrucciones'] ?? '';

    final String fotoCaja = medicamento['foto_caja'] ?? '';
    final String fotoRemedio = medicamento['foto_remedio'] ?? '';
    final bool tieneFotos = fotoCaja.isNotEmpty || fotoRemedio.isNotEmpty;

    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        backgroundColor: colorPrimario,
        centerTitle: true,
        title: const Text(
          'Detalle del medicamento', // Actualizado
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                // ── HEADER: ICONO, NOMBRE Y DOSIS ──
                Column(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00D000),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: SvgPicture.asset(
                        'assets/icons/medicines.svg',
                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                        placeholderBuilder: (context) => const Icon(Icons.medication, color: Colors.white, size: 50),
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
                    if (dosis.isNotEmpty)
                      Text(
                        dosis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: colorPrimario,
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
                  child: Column(
                    children: [
                      _buildHorarioFila('Hora de la\ntoma', hora),
                      const Divider(color: colorGrisBorde, thickness: 2, height: 0),
                      _buildHorarioFila('Frecuencia', frecuencia),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // ── SECCIÓN CONDICIONAL: INSTRUCCIONES ──
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
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: colorPrimario,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],

                // ── SECCIÓN CONDICIONAL: FOTOS ──
                if (true) ...[
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
                ],

                // ── BOTONES DE ACCIÓN ──
                ElevatedButton(
                  onPressed: () {
                    // Lógica para editar
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: botonEditar,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 65),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                  ),
                  child: const Text(
                    'Editar recordatorio',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Lógica para eliminar
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: botonEliminar,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 65),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
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
    );
  }

  Widget _buildHorarioFila(String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            etiqueta,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          Text(
            valor,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: colorPrimario,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFotoCard(String etiqueta, String rutaFoto) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: colorGrisFondo,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400, width: 2),
      ),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: rutaFoto.isNotEmpty
                  ? Text('Cargar imagen: $rutaFoto')
                  : Icon(Icons.camera_alt_outlined, size: 60, color: Colors.grey.shade500),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade400, width: 2)),
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