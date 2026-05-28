import 'package:flutter/material.dart';

class ResultadoMedicionScreen extends StatelessWidget {
  final String presionString; // Recibe el texto en formato "120/80" o "160/100"

  const ResultadoMedicionScreen({Key? key, required this.presionString}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1. Separamos el String por la barra "/"
    List<String> partes = presionString.split('/');

    // Convertimos a números enteros usando un tryParse por seguridad
    int sistolica = int.tryParse(partes[0].trim()) ?? 0;
    int diastolica = (partes.length > 1) ? (int.tryParse(partes[1].trim()) ?? 0) : 0;

    // Variables que van a cambiar según el rango de presión
    Color backgroundColor;
    Color statusColor;
    IconData iconData;
    String titulo;
    String mensaje;
    String textoBoton;

    // 2. Evaluamos los rangos (Lógica basada en tu mockup)
    // RANGO ROJO: Alerta Crítica (>= 200 sistólica o >= 150 diastólica)
    if (sistolica >= 200 || diastolica >= 150) {
      backgroundColor = const Color(0xFFFFC5C5); // Rosado/Rojo suave
      statusColor = Colors.red;
      iconData = Icons.error_outline;
      titulo = '¡ALERTA\nCRÍTICA!';
      mensaje = 'Siéntese y repose por 30 minutos. Evite tomar café o agitarse. Si no baja avise a su cuidador';
      textoBoton = 'REPETIR MEDICIÓN\nEN 30 MINUTOS';
    }
    // RANGO AMARILLO: Presión Elevada (>= 140 sistólica o >= 90 diastólica)
    else if (sistolica >= 140 || diastolica >= 90) {
      backgroundColor = const Color(0xFFFFF9C4); // Amarillo suave
      statusColor = const Color(0xFFB71C1C); // Usamos rojo oscuro o naranjo para destacar
      iconData = Icons.warning_amber_rounded;
      titulo = 'PRESIÓN\nELEVADA';
      mensaje = 'Siéntese y repose por 30 minutos. Evite tomar café o agitarse. Si no baja avise a su cuidador';
      textoBoton = 'REPETIR MEDICIÓN\nEN 30 MINUTOS';
    }
    // RANGO VERDE: Todo Bien (Menor a 140/90)
    else {
      backgroundColor = const Color(0xFFC8E6C9); // Verde claro
      statusColor = const Color(0xFF1AA23A); // Verde fuerte
      iconData = Icons.check_circle_outline_rounded;
      titulo = 'TODO BIEN';
      mensaje = 'Su presión arterial está en niveles normales. Siga manteniendo sus hábitos saludables';
      textoBoton = 'ENTENDIDO';
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Parte superior: Icono y Estado
              Column(
                children: [
                  const SizedBox(height: 20),
                  Icon(iconData, color: statusColor, size: 90),
                  const SizedBox(height: 10),
                  Text(
                    titulo,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              // Tarjeta Blanca Central
              Card(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Óvalo celeste con la presión ingresada
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD2E3FC),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          '$presionString mmHg',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D1B3E),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Mensaje explicativo
                      Text(
                        mensaje,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Botón de acción inferior (Volver al Home)
              SizedBox(
                width: double.infinity,
                height: 65,
                child: ElevatedButton(
                  onPressed: () {
                    // Limpia las pantallas intermedias y regresa al Home de forma limpia
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (titulo == 'TODO BIEN') ? const Color(0xFF1AA23A) : Colors.orange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 3,
                  ),
                  child: Text(
                    textoBoton,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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