import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../services/activity_service.dart';
import 'editar_actividad_screen.dart';

class DetalleActividadScreen extends StatefulWidget {
  final Map<String, dynamic> actividad;

  const DetalleActividadScreen({
    Key? key,
    required this.actividad,
  }) : super(key: key);

  @override
  State<DetalleActividadScreen> createState() => _DetalleActividadScreenState();
}

class _DetalleActividadScreenState extends State<DetalleActividadScreen> {
  final ActivityService _actividadService = ActivityService();
  bool _eliminando = false;

  static const Color colorPrimario = Color(0xFF000080);
  static const Color colorFondo = Colors.white;
  static const Color colorGrisFondo = Color(0xFFF3F4F6);
  static const Color colorGrisBorde = Color(0xFFD1D5DB);
  static const Color botonEditar = Color(0xFF2196F3);
  static const Color botonEliminar = Color(0xFFD32F2F);

  Future<void> _confirmarEliminar(BuildContext context, int id) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('¿Eliminar recordatorio?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        content: const Text('Se eliminará esta toma de actividad. Esta acción no se puede deshacer.', style: TextStyle(fontSize: 18)),
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
    final exito = await _actividadService.eliminarActividad(id);
    if (!context.mounted) return;
    setState(() => _eliminando = false);

    if (exito) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo eliminar el recordatorio. Intenta de nuevo.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final actividad = widget.actividad;

    final int? id     = actividad['id'] is int ? actividad['id'] : int.tryParse(actividad['id']?.toString() ?? '');
    final String nombre  = actividad['nombre']  ?? 'Actividad';
    final String hora    = actividad['hora']    ?? '00:00';
    final String detalle = actividad['detalle'] ?? '';

    return Scaffold(
      backgroundColor: colorFondo,
      body: Column(
        children: [
          // ── HEADER ──
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
                        width: 46, height: 46,
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_back, color: Color(0xFF000080), size: 28),
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Text('Detalle del evento', textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'Roboto', fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 62),
                ],
              ),
            ),
          ),

          // ── CONTENIDO ──
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Icono y nombre
                    Column(
                      children: [
                        Container(
                          width: 100, height: 100,
                          decoration: BoxDecoration(color: const Color(0xFFB200FF), borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.all(16),
                          child: SvgPicture.asset(
                            'assets/imagenes/iconos/walking.svg',
                            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                            placeholderBuilder: (context) => const Icon(Icons.directions_walk, color: Colors.white, size: 60),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(nombre, textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black)),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Detalles
                    const Text('DETALLES', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
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
                          // 👇 EL IF DESAPARECE. EL CUADRO SIEMPRE ESTÁ 👇
                          const Divider(color: colorGrisBorde, thickness: 2, height: 0),
                          _buildDetalleFila('Cantidad', detalle.isNotEmpty ? detalle : '--'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 50),

                    // Botón Editar
                    ElevatedButton(
                      onPressed: id == null
                          ? null
                          : () async {
                        final editado = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditarActividadScreen(
                              id: id,
                              nombre: nombre,
                              hora: hora,
                              detalle: detalle.isNotEmpty ? detalle : null,
                            ),
                          ),
                        );
                        if (editado == true && context.mounted) {
                          Navigator.pop(context, true);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: botonEditar,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 65),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                      ),
                      child: const Text('Editar recordatorio', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 16),

                    // Botón Eliminar
                    ElevatedButton(
                      onPressed: (id == null || _eliminando) ? null : () => _confirmarEliminar(context, id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: botonEliminar,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 65),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                      ),
                      child: _eliminando
                          ? const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                          : const Text('Eliminar recordatorio', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
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
          Expanded(child: Text(etiqueta, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black))),
          Flexible(child: Text(valor, textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: colorPrimario),
              maxLines: 2, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}