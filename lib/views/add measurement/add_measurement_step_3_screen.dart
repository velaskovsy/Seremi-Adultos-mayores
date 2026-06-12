import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../viewmodels/add_measurement_viewmodel.dart';
import '../home/home_screen.dart';

class AddMeasurementStep3Screen extends StatelessWidget {
  const AddMeasurementStep3Screen({Key? key}) : super(key: key);

  // ── Popup para elegir cámara o galería ───────────────────
  void _mostrarOpcionesFoto(
      BuildContext context, AddMeasurementViewModel vm) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Seleccionar foto',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF000080), size: 32),
              title: const Text('Tomar foto', style: TextStyle(fontSize: 20)),
              onTap: () async {
                Navigator.pop(context); // Cierra el menú de abajo
                final foto = await vm.tomarFoto(ImageSource.camera);

                if (foto != null) {
                  vm.setFotoInstrumento(foto);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library,
                  color: Color(0xFF000080), size: 32),
              title: const Text('Elegir de galería',
                  style: TextStyle(fontSize: 20)),
              onTap: () async {
                Navigator.pop(context);
                final foto = await vm.tomarFoto(ImageSource.gallery);
                if (foto != null) {
                  vm.setFotoInstrumento(foto);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AddMeasurementViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [

          // ── HEADER ────────────────────────────────────────
          Container(
            width: double.infinity,
            height: 135,
            color: const Color(0xFF000080),
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
                        child: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF000080),
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      vm.tipoMedicion,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
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

          // ── CONTENIDO ─────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Título centrado
                    const Center(
                      child: Text(
                        'Añade instrucciones y\nreferencias visuales',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ── INSTRUCCIONES ─────────────────────────
                    const Text(
                      'INSTRUCCIONES',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: TextField(
                        onChanged: vm.setInstrucciones,

                        // 👇 CENTRADO Y MAGIA DINÁMICA 👇
                        textAlign: TextAlign.center,
                        minLines: 3,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,

                        style: const TextStyle(
                          fontSize: 26,
                          color: Color(0xFF000080),
                          fontWeight: FontWeight.bold,
                        ),
                        // 👇 QUITAMOS EL CONST Y AGREGAMOS TRANSPARENCIA AL HINT 👇
                        decoration: InputDecoration(
                          hintText: 'Ej: Reposar 5 minutos antes\nde tomar la medición',
                          hintStyle: TextStyle(
                            fontSize: 26,
                            color: const Color(0xFF000080).withValues(alpha: 0.5),
                            fontWeight: FontWeight.bold,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ── FOTO ──────────────────────────────────
                    const Text(
                      'FOTO',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Center(
                      child: _buildCuadroFoto(
                        context: context,
                        foto: vm.fotoInstrumento,
                        label: 'INSTRUMENTO',
                        onTap: () => _mostrarOpcionesFoto(context, vm),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // ── MENSAJE DE ERROR ──────────────────────
                    if (vm.errorGuardar != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Center(
                          child: Text(
                            vm.errorGuardar!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 24,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                    // ── BOTÓN GUARDAR ─────────────────────────
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
                          width: 319,
                          height: 65,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: vm.guardando
                                  ? Colors.grey
                                  : const Color(0xFFFF8800),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side: const BorderSide(
                                    color: Color(0xFFFF8800), width: 2),
                              ),
                            ),
                            onPressed: vm.guardando
                                ? null
                                : () async {
                              final exito = await vm.guardar();
                              if (exito && context.mounted) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const HomeScreen()),
                                      (route) => false,
                                );
                              }
                            },
                            child: vm.guardando
                                ? const CircularProgressIndicator(
                                color: Colors.white)
                                : const Text(
                              'Guardar',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 32,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Widget cuadro de foto ────────────────────────────────
  Widget _buildCuadroFoto({
    required BuildContext context,
    required XFile? foto,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black45, width: 3.5),
            ),
            child: foto != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(foto.path),
                fit: BoxFit.cover,
              ),
            )
                : const Icon(
              Icons.camera_alt,
              color: Colors.black45,
              size: 48,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}