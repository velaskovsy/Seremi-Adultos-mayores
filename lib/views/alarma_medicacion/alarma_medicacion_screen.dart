import 'package:flutter/material.dart';
import '../../viewmodels/alarma_medicacion_viewmodel.dart';


class AlarmaView extends StatelessWidget {
  final AlarmaViewModel viewModel;

  const AlarmaView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    // Colores exactos basados en tu diseño (Corregidos con 0xFF)
    const colorFondo = Color(0xFFFBC4C4);
    const colorRojoAlerta = Color(0xFFD32F2F);
    const colorBotonVerde = Color(0xFF1B5E20);
    const colorTagHora = Color(0xFFD1E2FF);
    const colorTagDosis = Color(0xFFD1E2FF);

    return Scaffold(
      backgroundColor: colorFondo,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              const Spacer(),

              // Ícono de Alerta Circular
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colorRojoAlerta, width: 4),
                ),
                child: const Icon(
                    Icons.priority_high,
                    size: 50,
                    color: colorRojoAlerta
                ),
              ),
              const SizedBox(height: 12),

              // Texto ¡ALARMA!
              const Text(
                '¡ALARMA!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: colorRojoAlerta,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),

              // Tag de la Hora (ej. 12:00)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 6),
                decoration: BoxDecoration(
                  color: colorTagHora,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: Text(
                  viewModel.hora,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Tarjeta Blanca de Información
              Card(
                color: const Color(0xFFF5F5F5), // Corregido #F5F5F5
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Nombre del Medicamento
                      Text(
                        viewModel.medicamento.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Tag de Gramaje / Dosis
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: colorTagDosis,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          viewModel.dosis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0D47A1), // Corregido #0D47A1
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Subtítulo Instrucción
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Instrucción',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D47A1), // Corregido #0D47A1
                          ),
                        ),
                      ),
                      const Divider(color: Colors.grey, thickness: 1),
                      const SizedBox(height: 8),

                      // Bloque de descripción con línea azul lateral (Quote layout)
                      IntrinsicHeight(
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2196F3), // Corregido #2196F3
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '"${viewModel.instruccion}"',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Botón "SÍ, YA LO TOMÉ"
              ListenableBuilder(
                  listenable: viewModel,
                  builder: (context, child) {
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorBotonVerde,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      onPressed: viewModel.isProcessing
                          ? null
                          : () async {
                        bool OK = await viewModel.registrarToma();
                        if (OK && context.mounted) {
                          Navigator.pop(context); // Cierra la alerta al terminar
                        }
                      },
                      child: viewModel.isProcessing
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        'SÍ, YA LO TOMÉ',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                    );
                  }
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}