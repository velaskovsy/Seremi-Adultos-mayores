import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/login_viewmodel.dart';
import '../../core/widgets/input_field.dart';
import '../register/register_step1_screen.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Escucha al ViewModel: cuando llama notifyListeners(), esta pantalla se redibuja
    final vm = Provider.of<LoginViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [

            // HEADER
            Container(
              width: 412,
              height: 135,
              color: const Color(0xFF000080),
              alignment: Alignment.center,
              child: const Text(
                'Nombre\nde la app',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // texto INICIAR SESIÓN
            const Text(
              'INICIAR SESIÓN',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF000080),
              ),
            ),

            const SizedBox(height: 30),

            // CAMPO RUT
            InputField(
              label: 'RUT (SIN PUNTOS, CON GUIÓN)',
              hint: '12345678-9',
              isPassword: false,
              errorText: vm.errorRut,       // muestra error si hay
              onChanged: vm.setRut,         // delega al ViewModel
              verticalPadding: 24,
              hintFontSize: 32,
            ),

            // Esto sirve para dar un espacio vertical entre elementos, si se cambia las cajas de los
            // inputs se van a "pegar" más
            const SizedBox(height: 20),

            // CAMPO CONTRASEÑA (PIN)
            InputField(
              label: 'CONTRASEÑA',
              hint: '****',
              isPassword: true,
              passwordVisible: vm.pinVisible,
              errorText: vm.errorPin,
              onChanged: vm.setPin,
              onToggleVisibility: vm.togglePinVisible,
              verticalPadding: 20,
              hintFontSize: 40,
            ),

            const SizedBox(height: 10),

            // Opción de ¿OLVIDÓ SU CLAVE?
            TextButton(
              onPressed: () {
                // TODO: navegar a pantalla de recuperación
              },
              child: const Text(
                '¿OLVIDÓ SU CLAVE?',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Botón ENTRAR
            Container(
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
                width: 344,
                height: 95,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF8800),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: const BorderSide(color: Colors.orange, width: 4),
                    ),
                  ),
                  // Si está cargando, deshabilita el botón
                  onPressed: vm.isLoading ? null : vm.login,
                  child: vm.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'ENTRAR',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 64,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Opción de REGISTRARSE
            TextButton(
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterStep1Screen()),
                );
              },
              child: const Text(
                'REGISTRARSE',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
