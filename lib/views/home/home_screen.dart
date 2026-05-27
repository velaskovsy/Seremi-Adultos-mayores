// lib/views/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/app_footer.dart';
import '../../services/auth_service.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../viewmodels/alarma_medicacion_viewmodel.dart'; // Importación del ViewModel de alarmas

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

    // Activamos el motor de alarmas apenas la pantalla se termina de renderizar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AlarmViewModel>(context, listen: false).iniciarMonitoreoDeAlarmas(context);
    });
  }

  @override
  void dispose() {
    try {
      Provider.of<AlarmViewModel>(context, listen: false).detenerMonitoreo();
    } catch (e) {
      debugPrint("No se pudo detener el monitoreo: $e");
    }
    super.dispose();
  }

  // Generador de fecha dinámica en español
  String _obtenerFecha() {
    final ahora = DateTime.now();
    const dias = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    const meses = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];

    return '${dias[ahora.weekday - 1]}, ${ahora.day} de ${meses[ahora.month - 1]}';
  }

  Future<void> _handleLogout(BuildContext context) async {
    final authService = AuthService();

    // Apagamos el timer antes de salir
    Provider.of<AlarmViewModel>(context, listen: false).detenerMonitoreo();
    await authService.logout();

    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
            (route) => false,
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
          // HEADER AZUL
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
                  icon: const Icon(Icons.exit_to_app, color: Colors.white, size: 32),
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

                  // FECHA ACTUAL
                  Center(
                    child: Text(
                      _obtenerFecha(),
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // INDICADOR DE PRÓXIMA TAREA
                  Center(
                    child: Container(
                      width: 344,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD0EFFF),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.blueAccent, width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          'Su próxima tarea es a las\n${vm.data?['proxima_tarea'] ?? '--:--'}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 20, color: Colors.black87),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 🔥 BOTÓN AÑADIR RECORDATORIO (CORREGIDO SIN EL CONST ERRÓNEO)
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AddReminderScreen(), // Queda limpio aquí
                              ),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                child: const Icon(Icons.add, color: Color(0xFF4CAF50), size: 28),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'AÑADIR RECORDATORIO',
                                style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // SECCIONES DE HORARIOS
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 17),
                    child: Row(
                      children: const [
                        Icon(Icons.access_time, color: Color(0xFF000080), size: 38),
                        SizedBox(width: 10),
                        Text('HORARIO DEL DÍA', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 17),
                    child: Divider(color: Colors.black, thickness: 1),
                  ),
                  const SizedBox(height: 12),

                  // FRANJA MAÑANA
                  _buildFranja(
                    color: const Color(0xFFFFE0B2),
                    icono: Icons.wb_twilight,
                    iconoColor: Colors.orange,
                    titulo: 'MAÑANA',
                    tituloColor: Colors.orange,
                    vacio: manana.isEmpty,
                    imagenVacio: 'assets/imagenes/manana.jpg', // Path corregido sin "ñ"
                    mensajeVacio: 'No hay eventos\nprogramados',
                    tarjetas: manana.map<Widget>((item) => _buildRecordatorio(item)).toList(),
                  ),
                  const SizedBox(height: 12),

                  // FRANJA TARDE
                  _buildFranja(
                    color: const Color(0xFFE3F2FD),
                    icono: Icons.wb_sunny,
                    iconoColor: Colors.blue,
                    titulo: 'TARDE',
                    tituloColor: Colors.blue,
                    vacio: tarde.isEmpty,
                    imagenVacio: 'assets/imagenes/dia.jpg',
                    mensajeVacio: 'No hay eventos\nprogramados',
                    tarjetas: tarde.map<Widget>((item) => _buildRecordatorio(item)).toList(),
                  ),
                  const SizedBox(height: 12),

                  // FRANJA NOCHE
                  _buildFranja(
                    color: const Color(0xFFE8EAF6),
                    icono: Icons.nightlight_round,
                    iconoColor: Colors.indigo,
                    titulo: 'NOCHE',
                    tituloColor: Colors.indigo,
                    vacio: noche.isEmpty,
                    imagenVacio: 'assets/imagenes/noche.jpg',
                    mensajeVacio: 'No hay eventos\nprogramados',
                    tarjetas: noche.map<Widget>((item) => _buildRecordatorio(item)).toList(),
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
          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 16),
          child: Row(
            children: [
              Icon(icono, color: iconoColor, size: 36),
              const SizedBox(width: 10),
              Text(titulo, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: tituloColor)),
            ],
          ),
        ),
        if (vacio)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Image.asset(imagenVacio, width: 120, height: 120, fit: BoxFit.contain),
                const SizedBox(height: 8),
                Text(mensajeVacio, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, color: Colors.black54)),
              ],
            ),
          )
        else
          Column(children: tarjetas),
      ],
    );
  }

  Widget _buildRecordatorio(Map<String, dynamic> item) {
    Color colorBorde;
    Color colorRelleno;
    switch (item['color']) {
      case 'verde':
        colorBorde = const Color(0xFF18A528);
        colorRelleno = const Color(0xFFDEFFE1);
        break;
      case 'morado':
        colorBorde = const Color(0xFFB200FF);
        colorRelleno = const Color(0xFFEACFFF);
        break;
      case 'rojo':
        colorBorde = const Color(0xFFFF0505);
        colorRelleno = const Color(0xFFFFDFDF);
        break;
      case 'azul':
        colorBorde = const Color(0xFF59BDFF);
        colorRelleno = const Color(0xFFCDE3FF);
        break;
      default:
        colorBorde = Colors.grey;
        colorRelleno = const Color(0xFFE0E0E0);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          // Hora a la izquierda
          SizedBox(
            width: 100,
            child: Text(
              item['hora'] ?? '',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Tarjeta
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 90),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: colorRelleno,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorBorde, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    offset: const Offset(0, 4),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['nombre'] ?? '',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        if ((item['tipo'] == 'medicamento' || item['tipo'] == 'actividad') &&
                            (item['detalle'] ?? '').isNotEmpty)
                          Text(
                            (item['detalle'] as String).split(' — ').first,
                            style: const TextStyle(
                              fontSize: 24,
                              color: Color(0xFF000080),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Icon(
                      Icons.volume_up,
                      color: Colors.black,
                      size: 46,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}