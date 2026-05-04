import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/register_viewmodel.dart';
import '../../../core/widgets/input_field.dart';

class RegisterStep2Screen extends StatelessWidget {
  const RegisterStep2Screen({Key? key}) : super(key: key);

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

          // CONTENIDO
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
                      '¿Quiere agregar a un cuidador?',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 18,
                        color: Color(0xFF000080),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Campo nombre cuidador
                  InputField(
                    label: 'NOMBRE/APODO',
                    hint: 'Ej: Juan Tapia',
                    onChanged: vm.setNombreCuidador,
                    hintFontSize: 24,
                    verticalPadding: 20,
                  ),

                  const SizedBox(height: 20),

                  // Campo correo
                  InputField(
                    label: 'CORREO ELECTRÓNICO',
                    hint: 'Correo electrónico del cuidador',
                    onChanged: vm.setCorreoCuidador,
                    errorText: vm.errorCorreo,
                    keyboardType: TextInputType.emailAddress,
                    hintFontSize: 20,
                    verticalPadding: 20,
                  ),

                  const SizedBox(height: 20),

                  // Campo teléfono
                  InputField(
                    label: 'TELÉFONO DEL CUIDADOR',
                    hint: 'Ej: 9 1234 5678',
                    onChanged: vm.setTelefonoCuidador,
                    keyboardType: TextInputType.phone,
                    hintFontSize: 24,
                    verticalPadding: 20,
                  ),

                  const SizedBox(height: 40),

                  // Botón Omitir
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4), // intensidad de la sombra, recordar cambiar a .withValues()
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
                          backgroundColor: Color(0xFF000080),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: const BorderSide(color: Color(0xFF000080), width: 4),
                          ),
                        ),
                        onPressed: () {
                          // TODO: navegar al home sin agregar cuidador
                        },
                        child: const Text(
                          'Omitir',
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

                  const SizedBox(height: 16),

                  // Botón Siguiente
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4), // intensidad de la sombra, recordar cambiar a .withValues()
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
                            side: const BorderSide(color: Color(0xFFFF8800), width: 4),
                          ),
                        ),
                        onPressed: vm.isLoading
                            ? null
                            : () async {
                          if (vm.validarPaso2()) {
                            await vm.registrar();
                            // TODO: navegar al home
                          }
                        },
                        child: vm.isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
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
