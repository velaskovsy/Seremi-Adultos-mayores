import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:seremi_adultos_mayores/views/add%20measurement/add_measurement_step_1_screen.dart';

import '../add activity/add_activity_step_1_screen.dart';
import '../add appointment/add_appointment_step_1_screen.dart';
import '../add medication/add_medication_step_1_screen.dart';

class AddReminderScreen extends StatelessWidget {
  const AddReminderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [

          // HEADER
          Container(
            width: double.infinity,
            height: 135,
            color: const Color(0xFF000080),
            padding: const EdgeInsets.only(top: 50),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 14),
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
                    'Añadir recordatorio',
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
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 40),
                child: Column(
                  children: [

                    // Medicamento
                    _buildOpcion(
                      context: context,
                      svgPath: 'assets/imagenes/iconos/medicines.svg',
                      colorIcono: const Color(0xFF4CAF50),
                      label: 'Medicamento',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AddMedicationStep1Screen()),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // Medición
                    _buildOpcion(
                      context: context,
                      svgPath: 'assets/imagenes/iconos/heart-cardiogram.svg',
                      colorIcono: const Color(0xFFE53935),
                      label: 'Medición',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AddMeasurementStep1Screen()),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // Actividad
                    _buildOpcion(
                      context: context,
                      svgPath: 'assets/imagenes/iconos/walking.svg',
                      colorIcono: const Color(0xFFAB47BC),
                      label: 'Actividad',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AddActivityStep1Screen()),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // Cita Médica
                    _buildOpcion(
                      context: context,
                      svgPath: 'assets/imagenes/iconos/i-schedule_school_date_time.svg',
                      colorIcono: const Color(0xFF42A5F5),
                      label: 'Cita Médica',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AddAppointmentStep1Screen()),
                        );
                      },
                    ),

                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget de cada opción
  Widget _buildOpcion({
    required BuildContext context,
    required String svgPath,
    required Color colorIcono,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 140,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),

            // Ícono SVG con fondo de color
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: colorIcono,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: SvgPicture.asset(
                svgPath,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),

            const SizedBox(width: 20),

            // Texto
            // 👇 1. ENVOLVEMOS EN EXPANDED 👇
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 32, // Mantenemos tu letra grande y accesible
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                maxLines: 2, // 👈 2. Permite que "Cita Médica" salte a la línea de abajo
                overflow: TextOverflow.ellipsis, // Por si acaso algo es brutalmente largo
              ),
            ),
            const SizedBox(width: 16), // 👈 3. Un pequeño margen para que el texto no raspe la pared derecha
          ],
        ),
      ),
    );
  }
}