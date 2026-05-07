import 'package:flutter/material.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 128,
      color: const Color(0xFF0000B0), // Azul oscuro del footer
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Ícono con fondo blanco redondeado
          const SizedBox(height:10),
          Container(
            width: 40,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.checklist,
              color: Color(0xFF0000B0),
              size: 28,
            ),
          ),

          const SizedBox(height: 0),

          // Texto "Hoy"
          const Text(
            'Hoy',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}