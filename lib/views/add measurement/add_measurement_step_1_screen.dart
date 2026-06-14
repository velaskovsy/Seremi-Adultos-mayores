import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/add_measurement_viewmodel.dart';
import 'add_measurement_step_2_screen.dart';
import 'add_measurement_step_3_screen.dart';

class AddMeasurementStep1Screen extends StatefulWidget {
  const AddMeasurementStep1Screen({Key? key}) : super(key: key);

  @override
  State<AddMeasurementStep1Screen> createState() =>
      _AddMeasurementStep1ScreenState();
}

class _AddMeasurementStep1ScreenState
    extends State<AddMeasurementStep1Screen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filtrados = [];

  @override
  void initState() {
    super.initState();
    final vm =
    Provider.of<AddMeasurementViewModel>(context, listen: false);
    _filtrados = List.from(vm.tiposMedicion);
  }

  void _filtrar(String query, List<String> todos) {
    setState(() {
      if (query.isEmpty) {
        _filtrados = List.from(todos);
      } else {
        _filtrados = todos
            .where((t) => t.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AddMeasurementViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [

          // ── HEADER ────────────────────────────────────────────────────────
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
                      'Añadir\nMedición',
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

          // ── CONTENIDO ─────────────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Buscador
                  Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.black45, width: 2),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.black,
                      ),
                      onChanged: (q) => _filtrar(q, vm.tiposMedicion),
                      decoration: const InputDecoration(
                        hintText: 'Buscar',
                        hintStyle: TextStyle(
                          fontSize: 30,
                          color: Colors.black54,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.black54,
                          size: 28,
                        ),
                        border: InputBorder.none,
                        contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    '¿Qué medición desea agregar?',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 26,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Lista de opciones filtradas
                  Expanded(
                    child: ListView.separated(
                      itemCount: _filtrados.length,
                      separatorBuilder: (_, __) => const Divider(
                        color: Colors.black26,
                        thickness: 1,
                        height: 1,
                      ),
                      itemBuilder: (context, index) {
                        final tipo = _filtrados[index];
                        final seleccionado = vm.tipoMedicion == tipo;
                        return GestureDetector(
                          onTap: () {
                            vm.setTipoMedicion(tipo);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 18),
                            color: seleccionado
                                ? const Color(0xFFD0DFFF)
                                : Colors.transparent,
                            child: Row(
                              children: [
                                if (seleccionado)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF000080),
                                    size: 28,
                                  )
                                else
                                  const SizedBox(width: 28),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    tipo,
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontSize: 28,
                                      fontWeight: seleccionado
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: seleccionado
                                          ? const Color(0xFF000080)
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Error
                  if (vm.errorTipoMedicion != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        vm.errorTipoMedicion!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 22,
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

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
                                  const AddMeasurementStep2Screen(),
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

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}