import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../viewmodels/add_medication_viewmodel.dart';
import '../home/home_screen.dart';

class AddMedicationStep4Screen extends StatelessWidget {
  const AddMedicationStep4Screen({Key? key}) : super(key: key);

  // Popup para elegir cámara o galería
  void _mostrarOpcionesFoto(
      BuildContext context, AddMedicationViewModel vm, bool esCaja) {
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
              leading: const Icon(Icons.camera_alt,
                  color: Color(0xFF000080), size: 32),
              title: const Text('Tomar foto',
                  style: TextStyle(fontSize: 20)),
              onTap: () async {
                Navigator.pop(context);
                final foto =
                await vm.tomarFoto(ImageSource.camera);
                if (foto != null) {
                  _confirmarFoto(context, vm, foto, esCaja);
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
                final foto =
                await vm.tomarFoto(ImageSource.gallery);
                if (foto != null) {
                  if (esCaja) {
                    vm.setFotoCaja(foto);
                  } else {
                    vm.setFotoRemedio(foto);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Confirmación de foto tomada con cámara
  void _confirmarFoto(BuildContext context, AddMedicationViewModel vm,
      XFile foto, bool esCaja) {
    showDialog(
      context: context,
      builder: (_) => Stack(
        children: [
          // Foto de fondo
          Positioned.fill(
            child: Image.file(
              File(foto.path),
              fit: BoxFit.cover,
            ),
          ),

          // Botones en la parte central inferior
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ✗ Desechar
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close,
                        color: Colors.white, size: 36),
                  ),
                ),

                const SizedBox(width: 40),

                // ✓ Guardar
                GestureDetector(
                  onTap: () {
                    if (esCaja) {
                      vm.setFotoCaja(foto);
                    } else {
                      vm.setFotoRemedio(foto);
                    }
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check,
                        color: Colors.white, size: 36),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AddMedicationViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [

          // HEADER
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
                  const Expanded(
                    child: Text(
                      'Añadir\nMedicamento',
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

          // CONTENIDO
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 34, vertical: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Título
                    Center(
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

                    // INSTRUCCIONES
                    const Text(
                      'INSTRUCCIONES',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.black, width: 4),
                      ),
                      child: TextField(
                        maxLines: 4,
                        onChanged: vm.setInstrucciones,
                        style: const TextStyle(fontSize: 20),
                        decoration: const InputDecoration(
                          hintText:
                          'Ej: no masticar la pastilla y tomar\ncon abundante líquido',
                          hintStyle: TextStyle(
                              fontSize: 20,
                              color: Color(0xFF000080),
                              fontWeight: FontWeight.bold
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // FOTOS
                    const Text(
                      'FOTOS',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Foto caja
                        _buildCuadroFoto(
                          context: context,
                          foto: vm.fotoCaja,
                          label: 'CAJA',
                          onTap: () =>
                              _mostrarOpcionesFoto(context, vm, true),
                        ),

                        const SizedBox(width: 20),

                        // Foto remedio
                        _buildCuadroFoto(
                          context: context,
                          foto: vm.fotoRemedio,
                          label: 'REMEDIO',
                          onTap: () =>
                              _mostrarOpcionesFoto(context, vm, false),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // BOTÓN GUARDAR
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              offset: const Offset(0, 6),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: SizedBox(
                          width: 319,
                          height: 65,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF8800),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side: const BorderSide(
                                    color: Color(0xFFFF8800), width: 2),
                              ),
                            ),
                            onPressed: () async {
                              await vm.guardar();
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const HomeScreen()),
                                    (route) => false,
                              );
                            },
                            child: const Text(
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

  // Widget cuadro de foto
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