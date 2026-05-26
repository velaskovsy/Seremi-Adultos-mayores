class RecordatorioModel {
  final int? id; // SQLite lo genera automáticamente
  final String nombre;
  final String dosis;
  final String hora;
  final String? fecha; // Guardado como "YYYY-MM-DD" o null si es diario
  final String intervalo;
  final String? instrucciones;
  final String? pathFotoCaja;
  final String? pathFotoRemedio;
  final int activo; // 1 para activo, 0 para inactivo

  RecordatorioModel({
    this.id,
    required this.nombre,
    required this.dosis,
    required this.hora,
    this.fecha,
    required this.intervalo,
    this.instrucciones,
    this.pathFotoCaja,
    this.pathFotoRemedio,
    this.activo = 1,
  });

  // Convertir a Map para insertar en SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'dosis': dosis,
      'hora': hora,
      'fecha': fecha,
      'intervalo': intervalo,
      'instrucciones': instrucciones,
      'pathFotoCaja': pathFotoCaja,
      'pathFotoRemedio': pathFotoRemedio,
      'activo': activo,
    };
  }

  // Crear objeto a partir de un Map de la base de datos
  factory RecordatorioModel.fromMap(Map<String, dynamic> map) {
    return RecordatorioModel(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
      dosis: map['dosis'] as String,
      hora: map['hora'] as String,
      fecha: map['fecha'] as String?,
      intervalo: map['intervalo'] as String,
      instrucciones: map['instrucciones'] as String?,
      pathFotoCaja: map['pathFotoCaja'] as String?,
      pathFotoRemedio: map['pathFotoRemedio'] as String?,
      activo: map['activo'] as int,
    );
  }
}