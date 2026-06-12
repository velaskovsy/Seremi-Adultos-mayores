import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputField extends StatelessWidget {
  final String label;
  final String hint;
  final bool isPassword;
  final bool passwordVisible;
  final String? errorText;
  final Function(String) onChanged;
  final VoidCallback? onToggleVisibility;
  final double verticalPadding;
  final double hintFontSize;
  final double labelFontSize;
  final double labelLeftPadding;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const InputField({
    Key? key,
    required this.label,
    required this.hint,
    required this.onChanged,
    this.isPassword = false,
    this.passwordVisible = false,
    this.errorText,
    this.onToggleVisibility,
    this.verticalPadding = 28,
    this.hintFontSize = 32,
    this.labelFontSize = 24,
    this.labelLeftPadding = 34,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Etiqueta encima del campo
        Padding(
          padding: EdgeInsets.only(left: labelLeftPadding, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: labelFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),

        // Campo de texto
        Center(
          child: Container(
            width: 344,
            // 👇 1. ¡CERO ALTURAS FIJAS! Borramos el height y el constraints.
            // Ahora el texto es el que manda sobre el tamaño del cuadro.
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.black, width: 4),
            ),
            child: TextField(
              obscureText: isPassword && !passwordVisible,

              // 👇 2. LA MAGIA DEL CRECIMIENTO DINÁMICO 👇
              minLines: 1, // Nace delgadito (1 sola línea)
              maxLines: isPassword ? 1 : null, // Crece infinitamente hacia abajo a medida que escriben

              textAlign: TextAlign.center,
              // Le ponemos multiline para que el teclado de Android les muestre la tecla "Enter"
              keyboardType: isPassword ? TextInputType.number : TextInputType.multiline,

              inputFormatters: isPassword
                  ? [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ]
                  : inputFormatters,

              style: const TextStyle(
                fontSize: 32,
                color: Color(0xFF000080),
                fontWeight: FontWeight.bold,
              ),
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  fontSize: hintFontSize,
                  color: const Color(0xFF000080).withValues(alpha: 0.5),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  // El verticalPadding le dará el "grosor" base para que no se vea aplastado al nacer
                  vertical: verticalPadding,
                ),
                suffixIcon: isPassword
                    ? IconButton(
                  icon: Icon(
                    passwordVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.black,
                    size: 45,
                  ),
                  onPressed: onToggleVisibility,
                )
                    : null,
              ),
            ),
          ),
        ),

        // Mensaje de error
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 34, top: 6),
            child: Text(
              errorText!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 24,
              ),
            ),
          ),
      ],
    );
  }
}