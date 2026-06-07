import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/add_activity_viewmodel.dart';
import '../home/home_screen.dart';
import '../../services/notificacion_service.dart';

class AddActivityStep3HydrationScreen extends StatelessWidget {
  const AddActivityStep3HydrationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AddActivityViewModel>(context);

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
                        child: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF000080),
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      vm.tipoActividad, // ← dinámico
                      textAlign: TextAlign.center,
                      style: const TextStyle(
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
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 34, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    '¿Cuánta cantidad de agua\ndebe tomar?',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Una fila por cada hora elegida en el paso 2
                  Expanded(
                    child: ListView.builder(
                      itemCount: vm.horas.length,
                      itemBuilder: (context, index) {
                        final hora = vm.horas[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [

                              // Hora
                              Text(
                                vm.horaTexto(hora),
                                style: const TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),

                              // Dropdown de vasos
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE3F2FD),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: const Color(0xFF000080), width: 2),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: vm.cantidadEnIndice(index),
                                    isDense: true,
                                    icon: const Icon(Icons.keyboard_arrow_down,
                                        color: Color(0xFF000080), size: 28),
                                    style: const TextStyle(
                                      fontFamily: 'Roboto',
                                      fontSize: 22,
                                      color: Color(0xFF000080),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    dropdownColor: const Color(0xFFE3F2FD),
                                    items: vm.opcionesVasos.map((opcion) {
                                      return DropdownMenuItem<String>(
                                        value: opcion,
                                        child: Text(opcion),
                                      );
                                    }).toList(),
                                    onChanged: (valor) {
                                      if (valor != null) {
                                        vm.setCantidadEnIndice(index, valor);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Botón guardar
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
                              side: const BorderSide(
                                  color: Color(0xFFFF8800), width: 2),
                            ),
                          ),
                          onPressed: () async {
                            final now = DateTime.now();
                            bool hayHoraPasada = false;

                            // 👇 1. VALIDACIÓN LIMPIA 👇
                            for (int i = 0; i < vm.horas.length; i++) {
                              final horaObj = vm.horas[i];

                              DateTime fechaHoraVerificar = DateTime(
                                  now.year,
                                  now.month,
                                  now.day,
                                  horaObj.hour,
                                  horaObj.minute
                              );

                              if (fechaHoraVerificar.isBefore(now)) {
                                hayHoraPasada = true;
                                break;
                              }
                            }

                            // 👇 2. BLOQUEO 👇
                            if (hayHoraPasada) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'No puedes programar un evento para una hora que ya pasó.',
                                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                  ),
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 4),
                                ),
                              );
                              return;
                            }

                            // 👇 3. GUARDAMOS EN LA BASE DE DATOS 👇
                            // ¡Listo! Al guardar aquí, tu "Radar" interno lo detectará y enviará la notificación de WhatsApp solo.
                            await vm.guardar();

                            // 👇 4. VOLVEMOS AL MENÚ PRINCIPAL 👇
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const HomeScreen()),
                                  (route) => false,
                            );
                          },
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

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}