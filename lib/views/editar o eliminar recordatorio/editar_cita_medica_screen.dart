import 'package:flutter/material.dart';
import '../../services/cita_medica_service.dart';

class EditarCitaMedicaScreen extends StatefulWidget {
  final int id;
  final String hora;
  final String lugar;
  final String profesional;
  final String? notas;

  const EditarCitaMedicaScreen({
    Key? key,
    required this.id,
    required this.hora,
    required this.lugar,
    required this.profesional,
    this.notas,
  }) : super(key: key);

  @override
  State<EditarCitaMedicaScreen> createState() => _EditarCitaMedicaScreenState();
}

class _EditarCitaMedicaScreenState extends State<EditarCitaMedicaScreen> {
  final CitaMedicaService _citaService = CitaMedicaService();

  late TextEditingController _lugarCtrl;
  late TextEditingController _profesionalCtrl;
  late TextEditingController _notasCtrl;
  late TimeOfDay _hora;

  bool _guardando = false;
  String? _error;

  static const Color colorPrimario = Color(0xFF000080);
  static const Color colorGrisFondo = Color(0xFFF3F4F6);
  static const Color colorGrisBorde = Color(0xFFD1D5DB);

  @override
  void initState() {
    super.initState();
    _lugarCtrl       = TextEditingController(text: widget.lugar);
    _profesionalCtrl = TextEditingController(text: widget.profesional);
    _notasCtrl       = TextEditingController(text: widget.notas ?? '');
    final partes = widget.hora.split(':');
    _hora = TimeOfDay(
      hour:   int.tryParse(partes[0]) ?? 8,
      minute: int.tryParse(partes.length > 1 ? partes[1] : '0') ?? 0,
    );
  }

  @override
  void dispose() {
    _lugarCtrl.dispose();
    _profesionalCtrl.dispose();
    _notasCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarHora() async {
    final nueva = await showTimePicker(context: context, initialTime: _hora);
    if (nueva != null) setState(() => _hora = nueva);
  }

  Future<void> _guardar() async {
    if (_lugarCtrl.text.trim().isEmpty || _profesionalCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Lugar y profesional son obligatorios');
      return;
    }

    setState(() { _guardando = true; _error = null; });

    final h = _hora.hour.toString().padLeft(2, '0');
    final m = _hora.minute.toString().padLeft(2, '0');

    final exito = await _citaService.editarCita(
      id:          widget.id,
      hora:        '$h:$m',
      lugar:       _lugarCtrl.text.trim(),
      profesional: _profesionalCtrl.text.trim(),
      notas:       _notasCtrl.text.trim().isNotEmpty ? _notasCtrl.text.trim() : null,
    );

    if (!mounted) return;
    setState(() => _guardando = false);

    if (exito) {
      Navigator.pop(context, true);
    } else {
      setState(() => _error = 'No se pudo guardar. Intenta de nuevo.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final horaTexto =
        '${_hora.hour.toString().padLeft(2, '0')}:${_hora.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: Colors.white,
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
                    child: Text('Editar cita médica', textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'Roboto', fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 62),
                ],
              ),
            ),
          ),

          // ── FORMULARIO ──
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Hora
                    const Text('HORA', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: _seleccionarHora,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        decoration: BoxDecoration(
                          color: colorGrisFondo,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colorGrisBorde, width: 2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(horaTexto, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: colorPrimario)),
                            const Icon(Icons.access_time, color: colorPrimario, size: 28),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Lugar
                    _buildCampo('LUGAR', _lugarCtrl, 'Ej: Clínica los Carrera'),
                    const SizedBox(height: 24),

                    // Profesional
                    _buildCampo('PROFESIONAL DE LA SALUD', _profesionalCtrl, 'Ej: Doctor Juan García'),
                    const SizedBox(height: 24),

                    // Notas
                    _buildCampo('NOTAS (opcional)', _notasCtrl, 'Ej: Ir en ayunas', maxLines: 3),
                    const SizedBox(height: 16),

                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 18)),
                      ),

                    // Botón guardar
                    ElevatedButton(
                      onPressed: _guardando ? null : _guardar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorPrimario,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 65),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                      ),
                      child: _guardando
                          ? const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                          : const Text('Guardar cambios', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
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

  Widget _buildCampo(String etiqueta, TextEditingController ctrl, String hint, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(etiqueta, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
        const SizedBox(height: 10),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: colorPrimario),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 20),
            filled: true,
            fillColor: colorGrisFondo,
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 2)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 2)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: colorPrimario, width: 2)),
          ),
        ),
      ],
    );
  }
}
