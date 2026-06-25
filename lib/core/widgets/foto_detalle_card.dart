import 'package:flutter/material.dart';

class FotoDetalleCard extends StatelessWidget {
  final String etiqueta;
  final String rutaFoto;

  const FotoDetalleCard({
    Key? key,
    required this.etiqueta,
    required this.rutaFoto,
  }) : super(key: key);

  // Hacer zoom encapsulado aquí adentro
  void _mostrarImagenAmpliada(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Stack(
            alignment: Alignment.center,
            children: [
              InteractiveViewer(
                panEnabled: true,
                minScale: 0.8,
                maxScale: 4.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.white, size: 40),
                  style: IconButton.styleFrom(backgroundColor: Colors.black45),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool tieneFoto = rutaFoto.isNotEmpty;
    const Color colorPrimario = Color(0xFF000080);
    const Color colorGrisFondo = Color(0xFFF3F4F6);

    return GestureDetector(
      // Si la foto existe, dispara el Pop-Up al tocar. Si no, no hace nada.
      onTap: tieneFoto ? () => _mostrarImagenAmpliada(context, rutaFoto) : null,
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          color: colorGrisFondo,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade500, width: 2),
        ),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: tieneFoto
                    ? ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Image.network(
                    rutaFoto,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    loadingBuilder: (context, child, progress) =>
                    progress == null ? child : const CircularProgressIndicator(),
                    errorBuilder: (context, error, stack) =>
                        Icon(Icons.broken_image_outlined, size: 50, color: Colors.grey.shade500),
                  ),
                )
                    : Icon(Icons.camera_alt_outlined, size: 50, color: Colors.grey.shade500),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade500, width: 2)),
              ),
              child: Text(
                etiqueta,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorPrimario,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}