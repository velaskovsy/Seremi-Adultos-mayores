import 'package:flutter/services.dart';

class RutFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {

    // 1. Eliminamos todo lo que no sea número o la letra k/K
    String rutLimpio = newValue.text.replaceAll(RegExp(r'[^0-9kK]'), '');

    // 2. Límite máximo de 9 caracteres (8 números + 1 dígito verificador)
    if (rutLimpio.length > 9) {
      rutLimpio = rutLimpio.substring(0, 9);
    }

    // 3. Si borraron todo, retornamos vacío
    if (rutLimpio.isEmpty) {
      return const TextEditingValue(text: '');
    }

    // 4. Ponemos el guion antes del último dígito
    String rutFormateado = rutLimpio;
    if (rutLimpio.length > 1) {
      rutFormateado = '${rutLimpio.substring(0, rutLimpio.length - 1)}-${rutLimpio.substring(rutLimpio.length - 1)}';
    }

    // 5. Devolvemos el texto formateado
    return TextEditingValue(
      text: rutFormateado,
      selection: TextSelection.collapsed(offset: rutFormateado.length),
    );
  }
}