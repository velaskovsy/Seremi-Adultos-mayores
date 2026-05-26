import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RecordatorioService {

  static const String _url =
      'https://servidorappseremi-production.up.railway.app/api/recordatorios/hoy';

  static const String _tokenKey = 'auth_token';

  Future<Map<String, dynamic>?> obtenerHoy() async {

    try {

      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString(_tokenKey);

      if (token == null) {
        print('No hay token guardado');
        return null;
      }

      final response = await http.get(

        Uri.parse(_url),

        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('STATUS CODE: ${response.statusCode}');
      print('BODY: ${response.body}');

      if (response.statusCode == 200) {

        final data = jsonDecode(response.body);

        return {
          'proxima_tarea': data['proxima_tarea'],

          'franjas': {

            'manana': List<Map<String, dynamic>>.from(
              data['franjas']['manana'] ?? [],
            ),

            'tarde': List<Map<String, dynamic>>.from(
              data['franjas']['tarde'] ?? [],
            ),

            'noche': List<Map<String, dynamic>>.from(
              data['franjas']['noche'] ?? [],
            ),
          }
        };
      }

      print('Error servidor: ${response.statusCode}');
      return null;

    } catch (e) {

      print('ERROR obtenerHoy: $e');
      return null;
    }
  }
}