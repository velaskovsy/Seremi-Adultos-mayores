import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/add_appointment_viewmodel.dart';
import '../../../core/widgets/input_field.dart';
import 'add_appointment_step_2_screen.dart';

class AddAppointmentStep1Screen extends StatelessWidget {
  const AddAppointmentStep1Screen({Key? key}) : super(key: key);

  Future<void> _seleccionarFecha(
      BuildContext context, AddAppointmentViewModel vm) async {
    final hoy = DateTime.now();
    final seleccionada = await showDatePicker(
      context: context,
      initialDate: hoy,
      firstDate: hoy,
      lastDate: DateTime(hoy.year + 2),
      locale: const Locale('es', 'ES'),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF000080),
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      ),
    );
    if (seleccionada != null) vm.setFecha(seleccionada);
  }

  Future<void> _seleccionarHora(
      BuildContext context, AddAppointmentViewModel vm) async {
    final seleccionada = await showTimePicker(
      context: context,
      initialTime: vm.hora,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF000080),
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      ),
    );
    if (seleccionada != null) vm.setHora(seleccionada);
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AddAppointmentViewModel>(context);

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
                        child: const Icon(Icons.arrow_back,
                            color: Color(0xFF000080), size: 28),
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Añadir\nCita',
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
                    '¿Para cuándo quieres el\nrecordatorio?',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // FECHA
                  Row(
                    children: [
                      // 👇 1. "FECHA" cede espacio si el teléfono es muy chico
                      const Expanded(
                        child: Text(
                          'FECHA',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10), // Separación segura
                      GestureDetector(
                        onTap: () => _seleccionarFecha(context, vm),
                        child: Container(
                          // Bajamos un milímetro el padding horizontal (de 20 a 16)
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF000080),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          // 👇 2. Obligamos al Row interno a no estirarse al infinito
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 👇 3. Flexible por si la fecha es brutalmente larga
                              Flexible(
                                child: Text(
                                  vm.fechaTexto,
                                  style: const TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 24,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_drop_down, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // HORA
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'HORA',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _seleccionarHora(context, vm),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF000080),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Text(
                                vm.horaTexto,
                                style: const TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 22,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_drop_down,
                                  color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // LUGAR
                  InputField(
                    label: 'LUGAR',
                    hint: 'Ej:',
                    onChanged: vm.setLugar,
                    errorText: vm.errorLugar,
                    hintFontSize: 24,
                    verticalPadding: 28,
                  ),

                  const Spacer(),

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
                              side: const BorderSide(
                                  color: Color(0xFFFF8800), width: 2),
                            ),
                          ),
                          onPressed: () {
                            if (vm.validarPaso1()) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                  const AddAppointmentStep2Screen(),
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