import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FotoCuadroWidget extends StatelessWidget {
  final XFile? foto;
  final String label;
  final VoidCallback onTap;

  const FotoCuadroWidget({
    Key? key,
    required this.foto,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black45, width: 3.5),
            ),
            child: foto != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(foto!.path),
                fit: BoxFit.cover,
              ),
            )
                : const Icon(
              Icons.camera_alt,
              color: Colors.black45,
              size: 48,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}