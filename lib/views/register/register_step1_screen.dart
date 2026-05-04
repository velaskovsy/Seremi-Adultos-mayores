import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/register_viewmodel.dart';
import '../register/register_step2_screen.dart';
import '../../../core/widgets/input_field.dart';

class RegisterStep1Screen extends StatelessWidget {
  const RegisterStep1Screen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<RegisterViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [

          // ── HEADER ────────────────────────────────────────
          Container(
            width: 412,
            height: 135,
            color: const Color(0xFF000080),
            child: Row(
              children: [
                // Botón volver atrás
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
                    'Registrarse',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Espacio para balancear el botón de la izquierda
                const SizedBox(width: 62),
              ],
            ),
          ),

          // ── CONTENIDO ─────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // Texto guía
                  const Padding(
                    padding: EdgeInsets.only(left: 34),
                    child: Text(
                      'Ingrese los datos del adulto mayor',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 18,
                        color: Color(0xFF000080),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Campo nombre
                  InputField(
                    label: 'NOMBRE/APODO',
                    hint: 'Ej: Juan Tapia',
                    onChanged: vm.setNombre,
                    errorText: vm.errorNombre,
                    hintFontSize: 30,
                    verticalPadding: 20,
                  ),

                  const SizedBox(height: 20),

                  // Campo RUT
                  InputField(
                    label: 'RUT (SIN PUNTOS, CON GUIÓN)',
                    hint: 'Ej: 12345678-9',
                    onChanged: vm.setRut,
                    errorText: vm.errorRut,
                    hintFontSize: 30,
                    verticalPadding: 20,
                  ),

                  const SizedBox(height: 20),

                  // Campo PIN
                  InputField(
                    label: 'CONTRASEÑA DE LA CUENTA',
                    hint: 'Ingrese un pin de 4 dígitos',
                    onChanged: vm.setPin,
                    errorText: vm.errorPin,
                    isPassword: true, // se muestra el texto mientras escribe
                    passwordVisible: vm.pinVisible,
                    onToggleVisibility: vm.togglePinVisible,
                    hintFontSize: 20,
                    verticalPadding: 40,
                  ),

                  const SizedBox(height: 40),

                  // Botón Siguiente
                  Center(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4), // intensidad de la sombra
                              offset: const Offset(0, 6),           // posición (x, y)
                              blurRadius: 8,                        // qué tan difusa
                            ),
                          ],
                        ),
                      child: SizedBox(
                        width: 319,
                        height: 65,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFF8800),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: const BorderSide(color: Color(0xFFFF8800), width: 2),
                            ),
                          ),
                          onPressed: () {
                            if (vm.validarPaso1()) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RegisterStep2Screen(),
                                ),
                              );
                            }
                          },
                          child: const Text(
                            'Siguiente',
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
        ],
      ),
    );
  }
}
