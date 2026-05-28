import 'package:flutter/material.dart';
// Importación exacta que tienes configurada en tu proyecto
import '../semaforizacion/resultado_semaforizacion_screen.dart';

class AddMeasurementPresionAfterAlarm extends StatefulWidget {
  const AddMeasurementPresionAfterAlarm({Key? key}) : super(key: key);

  @override
  _AddMeasurementPresionAfterAlarmState createState() => _AddMeasurementPresionAfterAlarmState();
}

class _AddMeasurementPresionAfterAlarmState extends State<AddMeasurementPresionAfterAlarm> {
  final TextEditingController _valueController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  static const Color appNavBarColor = Color(0xFF000080);
  static const Color inputTextColor = Color(0xFF000080);
  static const Color primaryButtonColor = Color(0xFFFF8800);

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  /// Procesa el guardado y salta a la pantalla de semaforización
  void _guardarMedicion() {
    if (_formKey.currentState!.validate()) {
      print('Medición guardada: ${_valueController.text}');

      // 1. Obtenemos el texto plano ingresado por el usuario (Ej: "120/80")
      String valorPresion = _valueController.text.trim();

      // 2. Transición tradicional (Push) a la pantalla de semaforización pasándole el String
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultadoMedicionScreen(presionString: valorPresion),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appNavBarColor,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Presión Arterial',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  Center(
                    child: const Text(
                      '¿Qué valor le dió el instrumento?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'VALOR',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _valueController,
                    keyboardType: TextInputType.text,
                    style: const TextStyle(
                      fontSize: 20,
                      color: inputTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      errorMaxLines: 3,
                      errorStyle: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                      hintText: 'Ej: 120 / 80',
                      hintStyle: TextStyle(
                        color: inputTextColor.withOpacity(0.6),
                        fontSize: 32,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),

                      // Bordes normales y enfocados
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: const BorderSide(color: Colors.black, width: 4.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: const BorderSide(color: Colors.black, width: 4.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: const BorderSide(color: Colors.black, width: 4.0),
                      ),

                      // Bordes de error
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: const BorderSide(color: Colors.red, width: 4.0),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: const BorderSide(color: Colors.red, width: 4.0),
                      ),

                      suffixText: 'mmHg',
                      suffixStyle: const TextStyle(
                        color: inputTextColor,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingrese el valor que marcó su aparato.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Escriba el valor tal como aparece en su tensiómetro (incluyendo la barra si la tiene).',
                    style: TextStyle(
                      fontSize: 24,
                      color: Color(0xFF000080),
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 24.0, bottom: 60.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                      backgroundColor: primaryButtonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: const BorderSide(color: primaryButtonColor, width: 2),
                      ),
                    ),
                    onPressed: _guardarMedicion, // Ejecuta la función modificada
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
          ],
        ),
      ),
    );
  }
}