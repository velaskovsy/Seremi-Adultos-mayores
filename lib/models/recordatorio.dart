class Recordatorio {
  final int id; // SQLite pide un entero; nos servirá también como ID de la alarma
  final String titulo;
  final DateTime fechaHora;

  Recordatorio({required this.id, required this.titulo, required this.fechaHora});

  // Convertir a Mapa para guardar en SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'fechaHora': fechaHora.toIso8601String(),
    };
  }

  // Convertir de Mapa a Objeto
  factory Recordatorio.fromMap(Map<String, dynamic> map) {
    return Recordatorio(
      id: map['id'],
      titulo: map['titulo'],
      fechaHora: DateTime.parse(map['fechaHora']),
    );
  }
}