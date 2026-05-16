import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/add_medication_viewmodel.dart';
import '../../../core/widgets/input_field.dart';
import 'add_medication_step_2_screen.dart';

class AddMedicationStep1Screen extends StatelessWidget {
  const AddMedicationStep1Screen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AddMedicationViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [

          // HEADER
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
                  const Expanded(
                    child: Text(
                      'Añadir\nMedicamento',
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

          // CONTENIDO
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // Campo nombre
                  InputField(
                    label: 'NOMBRE DEL MEDICAMENTO',
                    hint: 'Ej: Paracetamol',
                    onChanged: vm.setNombre,
                    errorText: vm.errorNombre,
                    hintFontSize: 30,
                    verticalPadding: 20,
                  ),

                  const SizedBox(height: 24),

                  // Campo dosis
                  InputField(
                    label: 'DOSIS',
                    hint: 'Ej: 100mg o 1 pastilla',
                    onChanged: vm.setDosis,
                    errorText: vm.errorDosis,
                    hintFontSize: 30,
                    verticalPadding: 20,
                  ),

                  const SizedBox(height: 60),

                  // Botón siguiente
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
                                  const AddMedicationStep2Screen(),
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