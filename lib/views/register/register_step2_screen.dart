import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/register_viewmodel.dart';
import '../home/home_screen.dart';
import '../../../core/widgets/input_field.dart';

class RegisterStep2Screen extends StatelessWidget {
  const RegisterStep2Screen({Key? key}) : super(key: key);

  // Popup de registro exitoso
  void _mostrarPopupExito(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // no se cierra tocando afuera
      builder: (_) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 15), // ← más ancho
        contentPadding: const EdgeInsets.fromLTRB(40, 30, 40, 40),  // ← más espacio interno
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text(
          '¡Registro exitoso!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Color(0xFF000080),
          ),
        ),
        content: const Text(
          'Has sido registrado exitosamente.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 24,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8800),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 14),
            ),
            onPressed: () {
              // Cierra el popup y navega al home
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false, // elimina toda la pila de navegación
              );
            },
            child: const Text(
              'Continuar',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 30,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<RegisterViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [

          // HEADER
          Container(
            width: double.infinity,
            height: 135,
            color: const Color(0xFF000080),
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

                  const Padding(
                    padding: EdgeInsets.only(left: 37),
                    child: Text(
                      '¿Quiere agregar a un cuidador?',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 24,
                        color: Color(0xFF000080),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  InputField(
                    label: 'NOMBRE/APODO',
                    hint: 'Ej: Juan Tapia',
                    onChanged: vm.setNombreCuidador,
                    errorText: vm.errorNombreCuidador,
                    hintFontSize: 30,
                    verticalPadding: 17,
                  ),

                  const SizedBox(height: 20),

                  InputField(
                    label: 'CORREO ELECTRÓNICO',
                    hint: 'Correo electrónico del cuidador',
                    onChanged: vm.setCorreoCuidador,
                    errorText: vm.errorCorreo,
                    keyboardType: TextInputType.emailAddress,
                    hintFontSize: 20,
                    verticalPadding: 15,
                  ),

                  const SizedBox(height: 20),

                  InputField(
                    label: 'TELÉFONO DEL CUIDADOR',
                    hint: 'Ej: 9 1234 5678',
                    onChanged: vm.setTelefonoCuidador,
                    errorText: vm.errorTelefono,
                    keyboardType: TextInputType.phone,
                    hintFontSize: 30,
                    verticalPadding: 17,
                  ),

                  const SizedBox(height: 40),

                  // BOTÓN OMITIR
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
                            backgroundColor: const Color(0xFF000080),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: const BorderSide(color: Color(0xFF000080), width: 4),
                            ),
                          ),
                          onPressed: () async {
                            final exito = await vm.registrar();
                            if (exito) {
                              _mostrarPopupExito(context);
                            }
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

                  // BOTÓN SIGUIENTE
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
                            backgroundColor: const Color(0xFFFF8800),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: const BorderSide(color: Color(0xFFFF8800), width: 4),
                            ),
                          ),
                          onPressed: vm.isLoading ? null : () async {
                            if (vm.validarPaso2()) {
                              final exito = await vm.registrar(conCuidador: true);
                              if (exito) {
                                _mostrarPopupExito(context);
                              }
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