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
  DateTime _diaFocuseado    = DateTime.now();

  // Fechas que tienen al menos un recordatorio → puntitos del calendario
  Set<String> _diasConEventos = {};

  // Recordatorios del día seleccionado actualmente
  List<Map<String, dynamic>> _eventosDelDiaSeleccionado = [];

  bool _cargandoCalendario = true; // spinner mientras carga los puntitos
  bool _cargandoDia        = false; // spinner mientras carga el detalle del día

  // ── Helpers de formato ────────────────────────────────────────

  String _formatearFecha(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // Rango: primer día del mes anterior → último día del mes siguiente
  (DateTime, DateTime) _rangoParaMes(DateTime mes) {
    final desde = DateTime(mes.year, mes.month - 1, 1);
    final hasta  = DateTime(mes.year, mes.month + 2, 0);
    return (desde, hasta);
  }

  // ── Carga de puntitos (Lógica del amigo) ──────────────────────

  Future<void> _cargarPuntitos(DateTime mes) async {
    setState(() => _cargandoCalendario = true);

    final (desde, hasta) = _rangoParaMes(mes);
    final dias = await _service.obtenerDiasConEventos(desde, hasta);

    setState(() {
      _diasConEventos    = dias.toSet();
      _cargandoCalendario = false;
    });
  }

  // ── Carga del detalle del día seleccionado (Lógica del amigo) ─

  Future<void> _cargarDia(DateTime dia) async {
    setState(() {
      _cargandoDia = true;
      _eventosDelDiaSeleccionado = [];
    });

    final data = await _service.obtenerDia(dia);

    final List<Map<String, dynamic>> eventos = [];
    if (data != null) {
      final franjas = data['franjas'] as Map<String, dynamic>;
      for (final franja in ['manana', 'tarde', 'noche']) {
        final lista = franjas[franja] as List<dynamic>? ?? [];
        eventos.addAll(lista.map((e) => Map<String, dynamic>.from(e as Map)));
      }
      // Ordenar por hora ascendente
      eventos.sort((a, b) => (a['hora'] as String).compareTo(b['hora'] as String));
    }

    setState(() {
      _eventosDelDiaSeleccionado = eventos;
      _cargandoDia = false;
    });
  }

  // ── Lifecycle ─────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _cargarPuntitos(_diaFocuseado);
    _cargarDia(_diaSeleccionado);
  }

  // ── EventLoader para el TableCalendar ─────────────────────────
  List<Object> _eventLoader(DateTime dia) {
    return _diasConEventos.contains(_formatearFecha(dia)) ? [true] : [];
  }

  // ── Colores ───────────────────────────────────────────────────

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

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [

          // ── HEADER ──────────────────────────────────────────
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

          // ── CONTENIDO ───────────────────────────────────────
          Expanded(
            child: Column(
              children: [

                // ── CALENDARIO (Con tus estilos estéticos) ─────────
                _cargandoCalendario
                    ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: LinearProgressIndicator(color: Color(0xFF000080)),
                )
                    : TableCalendar(
                  locale: 'es_ES',
                  firstDay: DateTime(2024),
                  lastDay: DateTime(2027),
                  focusedDay: _diaFocuseado,
                  selectedDayPredicate: (dia) =>
                      isSameDay(_diaSeleccionado, dia),
                  eventLoader: _eventLoader,

                  // Cuando cambia el mes → recargar puntitos
                  onPageChanged: (nuevaFecha) {
                    _diaFocuseado = nuevaFecha;
                    _cargarPuntitos(nuevaFecha);
                  },

                  // Cuando toca un día → cargar detalle
                  onDaySelected: (seleccionado, focuseado) {
                    setState(() {
                      _diaSeleccionado = seleccionado;
                      _diaFocuseado    = focuseado;
                    });
                    _cargarDia(seleccionado);
                  },

                  // TUS ESTILOS ESTÉTICOS APLICADOS AQUÍ 👇
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

                // ── DETALLE DEL DÍA SELECCIONADO ────────────
                Expanded(
                  child: _cargandoDia
                      ? const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF000080)),
                  )
                      : _eventosDelDiaSeleccionado.isEmpty
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    itemCount: _eventosDelDiaSeleccionado.length,
                    itemBuilder: (context, index) {
                      final item = _eventosDelDiaSeleccionado[index];
                      final colorRelleno =
                      _parsearColor(item['color'] ?? '');
                      final colorBorde =
                      _parsearBorde(item['color'] ?? '');

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
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
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
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['nombre'] ?? '',
                                            style: const TextStyle(
                                              fontSize: 26,
                                              fontWeight:
                                              FontWeight.bold,
                                            ),
                                          ),
                                          if ((item['tipo'] ==
                                              'medicamento' ||
                                              item['tipo'] ==
                                                  'actividad') &&
                                              (item['detalle'] ?? '')
                                                  .isNotEmpty)
                                            Text(
                                              (item['detalle']
                                              as String)
                                                  .split(' — ')
                                                  .first,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black87,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.volume_up,
                                        color: Colors.black,
                                        size: 48),
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

          // ── FOOTER ──────────────────────────────────────────
          const AppFooter(paginaActual: 1),
        ],
      ),
    );
  }
}