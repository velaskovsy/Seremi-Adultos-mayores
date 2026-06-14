import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../semaforizacion/resultado_semaforizacion_screen.dart';
import '../alarma_presion/alerta_critica_presion_alta.dart';
import '../../core/utils/presion_formatter.dart';
import '../../services/notificacion_cuidador_service.dart'; // ✅ NUEVO

class AddMeasurementPresionAfterAlarm extends StatefulWidget {
  final bool esRepeticion;
  final String instruccionesOriginales;

  const AddMeasurementPresionAfterAlarm({
    Key? key,
    this.esRepeticion = false,
    this.instruccionesOriginales = 'Use su tensiómetro habitual para medir la presión.',
  }) : super(key: key);

  @override
  _AddMeasurementPresionAfterAlarmState createState() =>
      _AddMeasurementPresionAfterAlarmState();
}

class _AddMeasurementPresionAfterAlarmState
    extends State<AddMeasurementPresionAfterAlarm> {
  final TextEditingController _valueController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  static const Color appNavBarColor    = Color(0xFF000080);
  static const Color inputTextColor    = Color(0xFF000080);
  static const Color primaryButtonColor = Color(0xFFFF8800);

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  void _guardarMedicion() {
    if (_formKey.currentState!.validate()) {
      String valorPresion = _valueController.text.trim();

      List<String> partes    = valorPresion.split('/');
      int sistolica          = int.tryParse(partes[0].trim()) ?? 0;
      int diastolica         = (partes.length > 1) ? (int.tryParse(partes[1].trim()) ?? 0) : 0;
      bool esAlta            = (sistolica >= 140 || diastolica >= 90);

      if (widget.esRepeticion && esAlta) {
        // ✅ NUEVO — Trigger 3 (atajo directo): segunda medición sigue alta
        final String nivel = (sistolica >= 200 || diastolica >= 150) ? 'critico' : 'elevado';
        NotificacionCuidadorService().presionCritica(
          valorPresion: valorPresion,
          nivel:        nivel,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AlertaCriticaPresionAltaScreen(
              presionString: valorPresion,
            ),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResultadoMedicionScreen(
              presionString:         valorPresion,
              esRepeticion:          widget.esRepeticion,
              instruccionesOriginales: widget.instruccionesOriginales,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 135,
            color: appNavBarColor,
            padding: const EdgeInsets.only(top: 40),
            alignment: Alignment.center,
            child: const Text(
              'Presión Arterial',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),
                      const Center(
                        child: Text(
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
                        keyboardType: TextInputType.number,
                        inputFormatters: [PresionFormatter()],
                        style: const TextStyle(
                          fontSize: 32,
                          color: inputTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          errorMaxLines: 3,
                          errorStyle: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red),
                          hintText: 'Ej: 120 / 80',
                          hintStyle: TextStyle(
                              color: inputTextColor.withOpacity(0.6), fontSize: 32),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 18),
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
                              color: inputTextColor, fontSize: 32, fontWeight: FontWeight.bold),
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
                        'Escriba el valor tal como aparece en su tensiómetro\n\nEscriba los números seguidos, la barra "/" se pondrá de forma automática.',
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
        ],
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
                      color: Colors.black.withOpacity(0.3),
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
                    onPressed: _guardarMedicion,
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
