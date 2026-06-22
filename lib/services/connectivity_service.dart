// lib/services/connectivity_service.dart
//
// Detecta en tiempo real si hay internet disponible.
// Todos los Services lo usan para decidir si van a Railway o a SQLite.
//
// USO:
//   final online = await ConnectivityService().hayInternet();

import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:io';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  /// Retorna true si hay conexión a internet real (no solo WiFi conectado).
  /// Hace un ping a Google DNS para confirmar que hay salida a internet.
  Future<bool> hayInternet() async {
    try {
      final result = await Connectivity().checkConnectivity();

      // Sin ningún tipo de red → false inmediato
      if (result.contains(ConnectivityResult.none) ||
          result.isEmpty) {
        return false;
      }

      // Verificar que realmente haya salida a internet
      final lookup = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      return lookup.isNotEmpty && lookup.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Stream que emite true/false cada vez que cambia la conectividad.
  /// Útil para que el SyncService se active automáticamente al recuperar internet.
  Stream<bool> get onConnectivityChanged {
    return Connectivity().onConnectivityChanged.asyncMap(
      (results) async {
        if (results.contains(ConnectivityResult.none) || results.isEmpty) {
          return false;
        }
        try {
          final lookup = await InternetAddress.lookup('google.com')
              .timeout(const Duration(seconds: 3));
          return lookup.isNotEmpty && lookup.first.rawAddress.isNotEmpty;
        } catch (_) {
          return false;
        }
      },
    );
  }
}
