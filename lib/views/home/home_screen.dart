import 'package:flutter/material.dart';

import '../../core/widgets/app_footer.dart';
import '../../services/auth_service.dart';
import '../../viewmodels/home_viewmodel.dart';

import '../login/login_screen.dart';
import '../reminder/add_reminder_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  late HomeViewModel vm;

  @override
  void initState() {
    super.initState();

    vm = HomeViewModel();

    vm.addListener(() {
      setState(() {});
    });

    vm.cargar();
  }

  // Fecha dinámica
  String _obtenerFecha() {
    final ahora = DateTime.now();

    const dias = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo'
    ];

    const meses = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];

    final dia = dias[ahora.weekday - 1];
    final mes = meses[ahora.month - 1];

    return '$dia, ${ahora.day} de $mes';
  }

  Future<void> _handleLogout(BuildContext context) async {

    final authService = AuthService();

    await authService.logout();

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    final manana = vm.data?['franjas']?['manana'] ?? [];
    final tarde  = vm.data?['franjas']?['tarde'] ?? [];
    final noche  = vm.data?['franjas']?['noche'] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,

      body: Column(
        children: [

          // HEADER
          Stack(
            children: [

              Container(
                width: double.infinity,
                height: 135,
                color: const Color(0xFF000080),

                alignment: Alignment.center,

                child: const Text(
                  'Salud\nMayor',
                  textAlign: TextAlign.center,

                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Positioned(
                top: 40,
                left: 10,

                child: IconButton(
                  icon: const Icon(
                    Icons.exit_to_app,
                    color: Colors.white,
                    size: 32,
                  ),

                  tooltip: 'Cerrar sesión',

                  onPressed: () => _handleLogout(context),
                ),
              ),
            ],
          ),

          Expanded(
            child: SingleChildScrollView(

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  const SizedBox(height: 20),

                  // FECHA
                  Center(
                    child: Text(
                      _obtenerFecha(),

                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // PROXIMA TAREA
                  Center(
                    child: Container(

                      width: 344,

                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),

                      decoration: BoxDecoration(
                        color: const Color(0xFFD0EFFF),

                        borderRadius: BorderRadius.circular(15),

                        border: Border.all(
                          color: Colors.blueAccent,
                          width: 1.5,
                        ),
                      ),

                      child: Center(
                        child: Text(
                          'Su próxima tarea es a las\n${vm.data?['proxima_tarea'] ?? '--:--'}',

                          textAlign: TextAlign.center,

                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 20,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // BOTON
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AddReminderScreen(),
                              ),
                            );
                          },

                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,

                            children: [

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

                  const SizedBox(height: 24),

                  // HORARIO DEL DIA
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 17),

                    child: Row(
                      children: const [

                        Icon(
                          Icons.access_time,
                          color: Color(0xFF000080),
                          size: 38,
                        ),

                        SizedBox(width: 10),

                        Text(
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
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 17),
                    child: Divider(
                      color: Colors.black,
                      thickness: 1,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // MAÑANA
                  _buildFranja(
                    color: const Color(0xFFFFE0B2),
                    icono: Icons.wb_twilight,
                    iconoColor: Colors.orange,
                    titulo: 'MAÑANA',
                    tituloColor: Colors.orange,

                    vacio: manana.isEmpty,

                    imagenVacio: 'assets/imagenes/mañana.jpg',

                    mensajeVacio: 'No hay eventos\nprogramados',

                    tarjetas: manana.map<Widget>((item) {
                      return _buildRecordatorio(item);
                    }).toList(),
                  ),

                  const SizedBox(height: 12),

                  // TARDE
                  _buildFranja(
                    color: const Color(0xFFE3F2FD),
                    icono: Icons.wb_sunny,
                    iconoColor: Colors.blue,
                    titulo: 'TARDE',
                    tituloColor: Colors.blue,

                    vacio: tarde.isEmpty,

                    imagenVacio: 'assets/imagenes/dia.jpg',

                    mensajeVacio: 'No hay eventos\nprogramados',

                    tarjetas: tarde.map<Widget>((item) {
                      return _buildRecordatorio(item);
                    }).toList(),
                  ),

                  const SizedBox(height: 12),

                  // NOCHE
                  _buildFranja(
                    color: const Color(0xFFE8EAF6),
                    icono: Icons.nightlight_round,
                    iconoColor: Colors.indigo,
                    titulo: 'NOCHE',
                    tituloColor: Colors.indigo,

                    vacio: noche.isEmpty,

                    imagenVacio: 'assets/imagenes/noche.jpg',

                    mensajeVacio: 'No hay eventos\nprogramados',

                    tarjetas: noche.map<Widget>((item) {
                      return _buildRecordatorio(item);
                    }).toList(),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          const AppFooter(),
        ],
      ),
    );
  }

  Widget _buildFranja({
    required Color color,
    required IconData icono,
    required Color iconoColor,
    required String titulo,
    required Color tituloColor,
    required bool vacio,
    required String imagenVacio,
    required String mensajeVacio,
    List<Widget> tarjetas = const [],
  }) {

    return Column(
      children: [

        Container(
          width: double.infinity,
          color: color,

          padding: const EdgeInsets.symmetric(
            horizontal: 17,
            vertical: 16,
          ),

          child: Row(
            children: [

              Icon(
                icono,
                color: iconoColor,
                size: 36,
              ),

              const SizedBox(width: 10),

              Text(
                titulo,

                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: tituloColor,
                ),
              ),
            ],
          ),
        ),

        if (vacio)

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),

            child: Column(
              children: [

                Image.asset(
                  imagenVacio,
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 8),

                Text(
                  mensajeVacio,

                  textAlign: TextAlign.center,

                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 24,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          )

        else

          Column(children: tarjetas),
      ],
    );
  }

  Widget _buildRecordatorio(Map<String, dynamic> item) {

    Color color;

    switch (item['color']) {

      case 'verde':
        color = Colors.green;
        break;

      case 'rojo':
        color = Colors.red;
        break;

      case 'rojo':
        color = Colors.red;
        break;

      case 'rojo':
        color = Colors.red;
        break;

      default:
        color = Colors.white;
    }

    return Container(

      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: color.withOpacity(0.15),

        borderRadius: BorderRadius.circular(14),

        border: Border.all(
          color: color,
          width: 2,
        ),
      ),

      child: Row(
        children: [

          // COLOR
          Container(
            width: 12,
            height: 60,

            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          const SizedBox(width: 12),

          // TEXTO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(
                  item['nombre'] ?? '',

                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  item['detalle'] ?? '',

                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // HORA
          Text(
            item['hora'] ?? '',

            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}