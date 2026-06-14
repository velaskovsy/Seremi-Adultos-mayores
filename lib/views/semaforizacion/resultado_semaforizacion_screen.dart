import 'package:flutter/material.dart';

import '../../services/notificacion_service.dart';
import '../../services/medicion_service.dart';
import '../../services/notificacion_cuidador_service.dart'; // ✅ NUEVO
import '../alarma_presion/alerta_critica_presion_alta.dart';
import '../home/home_screen.dart';

class ResultadoMedicionScreen extends StatelessWidget {
  final String presionString;
  final bool esRepeticion;
  final String instruccionesOriginales;

  const ResultadoMedicionScreen({
    Key? key,
    required this.presionString,
    this.esRepeticion = false,
    this.instruccionesOriginales = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> partes = presionString.split('/');
    int sistolica  = int.tryParse(partes[0].trim()) ?? 0;
    int diastolica = (partes.length > 1) ? (int.tryParse(partes[1].trim()) ?? 0) : 0;

    Color     backgroundColor;
    Color     statusColor;
    IconData  iconData;
    String    titulo;
    String    mensaje;
    String    textoBoton;

    bool esCritico = false;
    bool esElevado = false;

    if (sistolica >= 200 || diastolica >= 150) {
      esCritico       = true;
      backgroundColor = const Color(0xFFFFC5C5);
      statusColor     = Colors.red;
      iconData        = Icons.error_outline;
      titulo          = '¡ALERTA\nCRÍTICA!';
      mensaje         = 'Siéntese y repose por 30 minutos. Evite tomar café o agitarse. Si no baja avise a su cuidador';
      textoBoton      = esRepeticion ? 'VER OPCIONES DE EMERGENCIA' : 'REPETIR MEDICIÓN\nEN 30 MINUTOS';
    } else if (sistolica >= 140 || diastolica >= 90) {
      esElevado       = true;
      backgroundColor = const Color(0xFFFFF9C4);
      statusColor     = const Color(0xFFB71C1C);
      iconData        = Icons.warning_amber_rounded;
      titulo          = 'PRESIÓN\nELEVADA';
      mensaje         = 'Siéntese y repose por 30 minutos. Evite tomar café o agitarse. Si no baja avise a su cuidador';
      textoBoton      = esRepeticion ? 'VER OPCIONES DE EMERGENCIA' : 'REPETIR MEDICIÓN\nEN 30 MINUTOS';
    } else {
      backgroundColor = const Color(0xFFC8E6C9);
      statusColor     = const Color(0xFF1AA23A);
      iconData        = Icons.check_circle_outline_rounded;
      titulo          = 'TODO BIEN';
      mensaje         = 'Su presión arterial está en niveles normales. Siga manteniendo sus hábitos saludables';
      textoBoton      = 'ENTENDIDO';
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  const SizedBox(height: 20),
                  Icon(iconData, color: statusColor, size: 90),
                  const SizedBox(height: 10),
                  Text(
                    titulo,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: statusColor, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  if (esCritico || esElevado) ...[
                    const SizedBox(height: 12),
                    const Text(
                      '¿Recordaste tomarte tu remedio?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ],
              ),
              Card(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        decoration: BoxDecoration(
                            color: const Color(0xFFD2E3FC),
                            borderRadius: BorderRadius.circular(30)),
                        child: Text(
                          '$presionString mmHg',
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0D1B3E)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        mensaje,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 19, fontWeight: FontWeight.w500, color: Colors.black87, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 65,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      if (esCritico || esElevado) {
                        if (esRepeticion) {
                          // ✅ NUEVO — Trigger 3: segunda medición sigue alta → WhatsApp al cuidador
                          final String nivel = esCritico ? 'critico' : 'elevado';
                          NotificacionCuidadorService().presionCritica(
                            valorPresion: presionString,
                            nivel:        nivel,
                          );

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AlertaCriticaPresionAltaScreen(
                                presionString: presionString,
                              ),
                            ),
                          );
                        } else {
                          final int minutosEspera = 30; // producción: 30 min
                          final nuevaHora = DateTime.now().add(Duration(minutes: minutosEspera));
                          final horaStr =
                              '${nuevaHora.hour.toString().padLeft(2, '0')}:${nuevaHora.minute.toString().padLeft(2, '0')}';

                          await NotificationService().programarRepeticionPresion({
                            'hora_original': DateTime.now().toString(),
                            'tipo':          'medicion_repeticion',
                            'nombre':        'Control de Presión',
                            'detalle':       'Segunda medición',
                          }, minutosEspera);

                          final MedicionService service = MedicionService();
                          await service.crearMedicion(
                            tipoMedicion: 'Presión arterial (Repetición)',
                            horas:        [horaStr],
                            fecha:        DateTime.now(),
                            instrucciones: 'Recordatorio automático de repetición',
                          );

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const HomeScreen()),
                            (route) => false,
                          );
                        }
                      } else {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                          (route) => false,
                        );
                      }
                    } catch (e) {
                      debugPrint('Error al procesar: $e');
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                        (route) => false,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (!esCritico && !esElevado)
                        ? const Color(0xFF1AA23A)
                        : (esCritico ? Colors.red : Colors.orange),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                  ),
                  child: Text(
                    textoBoton,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
