import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/add_activity_viewmodel.dart';
import 'add_activity_step_3_hydration_screen.dart';

class AddActivityStep2Screen extends StatelessWidget {
  const AddActivityStep2Screen({Key? key}) : super(key: key);

  Future<void> _seleccionarFecha(
      BuildContext context, AddActivityViewModel vm) async {
    final hoy = DateTime.now();
    final seleccionada = await showDatePicker(
      context: context,
      initialDate: hoy,
      firstDate: hoy,
      lastDate: DateTime(hoy.year + 2),
      locale: const Locale('es', 'ES'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF000080),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (seleccionada != null) vm.setFecha(seleccionada);
  }

  Future<void> _seleccionarHora(BuildContext context,
      AddActivityViewModel vm, int index) async {
    final seleccionada = await showTimePicker(
      context: context,
      initialTime: vm.horas[index],
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF000080),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (seleccionada != null) vm.setHoraEnIndice(index, seleccionada);
  }

  // Navega a la pantalla correcta según la actividad
  void _navegarSiguiente(BuildContext context, AddActivityViewModel vm) {
    switch (vm.tipoActividad) {
      case 'Hidratarse':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AddActivityStep3HydrationScreen(),
          ),
        );
        break;
    // TODO: agregar más casos cuando se agreguen actividades
      default:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AddActivityStep3HydrationScreen(),
          ),
        );
    }
  }

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
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 34, vertical: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text(
                      '¿Para cuándo quieres\nempezar el recordatorio?',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 26,
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

                    const Text(
                      '¿A qué hora(s) quieres\nque te lo recuerden?',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Lista de horas
                    ...vm.horas.asMap().entries.map((entry) {
                      final index = entry.key;
                      final hora = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'HORA',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () =>
                                      _seleccionarHora(context, vm, index),
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
                                          vm.horaTexto(hora),
                                          style: const TextStyle(
                                            fontFamily: 'Roboto',
                                            fontSize: 24,
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
                                if (vm.horas.length > 1)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: GestureDetector(
                                      onTap: () => vm.eliminarHora(index),
                                      child: const Icon(
                                        Icons.remove_circle_outline,
                                        color: Colors.red,
                                        size: 34,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),

                    const SizedBox(height: 8),

                    // Botón añadir hora
                    Center(
                      child: GestureDetector(
                        onTap: vm.agregarHora,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF000080),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add_circle_outline,
                                  color: Colors.white, size: 28),
                              SizedBox(width: 10),
                              Text(
                                'AÑADIR HORA',
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 22,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Botón siguiente
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              offset: const Offset(0, 6),
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
                            onPressed: () => _navegarSiguiente(context, vm),
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
          ),
        ],
      ),
    );
  }
}