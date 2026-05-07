import 'package:flutter/material.dart';
import '../../core/widgets/app_footer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [

          // HEADER
          Container(
            width: double.infinity,
            height: 145,
            color: const Color(0xFF000080),
            alignment: Alignment.center,
            child: const Text(
              'Nombre\nde la app',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // CONTENIDO
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const SizedBox(height: 80),

                  // BOTÓN AÑADIR RECORDATORIO
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
                        width: 378,
                        height: 92,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () {
                            // TODO: navegar a pantalla de añadir recordatorio
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Ícono +
                              Container(
                                width: 38,
                                height: 38,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Color(0xFF4CAF50),
                                  size: 28,
                                ),
                              ),

                              const SizedBox(width: 12),

                              // Texto
                              const Text(
                                'AÑADIR RECORDATORIO',
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 24,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),

                  // HORARIO DEL DÍA
                  Row(
                    children: [
                      // Ícono reloj
                      SizedBox(
                        width: 38,
                        height: 38,
                        child: Icon(
                          Icons.access_time,
                          color: const Color(0xFF000080),
                          size: 38,
                        ),
                      ),

                      const SizedBox(width: 10),

                      // Texto
                      const Text(
                        'HORARIO DEL DÍA',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Línea divisoria
                  const Divider(
                    color: Colors.black,
                    thickness: 1,
                  ),

                ],
              ),
            ),
          ),

          // FOOTER
          const AppFooter(),
        ],
      ),
    );
  }
}
