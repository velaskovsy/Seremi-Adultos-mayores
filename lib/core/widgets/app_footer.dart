import 'package:flutter/material.dart';
import '../../views/calendario/calendario_screen.dart';
import '../../views/home/home_screen.dart';

class AppFooter extends StatelessWidget {
  final int paginaActual; // 0 = Hoy, 1 = Calendario

  const AppFooter({Key? key, this.paginaActual = 0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 128,
      color: const Color(0xFF0000B0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [

          // ── HOY ──────────────────────────────────────────
          _buildBoton(
            context: context,
            icono: Icons.checklist,
            label: 'Hoy',
            activo: paginaActual == 0,
            onTap: () {
              if (paginaActual != 0) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (route) => false,
                );
              }
            },
          ),

          // ── CALENDARIO ────────────────────────────────────
          _buildBoton(
            context: context,
            icono: Icons.calendar_month,
            label: 'Calendario',
            activo: paginaActual == 1,
            onTap: () {
              if (paginaActual != 1) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const CalendarioScreen()),
                      (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBoton({
    required BuildContext context,
    required IconData icono,
    required String label,
    required bool activo,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: activo ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icono,
              color: activo
                  ? const Color(0xFF0000B0)
                  : Colors.white.withValues(alpha: 0.7),
              size: 32,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 16,
              color: activo ? Colors.white : Colors.white.withValues(alpha: 0.7),
              fontWeight: activo ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}