// lib/views/historial/historial_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/widgets/app_footer.dart';
import '../../services/historial_service.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({Key? key}) : super(key: key);

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

// Filtro seleccionado en la parte superior
enum _FiltroHistorial { todos, medicamento, medicion }

class _HistorialScreenState extends State<HistorialScreen> {
  final HistorialService _historialService = HistorialService();

  bool _cargando = true;
  String? _error;
  List<HistorialItem> _items = [];
  _FiltroHistorial _filtro = _FiltroHistorial.todos;

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  Future<void> _cargarHistorial() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final tipo = _filtro == _FiltroHistorial.medicamento
          ? 'medicamento'
          : _filtro == _FiltroHistorial.medicion
              ? 'medicion'
              : null;

      final resultado = await _historialService.obtenerHistorial(tipo: tipo);

      setState(() {
        _items = resultado;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = 'No se pudo cargar el historial. Verifica tu conexión.';
        _cargando = false;
      });
    }
  }

  /// Agrupa los items por día ("Hoy", "Ayer", o "lunes 15 de junio")
  Map<String, List<HistorialItem>> _agruparPorDia(List<HistorialItem> items) {
    final hoy = DateTime.now();
    final ayer = hoy.subtract(const Duration(days: 1));

    const dias = ['lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'];
    const meses = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];

    String etiquetaPara(DateTime fecha) {
      final esHoy = fecha.year == hoy.year && fecha.month == hoy.month && fecha.day == hoy.day;
      final esAyer = fecha.year == ayer.year && fecha.month == ayer.month && fecha.day == ayer.day;

      if (esHoy) return 'Hoy';
      if (esAyer) return 'Ayer';
      return '${dias[fecha.weekday - 1]} ${fecha.day} de ${meses[fecha.month - 1]}';
    }

    final Map<String, List<HistorialItem>> agrupado = {};
    for (final item in items) {
      final etiqueta = etiquetaPara(item.fechaHora);
      agrupado.putIfAbsent(etiqueta, () => []).add(item);
    }
    return agrupado;
  }

  @override
  Widget build(BuildContext context) {
    final agrupado = _agruparPorDia(_items);
    final grupos = agrupado.entries.toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── HEADER AZUL (mismo estilo que Home) ──
          Container(
            width: double.infinity,
            height: 135,
            color: const Color(0xFF000080),
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.only(top: 50),
            child: const Text(
              'Historial',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // ── FILTROS ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(child: _buildChipFiltro('Todos', _FiltroHistorial.todos)),
                const SizedBox(width: 8),
                Expanded(child: _buildChipFiltro('Medicamentos', _FiltroHistorial.medicamento)),
                const SizedBox(width: 8),
                Expanded(child: _buildChipFiltro('Presión', _FiltroHistorial.medicion)),
              ],
            ),
          ),

          // ── CONTENIDO ──
          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF000080)))
                : _error != null
                    ? _buildEstadoError()
                    : _items.isEmpty
                        ? _buildEstadoVacio()
                        : RefreshIndicator(
                            onRefresh: _cargarHistorial,
                            color: const Color(0xFF000080),
                            child: ListView.builder(
                              padding: const EdgeInsets.only(bottom: 24),
                              itemCount: grupos.length,
                              itemBuilder: (context, index) {
                                final etiquetaDia = grupos[index].key;
                                final itemsDelDia = grupos[index].value;
                                return _buildSeccionDia(etiquetaDia, itemsDelDia);
                              },
                            ),
                          ),
          ),

          const AppFooter(paginaActual: 2),
        ],
      ),
    );
  }

  Widget _buildChipFiltro(String label, _FiltroHistorial valor) {
    final seleccionado = _filtro == valor;
    return GestureDetector(
      onTap: () {
        if (_filtro != valor) {
          setState(() => _filtro = valor);
          _cargarHistorial();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: seleccionado ? const Color(0xFF000080) : const Color(0xFFE8EAF6),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: seleccionado ? Colors.white : const Color(0xFF000080),
          ),
        ),
      ),
    );
  }

  Widget _buildEstadoVacio() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.fact_check_outlined, size: 100, color: Colors.black26),
            const SizedBox(height: 16),
            const Text(
              'Aún no hay registros',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cuando confirmes que tomaste un\nmedicamento o registres tu presión,\naparecerá aquí.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.black45),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadoError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 90, color: Colors.black38),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Ocurrió un error',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, color: Colors.black54, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _cargarHistorial,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF000080),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccionDia(String etiqueta, List<HistorialItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(17, 16, 17, 8),
          child: Text(
            etiqueta[0].toUpperCase() + etiqueta.substring(1),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF000080)),
          ),
        ),
        ...items.map((item) => _buildTarjetaHistorial(item)),
      ],
    );
  }

  Widget _buildTarjetaHistorial(HistorialItem item) {
    final esMedicamento = item.tipo == 'medicamento';

    // Colores siguiendo la misma paleta que usa la pantalla "Hoy"
    Color colorBorde;
    Color colorRelleno;
    IconData icono;

    if (esMedicamento) {
      colorBorde = const Color(0xFF18A528);
      colorRelleno = const Color(0xFFDEFFE1);
      icono = Icons.medication;
    } else {
      switch (item.nivelPresion) {
        case 'critico':
          colorBorde = const Color(0xFFFF0505);
          colorRelleno = const Color(0xFFFFDFDF);
          break;
        case 'elevado':
          colorBorde = const Color(0xFFFFA000);
          colorRelleno = const Color(0xFFFFF3CD);
          break;
        default:
          colorBorde = const Color(0xFF18A528);
          colorRelleno = const Color(0xFFDEFFE1);
      }
      icono = Icons.monitor_heart;
    }

    final horaRegistro = DateFormat('HH:mm').format(item.fechaHora);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colorRelleno,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorBorde, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              offset: const Offset(0, 3),
              blurRadius: 5,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icono, color: colorBorde, size: 34),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.nombre,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    esMedicamento
                        ? 'Confirmado a las $horaRegistro'
                        : '${item.valorPresion ?? '--'} mmHg · ${_etiquetaNivel(item.nivelPresion)} · $horaRegistro',
                    style: TextStyle(fontSize: 16, color: Colors.black.withOpacity(0.65), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            Icon(
              esMedicamento ? Icons.check_circle : _iconoPorNivel(item.nivelPresion),
              color: colorBorde,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  String _etiquetaNivel(String? nivel) {
    switch (nivel) {
      case 'critico':
        return 'Crítica';
      case 'elevado':
        return 'Elevada';
      default:
        return 'Normal';
    }
  }

  IconData _iconoPorNivel(String? nivel) {
    switch (nivel) {
      case 'critico':
        return Icons.error_outline;
      case 'elevado':
        return Icons.warning_amber_rounded;
      default:
        return Icons.check_circle;
    }
  }
}
