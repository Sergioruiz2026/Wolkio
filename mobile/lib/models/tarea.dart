enum CategoriaTarea { patio, mudanza, muebles, limpieza }

enum EstadoTarea {
  publicada,
  buscandoPrestador,
  asignada,
  enCurso,
  finalizada,
  cancelada,
}

class Tarea {
  final String id;
  final String solicitanteId;
  final CategoriaTarea categoria;
  final String descripcion;
  final List<String> fotos;
  final double latitud;
  final double longitud;
  final String? direccionExacta;
  final double precioOfrecido;
  final DateTime? fechaHoraProgramada;
  final EstadoTarea estado;
  final String? prestadorId;

  Tarea({
    required this.id,
    required this.solicitanteId,
    required this.categoria,
    required this.descripcion,
    this.fotos = const [],
    required this.latitud,
    required this.longitud,
    this.direccionExacta,
    required this.precioOfrecido,
    this.fechaHoraProgramada,
    this.estado = EstadoTarea.publicada,
    this.prestadorId,
  });

  factory Tarea.fromJson(Map<String, dynamic> json) {
    return Tarea(
      id: json['id'],
      solicitanteId: json['solicitante_id'],
      categoria: CategoriaTarea.values.byName(json['categoria']),
      descripcion: json['descripcion'] ?? '',
      fotos: List<String>.from(json['fotos'] ?? []),
      latitud: (json['latitud'] as num).toDouble(),
      longitud: (json['longitud'] as num).toDouble(),
      direccionExacta: json['direccion_exacta'],
      precioOfrecido: (json['precio_ofrecido'] as num).toDouble(),
      fechaHoraProgramada: json['fecha_hora_programada'] != null
          ? DateTime.parse(json['fecha_hora_programada'])
          : null,
      estado: EstadoTarea.values.byName(json['estado'] ?? 'publicada'),
      prestadorId: json['prestador_id'],
    );
  }

  Map<String, dynamic> toJson() => {
        'solicitante_id': solicitanteId,
        'categoria': categoria.name,
        'descripcion': descripcion,
        'fotos': fotos,
        'latitud': latitud,
        'longitud': longitud,
        'direccion_exacta': direccionExacta,
        'precio_ofrecido': precioOfrecido,
        'fecha_hora_programada': fechaHoraProgramada?.toIso8601String(),
        'estado': estado.name,
        'prestador_id': prestadorId,
      };
}
