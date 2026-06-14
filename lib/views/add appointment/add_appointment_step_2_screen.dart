import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/add_appointment_viewmodel.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../home/home_screen.dart';

class AddAppointmentStep2Screen extends StatelessWidget {
  const AddAppointmentStep2Screen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AddAppointmentViewModel>(context);

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
                        child: const Icon(Icons.arrow_back,
                            color: Color(0xFF000080), size: 28),
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Añadir\nCita',
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

          // ── CONTENIDO ─────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

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

                    // PROFESIONAL DE SALUD
                    const Text(
                      'PROFESIONAL DE SALUD',
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
                        border: Border.all(color: Colors.black, width: 4),
                      ),
                      child: TextField(
                        onChanged: vm.setProfesional,

                        // 👇 AQUÍ ESTÁ EL CENTRADO DE TEXTO QUE FALTABA
                        textAlign: TextAlign.center,

                        minLines: 1,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,

                        style: const TextStyle(
                          fontSize: 32,
                          color: Color(0xFF000080),
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Ej: Doctor Juan García',
                          hintStyle: TextStyle(
                            fontSize: 32,
                            color: const Color(0xFF000080).withValues(alpha: 0.5),
                            fontWeight: FontWeight.bold,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),

                    // Error profesional
                    if (vm.errorProfesional != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          vm.errorProfesional!,
                          style: const TextStyle(
                              color: Colors.red, fontSize: 24),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // NOTAS
                    const Text(
                      'NOTAS',
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
                        border: Border.all(color: Colors.black, width: 4),
                      ),
                      child: TextField(
                        onChanged: vm.setNotas,
                        textAlign: TextAlign.center,
                        minLines: 3,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,

                        style: const TextStyle(
                          fontSize: 32,
                          color: Color(0xFF000080),
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Ej: Ir en ayuna',
                          hintStyle: TextStyle(
                            fontSize: 32,
                            color: const Color(0xFF000080).withValues(alpha: 0.5),
                            fontWeight: FontWeight.bold,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Error guardar
                    if (vm.errorGuardar != null)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            vm.errorGuardar!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                    // BOTÓN GUARDAR
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
                              if (vm.validarPaso2()) {
                                final exito = await vm.guardar();
                                if (exito && context.mounted) {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                                        (route) => false,
                                  );
                                }
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
}