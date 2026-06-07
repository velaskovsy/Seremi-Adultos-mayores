import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PermisosScreen extends StatefulWidget {
  const PermisosScreen({super.key});

  @override
  State<PermisosScreen> createState() => _PermisosScreenState();
}

class _PermisosScreenState extends State<PermisosScreen> {
  bool _notificacionesGranted = false;
  bool _bateriaGranted = false;
  bool _superposicionGranted = false;
  bool _alarmasExactasGranted = false;

  @override
  void initState() {
    super.initState();
    _revisarPermisos();
  }

  // 👇 Revisa en tiempo real cómo están los interruptores del celular
  Future<void> _revisarPermisos() async {
    _notificacionesGranted = await Permission.notification.isGranted;
    _bateriaGranted = await Permission.ignoreBatteryOptimizations.isGranted;
    _superposicionGranted = await Permission.systemAlertWindow.isGranted;
    setState(() {});
  }

  // 👇 Lanza el pop-up oficial de Android o lleva a los ajustes
  Future<void> _solicitarPermiso(Permission permiso) async {
    await permiso.request();
    await _revisarPermisos(); // Actualizamos la pantalla después de pedirlo
  }

// 👇 FUNCIÓN ACTUALIZADA CON PLAN B 👇
  Future<void> _solicitarAlarmasExactas() async {
    final plugin = FlutterLocalNotificationsPlugin();
    final androidImplementation = plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestExactAlarmsPermission();
    }

    await Future.delayed(const Duration(seconds: 1));
    bool concedido = await Permission.scheduleExactAlarm.isGranted;

    // Si Android bloqueó la apertura directa, lo mandamos a los ajustes generales
    if (!concedido) {
      await openAppSettings();
    }

    await Future.delayed(const Duration(seconds: 1));
    await _revisarPermisos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Confiabilidad de Alarmas'),
        backgroundColor: const Color(0xFF000080),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Para que la aplicación nunca falle y suene incluso con el teléfono apagado, necesitamos estos permisos:',
            style: TextStyle(fontSize: 24, color: Colors.black87, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),

          _buildPermisoTile(
            titulo: 'Notificaciones',
            descripcion: 'Permite mostrar los recordatorios en pantalla.',
            icono: Icons.notifications_active,
            estaConcedido: _notificacionesGranted,
            onTap: () => _solicitarPermiso(Permission.notification),
          ),

          _buildPermisoTile(
            titulo: 'Ignorar Batería',
            descripcion: 'Evita que el celular apague la alarma para ahorrar batería.',
            icono: Icons.battery_charging_full,
            estaConcedido: _bateriaGranted,
            onTap: () => _solicitarPermiso(Permission.ignoreBatteryOptimizations),
          ),

          _buildPermisoTile(
            titulo: 'Mostrar sobre otras apps',
            descripcion: 'Permite que la alarma roja secuestre la pantalla bloqueada.',
            icono: Icons.layers,
            estaConcedido: _superposicionGranted,
            onTap: () => _solicitarPermiso(Permission.systemAlertWindow),
          ),
        ],
      ),
    );
  }

// ─── WIDGET REUTILIZABLE CORREGIDO ───
  Widget _buildPermisoTile({
    required String titulo,
    required String descripcion,
    required IconData icono,
    required bool estaConcedido,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        // Ya no ponemos el color aquí de fondo, solo el borde
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: estaConcedido ? Colors.green : Colors.red, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: ListTile(
          // FLUTTER EXIGE QUE EL COLOR VAYA AQUÍ ADENTRO
          tileColor: estaConcedido ? Colors.green.shade50 : Colors.red.shade50,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          leading: Icon(icono, size: 40, color: estaConcedido ? Colors.green : Colors.red),
          title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 27)),
          subtitle: Text(descripcion, style : const TextStyle(fontSize: 22)),
          trailing: estaConcedido
              ? const Icon(Icons.check_circle, color: Colors.green, size: 50)
              : const Text('Corregir', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 24)),
          onTap: estaConcedido ? null : onTap,
        ),
      ),
    );
  }
}