// lib/views/calendario/calendario_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../core/widgets/app_footer.dart';
import '../../viewmodels/calendario_viewmodel.dart';

// 👇 IMPORTAMOS LAS PANTALLAS DE DETALLE 👇
import '../editar o eliminar recordatorio/detalle_medicamento_screen.dart';
import '../editar o eliminar recordatorio/detalle_medicion_screen.dart';
import '../editar o eliminar recordatorio/detalle_actividad_screen.dart';
import '../editar o eliminar recordatorio/detalle_cita_medica_screen.dart';

class CalendarioScreen extends StatelessWidget {
  const CalendarioScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CalendarioViewModel(),
      child: const _CalendarioContenido(),
    );
  }
}

class _CalendarioContenido extends StatefulWidget {
  const _CalendarioContenido({Key? key}) : super(key: key);

  @override
  State<_CalendarioContenido> createState() => _CalendarioContenidoState();
}

class _CalendarioContenidoState extends State<_CalendarioContenido> {
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("es-ES");
    await flutterTts.setSpeechRate(0.45);
    await flutterTts.setPitch(1.0);
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  Future<void> _reproducirTTS(Map<String, dynamic> item) async {
    // 👇 AJUSTE AQUÍ TAMBIÉN PARA QUE LA VOZ DIGA "CITA MÉDICA" 👇
    String nombre = item['nombre'] ?? '';
    if (item['tipo'] == 'cita' || item['tipo'] == 'cita_medica') {
      nombre = 'Cita Médica';
    }

    String detalle = '';

    if ((item['tipo'] == 'medicamento' || item['tipo'] == 'actividad') &&
        ((item['dosis'] ?? item['detalle']) ?? '').isNotEmpty) {
      detalle = ((item['dosis'] ?? item['detalle']) as String).split(' — ').first;
    }

    String horaStr = item['hora'] ?? '';
    String horaHablada = _formatearHoraParaTTS(horaStr);

    String textoALeer = "$nombre. ";
    if (detalle.isNotEmpty) {
      textoALeer += "$detalle. ";
    }
    if (horaHablada.isNotEmpty) {
      textoALeer += horaHablada;
    }

    await flutterTts.speak(textoALeer);
  }

  String _formatearHoraParaTTS(String horaStr) {
    if (horaStr.isEmpty || !horaStr.contains(':')) return "";

    List<String> partes = horaStr.split(':');
    int hora = int.tryParse(partes[0]) ?? 0;
    int minuto = int.tryParse(partes[1]) ?? 0;

    String periodo = "de la mañana";
    if (hora >= 12 && hora < 20) {
      periodo = "de la tarde";
    } else if (hora >= 20 || hora < 6) {
      periodo = "de la noche";
    }

    int hora12 = hora % 12;
    if (hora12 == 0) hora12 = 12;

    String articulo = hora12 == 1 ? "a la" : "a las";
    String horaTexto = hora12.toString();
    String minutoTexto = minuto == 0 ? "en punto" : "y $minuto";

    return "$articulo $horaTexto $minutoTexto $periodo";
  }

  Color _parsearColor(String colorStr) {
    switch (colorStr) {
      case 'verde':  return const Color(0xFFDEFFE1);
      case 'morado': return const Color(0xFFEACFFF);
      case 'rojo':   return const Color(0xFFFFDFDF);
      case 'azul':   return const Color(0xFFCDE3FF);
      default:       return const Color(0xFFE0E0E0);
    }
  }

  Color _parsearBorde(String colorStr) {
    switch (colorStr) {
      case 'verde':  return const Color(0xFF18A528);
      case 'morado': return const Color(0xFFB200FF);
      case 'rojo':   return const Color(0xFFFF0505);
      case 'azul':   return const Color(0xFF59BDFF);
      default:       return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<CalendarioViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
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
          Expanded(
            child: Column(
              children: [
                vm.cargandoCalendario
                    ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: LinearProgressIndicator(color: Color(0xFF000080)),
                )
                    : TableCalendar(
                  locale: 'es_ES',
                  firstDay: DateTime(2024),
                  lastDay: DateTime(2027),
                  focusedDay: vm.diaFocuseado,
                  selectedDayPredicate: (dia) => isSameDay(vm.diaSeleccionado, dia),
                  eventLoader: (dia) => vm.tieneEventos(dia) ? [true] : [],
                  onPageChanged: (nuevaFecha) {
                    vm.cambiarMes(nuevaFecha);
                  },
                  onDaySelected: (seleccionado, focuseado) {
                    vm.seleccionarDia(seleccionado, focuseado);
                  },
                  calendarStyle: CalendarStyle(
                    selectedDecoration: const BoxDecoration(
                      color: Color(0xFF000080),
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                    todayDecoration: BoxDecoration(
                      color: const Color(0xFF000080).withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: const TextStyle(
                      color: Color(0xFF000080),
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                    defaultTextStyle: const TextStyle(fontSize: 32),
                    weekendTextStyle: const TextStyle(
                      fontSize: 32,
                      color: Colors.black54,
                    ),
                    outsideTextStyle: const TextStyle(
                      fontSize: 26,
                      color: Colors.grey,
                    ),
                    markerDecoration: const BoxDecoration(
                      color: Color(0xFFFF8800),
                      shape: BoxShape.circle,
                    ),
                    markerSize: 10,
                    markersMaxCount: 3,
                    cellMargin: const EdgeInsets.all(3),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF000080),
                    ),
                    leftChevronIcon: Icon(
                      Icons.chevron_left,
                      color: Color(0xFF000080),
                      size: 32,
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right,
                      color: Color(0xFF000080),
                      size: 32,
                    ),
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF000080),
                    ),
                    weekendStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
                const Divider(color: Colors.black26, thickness: 1),
                Expanded(
                  child: vm.cargandoDia
                      ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF000080)),
                  )
                      : vm.eventosDelDiaSeleccionado.isEmpty
                      ? const Center(
                    child: Text(
                      'No hay eventos\nprogramados',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        color: Colors.black54,
                      ),
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: vm.eventosDelDiaSeleccionado.length,
                    itemBuilder: (context, index) {
                      final item = vm.eventosDelDiaSeleccionado[index];
                      final colorRelleno = _parsearColor(item['color'] ?? '');
                      final colorBorde = _parsearBorde(item['color'] ?? '');

                      // 👇 1. LÓGICA DE NOMBRE VISUAL 👇
                      String nombreAMostrar = item['nombre'] ?? '';
                      if (item['tipo'] == 'cita' || item['tipo'] == 'cita_medica') {
                        nombreAMostrar = 'Cita Médica';
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 70,
                              child: Text(
                                item['hora'] ?? '',
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              // 👇 2. ENVOLVEMOS CON GESTURE DETECTOR PARA NAVEGAR 👇
                              child: GestureDetector(
                                onTap: () {
                                  // 👇 LÓGICA DE NAVEGACIÓN IDÉNTICA AL HOME 👇
                                  if (item['tipo'] == 'medicamento') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => DetalleMedicamentoScreen(medicamento: item),
                                      ),
                                    );
                                  } else if (item['tipo'] == 'medicion' || item['tipo'] == 'medición') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => DetalleMedicionScreen(medicion: item),
                                      ),
                                    );
                                  } else if (item['tipo'] == 'actividad') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => DetalleActividadScreen(actividad: item),
                                      ),
                                    );
                                  } else if (item['tipo'] == 'cita' || item['tipo'] == 'cita_medica') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => DetalleCitaMedicaScreen(cita: item),
                                      ),
                                    );
                                  } else {
                                    print('Tocado un evento de tipo desconocido en calendario: ${item['tipo']}');
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: colorRelleno,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: colorBorde, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.1),
                                        offset: const Offset(0, 3),
                                        blurRadius: 5,
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
                                              nombreAMostrar, // 👇 USAMOS EL NOMBRE CORREGIDO 👇
                                              style: const TextStyle(
                                                fontSize: 26,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            if ((item['tipo'] == 'medicamento' || item['tipo'] == 'actividad') &&
                                                ((item['dosis'] ?? item['detalle']) ?? '').isNotEmpty)
                                              Text(
                                                ((item['dosis'] ?? item['detalle']) as String).split(' — ').first,
                                                style: const TextStyle(
                                                  fontSize: 24,
                                                  color: Color(0xFF000080),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.volume_up, color: Colors.black),
                                        iconSize: 48,
                                        onPressed: () => _reproducirTTS(item),
                                        tooltip: 'Escuchar recordatorio',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const AppFooter(paginaActual: 1),
        ],
      ),
    );
  }
}