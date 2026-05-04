import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputField extends StatelessWidget {
  final String label;
  final String hint;
  final bool isPassword;
  final bool passwordVisible; // Solo se usa si isPassword es true
  final String? errorText; // Muestra error debajo del campo
  final Function(String) onChanged;
  final VoidCallback? onToggleVisibility; // Solo se usa si isPassword es true
  final double verticalPadding;
  final double hintFontSize;
  final TextInputType keyboardType;

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
    this.keyboardType = TextInputType.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Etiqueta encima del campo
        Padding(
          padding: const EdgeInsets.only(left: 34, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),

        // Campo de texto
        Center(
          child: Container(
            width: 344,
            height: 95,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.black, width: 4),
            ),
            child: TextField(
              obscureText: isPassword && !passwordVisible,
              textAlign: TextAlign.center,
              keyboardType: isPassword ? TextInputType.number : keyboardType,
              inputFormatters: isPassword
                  ? [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ]
                  : [],
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
