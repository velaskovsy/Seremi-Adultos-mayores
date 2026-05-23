// lib/services/storage_service.dart
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  static const String _bucket = 'fotos-recordatorios';

  final SupabaseClient _supabase = Supabase.instance.client;

  /// Sube una foto al bucket y retorna la URL pública.
  /// Retorna null si falla.
  Future<String?> subirFoto(XFile foto, String carpeta) async {
    try {
      final file = File(foto.path);
      final extension = foto.path.split('.').last;
      final nombre = '${carpeta}/${DateTime.now().millisecondsSinceEpoch}.$extension';

      await _supabase.storage.from(_bucket).upload(
        nombre,
        file,
        fileOptions: const FileOptions(upsert: true),
      );

      final url = _supabase.storage.from(_bucket).getPublicUrl(nombre);
      return url;
    } catch (_) {
      return null;
    }
  }
}
