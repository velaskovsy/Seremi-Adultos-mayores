// lib/views/editar o eliminar recordatorio/editar_medicamento_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/widgets/photo_box.dart';
import '../../viewmodels/add_medication_viewmodel.dart';
import '../../services/medicamento_service.dart'; // 👈 Importamos el servicio
import '../home/home_screen.dart';

class EditarMedicamentoScreen extends StatefulWidget {
  final String grupoId;
  final String nombre;
  final String dosis;
  final String hora;
  final String? intervalo;
  final String? instrucciones;

  const EditarMedicamentoScreen({
    Key? key,
    required this.grupoId,
    required this.nombre,
    required this.dosis,
    required this.hora,
    this.intervalo,
    this.instrucciones,
  }) : super(key: key);

  @override
  State<EditarMedicamentoScreen> createState() =>
      _EditarMedicamentoScreenState();
}

class _EditarMedicamentoScreenState extends State<EditarMedicamentoScreen> {
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _dosisCtrl;
  late final TextEditingController _instruccionesCtrl;
  final MedicamentoService _medicamentoService = MedicamentoService(); // 👈 Instancia del servicio

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.nombre);
    _dosisCtrl = TextEditingController(text: widget.dosis);
    _instruccionesCtrl = TextEditingController(text: widget.instrucciones ?? '');

    // Precarga el viewmodel compartido con los datos actuales del grupo
    final vm = context.read<AddMedicationViewModel>();
    vm.cargarParaEditar(
      grupoId: widget.grupoId,
      nombre: widget.nombre,
      dosis: widget.dosis,
      hora: widget.hora,
      intervalo: widget.intervalo,
      instrucciones: widget.instrucciones,
    );
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _dosisCtrl.dispose();
    _instruccionesCtrl.dispose();
    super.dispose();
  }

  // 👈 Función para mostrar el diálogo de advertencia y eliminar si se confirma
  Future<void> _advertirEdicionIntervalo(BuildContext context) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'No es posible editar intervalo',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Si desea hacerlo, favor eliminar recordatorio y volver a crear. ¿Desea eliminar recordatorio?',
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(fontSize: 18, color: Color(0xFF000080), fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(fontSize: 18, color: Color(0xFFD32F2F), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmado == true && mounted) {
      // Reutiliza la lógica de eliminación enviando el grupoId actual
      final exito = await _medicamentoService.eliminarGrupoMedicamento(widget.grupoId);
      if (!mounted) return;

      if (exito) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo eliminar el recordatorio. Intenta de nuevo.')),
        );
      }
    }
  }

  Future<void> _seleccionarFecha(
      BuildContext context, AddMedicationViewModel vm) async {
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
    if (seleccionada != null) {
      vm.setFecha(seleccionada);
    }
  }

  Future<void> _seleccionarHora(
      BuildContext context, AddMedicationViewModel vm) async {
    final seleccionada = await showTimePicker(
      context: context,
      initialTime: vm.hora,
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
    if (seleccionada != null) {
      vm.setHora(seleccionada);
    }
  }

  void _mostrarOpcionesFoto(
      BuildContext context, AddMedicationViewModel vm, bool esCaja) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Seleccionar foto',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt,
                  color: Color(0xFF000080), size: 32),
              title: const Text('Tomar foto', style: TextStyle(fontSize: 20)),
              onTap: () async {
                Navigator.pop(context);
                final foto = await vm.tomarFoto(ImageSource.camera);
                if (foto != null) {
                  if (esCaja) {
                    vm.setFotoCaja(foto);
                  } else {
                    vm.setFotoRemedio(foto);
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library,
                  color: Color(0xFF000080), size: 32),
              title: const Text('Elegir de galería',
                  style: TextStyle(fontSize: 20)),
              onTap: () async {
                Navigator.pop(context);
                final foto = await vm.tomarFoto(ImageSource.gallery);
                if (foto != null) {
                  if (esCaja) {
                    vm.setFotoCaja(foto);
                  } else {
                    vm.setFotoRemedio(foto);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AddMedicationViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── HEADER ──
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
                      'Editar\nMedicamento',
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

          // ── CONTENIDO ──
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // NOMBRE
                    const Text(
                      'NOMBRE DEL MEDICAMENTO',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Container(
                        width: 344,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.black, width: 4),
                        ),
                        child: TextField(
                          controller: _nombreCtrl,
                          minLines: 1,
                          maxLines: null,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.multiline,
                          style: const TextStyle(
                            fontSize: 32,
                            color: Color(0xFF000080),
                            fontWeight: FontWeight.bold,
                          ),
                          onChanged: vm.setNombre,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                          ),
                        ),
                      ),
                    ),
                    if (vm.errorNombre != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 34, top: 6),
                        child: Text(
                          vm.errorNombre!,
                          style: const TextStyle(color: Colors.red, fontSize: 24),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // DOSIS
                    const Text(
                      'DOSIS',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Container(
                        width: 344,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.black, width: 4),
                        ),
                        child: TextField(
                          controller: _dosisCtrl,
                          minLines: 1,
                          maxLines: null,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.multiline,
                          style: const TextStyle(
                            fontSize: 32,
                            color: Color(0xFF000080),
                            fontWeight: FontWeight.bold,
                          ),
                          onChanged: vm.setDosis,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                          ),
                        ),
                      ),
                    ),
                    if (vm.errorDosis != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 34, top: 6),
                        child: Text(
                          vm.errorDosis!,
                          style: const TextStyle(color: Colors.red, fontSize: 24),
                        ),
                      ),

                    const SizedBox(height: 40),

                    // FECHA
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'FECHA',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _seleccionarFecha(context, vm),
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
                                  vm.fechaTexto,
                                  style: const TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 24,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
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
                            fontSize: 32,
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
                                    fontSize: 24,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_drop_down, color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // INTERVALO (Bloqueado para edición directa)
                    const Text(
                      'INTERVALO',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => _advertirEdicionIntervalo(context), // 👈 Dispara la alerta
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF000080), width: 3),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              vm.intervalo ?? '',
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 30,
                                color: Color(0xFF000080),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down,
                              color: Color(0xFF000080),
                              size: 32,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // INSTRUCCIONES
                    const Text(
                      'INSTRUCCIONES',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.black, width: 4),
                      ),
                      child: TextField(
                        controller: _instruccionesCtrl,
                        onChanged: vm.setInstrucciones,
                        textAlign: TextAlign.center,
                        minLines: 3,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        style: const TextStyle(
                          fontSize: 26,
                          color: Color(0xFF000080),
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              'Ej: no masticar la pastilla y tomar\ncon abundante líquido',
                          hintStyle: TextStyle(
                            fontSize: 26,
                            color: const Color(0xFF000080).withValues(alpha: 0.5),
                            fontWeight: FontWeight.bold,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // FOTOS
                    const Text(
                      'FOTOS',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FotoCuadroWidget(
                          foto: vm.fotoCaja,
                          label: 'CAJA',
                          onTap: () => _mostrarOpcionesFoto(context, vm, true),
                        ),
                        const SizedBox(width: 20),
                        FotoCuadroWidget(
                          foto: vm.fotoRemedio,
                          label: 'REMEDIO',
                          onTap: () => _mostrarOpcionesFoto(context, vm, false),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    if (vm.errorGuardar != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Center(
                          child: Text(
                            vm.errorGuardar!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 16,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                    // BOTÓN GUARDAR CAMBIOS
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
                              backgroundColor:
                                  vm.guardando ? Colors.grey : const Color(0xFFFF8800),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side: const BorderSide(
                                    color: Color(0xFFFF8800), width: 2),
                              ),
                            ),
                            onPressed: vm.guardando
                                ? null
                                : () async {
                                    if (!vm.validarPaso1()) return;
                                    final exito = await vm.guardar();
                                    if (exito && context.mounted) {
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => const HomeScreen()),
                                        (route) => false,
                                      );
                                    }
                                  },
                            child: vm.guardando
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    'Guardar cambios',
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