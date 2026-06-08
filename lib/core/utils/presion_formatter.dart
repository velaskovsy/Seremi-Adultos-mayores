import 'package:flutter/services.dart';

class PresionFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {

    // 1. Limpiamos todo para que solo queden números
    String numeros = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (numeros.isEmpty) return const TextEditingValue(text: '');

    // 2. Lógica Médica: Si empieza con 1 o 2, la sistólica (alta) tiene 3 dígitos (ej: 120, 200)
    // Si empieza con 7, 8 o 9, tiene 2 dígitos (ej: 90, 80)
    int largoSistolica = (numeros.startsWith('1') || numeros.startsWith('2')) ? 3 : 2;

    String formateado = numeros;

    // 3. Si el usuario ya escribió más allá de la sistólica, insertamos el " / "
    if (numeros.length > largoSistolica) {
      String sistolica = numeros.substring(0, largoSistolica);
      String diastolica = numeros.substring(largoSistolica);

      // Limitamos la diastólica a máximo 3 dígitos (para que no escriban al infinito)
      if (diastolica.length > 3) {
        diastolica = diastolica.substring(0, 3);
      }

      formateado = '$sistolica / $diastolica';
    }

    // 4. Devolvemos el texto con el cursor al final
    return TextEditingValue(
      text: formateado,
      selection: TextSelection.collapsed(offset: formateado.length),
    );
  }
}