import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/widgets/foto_detalle_card.dart';
import '../../services/medicamento_service.dart'; // Asegúrate de que esta ruta apunte a tu nueva carpeta widgets
import 'editar_medicamento_screen.dart';

class DetalleMedicamentoScreen extends StatefulWidget {
  final Map<String, dynamic> medicamento;

  const DetalleMedicamentoScreen({
    Key? key,
    required this.medicamento,
  }) : super(key: key);

  @override
  State<DetalleMedicamentoScreen> createState() =>
      _DetalleMedicamentoScreenState();
}

class _DetalleMedicamentoScreenState extends State<DetalleMedicamentoScreen> {
  final MedicamentoService _medicamentoService = MedicamentoService();
  bool _eliminando = false;

  static const Color colorPrimario = Color(0xFF000080);
  static const Color colorFondo = Colors.white;
  static const Color colorGrisFondo = Color(0xFFF3F4F6);
  static const Color colorGrisBorde = Color(0xFFD1D5DB);
  static const Color botonEditar = Color(0xFF2196F3);
  static const Color botonEliminar = Color(0xFFD32F2F);

  Future<void> _confirmarEliminar(BuildContext context, String grupoId) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          '¿Eliminar recordatorio?',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Se eliminarán todas las tomas pendientes de este medicamento. Esta acción no se puede deshacer.',
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(fontSize: 18, color: colorPrimario)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(fontSize: 18, color: botonEliminar, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmado != true) return;

    setState(() => _eliminando = true);
    final exito = await _medicamentoService.eliminarGrupoMedicamento(grupoId);
    if (!context.mounted) return;
    setState(() => _eliminando = false);

    if (exito) {
      Navigator.pop(context, true); // true = recordatorio eliminado, refrescar lista anterior
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo eliminar el recordatorio. Intenta de nuevo.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final medicamento = widget.medicamento;
    // ── DATOS REALES (vienen todos desde el endpoint /hoy) ──
    final String nombre        = medicamento['nombre']           ?? '';
    final String hora          = medicamento['hora']             ?? '00:00';
    final String dosis         = medicamento['dosis']            ?? '';
    final String frecuencia    = medicamento['frecuencia']       ?? '';
    final String instrucciones = medicamento['instrucciones']    ?? '';
    final String fotoCaja      = medicamento['url_foto_caja']    ?? '';
    final String fotoRemedio   = medicamento['url_foto_remedio'] ?? '';
    final String? grupoId      = medicamento['grupo_id'];
    final String? intervalo    = medicamento['intervalo'];

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
                          // 👇 LLAMAMOS A TU NUEVO WIDGET 👇
                          child: FotoDetalleCard(
                            etiqueta: 'CAJA',
                            rutaFoto: fotoCaja,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          // 👇 LLAMAMOS A TU NUEVO WIDGET 👇
                          child: FotoDetalleCard(
                            etiqueta: 'REMEDIO',
                            rutaFoto: fotoRemedio,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // ── BOTONES DE ACCIÓN ──
                    ElevatedButton(
                      onPressed: grupoId == null
                          ? null
                          : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditarMedicamentoScreen(
                              grupoId: grupoId,
                              nombre: nombre,
                              dosis: dosis,
                              hora: hora,
                              intervalo: intervalo,
                              instrucciones: instrucciones.isNotEmpty ? instrucciones : null,
                            ),
                          ),
                        );
                      },
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
                      onPressed: (grupoId == null || _eliminando)
                          ? null
                          : () => _confirmarEliminar(context, grupoId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: botonEliminar,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 65),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                      ),
                      child: _eliminando
                          ? const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                      )
                          : const Text(
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