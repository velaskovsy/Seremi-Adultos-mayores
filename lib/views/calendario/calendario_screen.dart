import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/widgets/app_footer.dart';
import '../../services/recordatorio_service.dart';

class CalendarioScreen extends StatefulWidget {
  const CalendarioScreen({Key? key}) : super(key: key);

  @override
  State<CalendarioScreen> createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends State<CalendarioScreen> {
  final RecordatorioService _service = RecordatorioService();

  DateTime _diaSeleccionado = DateTime.now();
  DateTime _diaFocuseado = DateTime.now();

  // Mapa de fecha → lista de recordatorios
  Map<DateTime, List<Map<String, dynamic>>> _eventos = {};
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarEventos();
  }

  Future<void> _cargarEventos() async {
    setState(() => _cargando = true);

    final data = await _service.obtenerHoy();
    if (data == null) {
      setState(() => _cargando = false);
      return;
    }

    final Map<DateTime, List<Map<String, dynamic>>> eventos = {};
    final franjas = data['franjas'] as Map<String, dynamic>;

    for (final franja in ['manana', 'tarde', 'noche']) {
      final lista = franjas[franja] as List<dynamic>? ?? [];
      for (final item in lista) {
        final map = Map<String, dynamic>.from(item as Map);
        // Usa la fecha de hoy si no tiene fecha específica
        final fecha = _normalizarFecha(DateTime.now());
        eventos[fecha] = [...(eventos[fecha] ?? []), map];
      }
    }

    setState(() {
      _eventos = eventos;
      _cargando = false;
    });
  }

  DateTime _normalizarFecha(DateTime fecha) {
    return DateTime(fecha.year, fecha.month, fecha.day);
  }

  List<Map<String, dynamic>> _eventosDelDia(DateTime dia) {
    return _eventos[_normalizarFecha(dia)] ?? [];
  }

  Color _parsearColor(String colorStr) {
    switch (colorStr) {
      case 'verde': return const Color(0xFFDEFFE1);
      case 'morado': return const Color(0xFFEACFFF);
      case 'rojo': return const Color(0xFFFFDFDF);
      case 'azul': return const Color(0xFFCDE3FF);
      default: return const Color(0xFFE0E0E0);
    }
  }

  Color _parsearBorde(String colorStr) {
    switch (colorStr) {
      case 'verde': return const Color(0xFF18A528);
      case 'morado': return const Color(0xFFB200FF);
      case 'rojo': return const Color(0xFFFF0505);
      case 'azul': return const Color(0xFF59BDFF);
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventosHoy = _eventosDelDia(_diaSeleccionado);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [

          // ── HEADER ────────────────────────────────────────
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

          // ── CONTENIDO ─────────────────────────────────────
          Expanded(
            child: _cargando
                ? const Center(
                child: CircularProgressIndicator(
                    color: Color(0xFF000080)))
                : Column(
              children: [

                // ── CALENDARIO ────────────────────────
                TableCalendar(
                  locale: 'es_ES',
                  firstDay: DateTime(2024),
                  lastDay: DateTime(2027),
                  focusedDay: _diaFocuseado,
                  selectedDayPredicate: (dia) =>
                      isSameDay(_diaSeleccionado, dia),
                  eventLoader: _eventosDelDia,
                  onDaySelected: (seleccionado, focuseado) {
                    setState(() {
                      _diaSeleccionado = seleccionado;
                      _diaFocuseado = focuseado;
                    });
                  },
                  calendarStyle: CalendarStyle(
                    // Día seleccionado
                    selectedDecoration: const BoxDecoration(
                      color: Color(0xFF000080),
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    // Día de hoy
                    todayDecoration: BoxDecoration(
                      color: const Color(0xFF000080).withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: const TextStyle(
                      color: Color(0xFF000080),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    // Días normales
                    defaultTextStyle: const TextStyle(fontSize: 20),
                    weekendTextStyle: const TextStyle(
                      fontSize: 20,
                      color: Colors.black54,
                    ),
                    outsideTextStyle: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                    // Marcador de eventos
                    markerDecoration: const BoxDecoration(
                      color: Color(0xFFFF8800),
                      shape: BoxShape.circle,
                    ),
                    markerSize: 10,
                    markersMaxCount: 3,
                    cellMargin: const EdgeInsets.all(6),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(
                      fontSize: 22,
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

                // ── RECORDATORIOS DEL DÍA ─────────────
                Expanded(
                  child: eventosHoy.isEmpty
                      ? const Center(
                    child: Text(
                      'No hay eventos\nprogramados',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.black54,
                      ),
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 17, vertical: 8),
                    itemCount: eventosHoy.length,
                    itemBuilder: (context, index) {
                      final item = eventosHoy[index];
                      final colorRelleno = _parsearColor(
                          item['color'] ?? '');
                      final colorBorde = _parsearBorde(
                          item['color'] ?? '');

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 60,
                              child: Text(
                                item['hora'] ?? '',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: colorRelleno,
                                  borderRadius:
                                  BorderRadius.circular(12),
                                  border: Border.all(
                                      color: colorBorde, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black
                                          .withValues(alpha: 0.1),
                                      offset: const Offset(0, 3),
                                      blurRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                        children: [
                                          Text(
                                            item['nombre'] ?? '',
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight:
                                              FontWeight.bold,
                                            ),
                                          ),
                                          if ((item['tipo'] ==
                                              'medicamento' ||
                                              item['tipo'] ==
                                                  'actividad') &&
                                              (item['detalle'] ??
                                                  '')
                                                  .isNotEmpty)
                                            Text(
                                              (item['detalle']
                                              as String)
                                                  .split(' — ')
                                                  .first,
                                              style:
                                              const TextStyle(
                                                fontSize: 16,
                                                color: Colors
                                                    .black87,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.volume_up,
                                        color: Colors.black54,
                                        size: 28),
                                  ],
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

          // ── FOOTER ────────────────────────────────────────
          const AppFooter(paginaActual: 1),
        ],
      ),
    );
  }
}