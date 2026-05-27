// lib/services/voice_service.dart
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VoiceService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // Configuramos el idioma local (español de Chile/Latinoamérica)
      await _flutterTts.setLanguage("es-CL");

      // Velocidad natural de lectura (0.45 - 0.5 es ideal para adultos mayores)
      await _flutterTts.setSpeechRate(0.48);

      // Tono estándar de la voz
      await _flutterTts.setPitch(1.0);

      // Configuración nativa para iOS (Altavoz activado por defecto)
      await _flutterTts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        ],
      );

      // Configuración nativa para Android
      await _flutterTts.awaitSpeakCompletion(true);

      _isInitialized = true;
    } catch (e) {
      debugPrint("Error inicializando VoiceService: $e");
    }
  }

  // Método principal para reproducir texto
  Future<void> hablar(String texto) async {
    if (!_isInitialized) await init();
    if (texto.isNotEmpty) {
      await _flutterTts.stop(); // Corta cualquier lectura previa para no solaparse
      await _flutterTts.speak(texto);
    }
  }

  // Detener el audio inmediatamente
  Future<void> detener() async {
    await _flutterTts.stop();
  }
}