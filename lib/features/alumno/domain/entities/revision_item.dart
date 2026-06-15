import 'package:equatable/equatable.dart';

class RevisionItem extends Equatable {
  final String idRevision;
  final String estado; // solicitada | asignada | calificada
  final DateTime? fechaRevision;
  final String? lugar;
  final double? calificacion;

  const RevisionItem({
    required this.idRevision,
    required this.estado,
    this.fechaRevision,
    this.lugar,
    this.calificacion,
  });

  factory RevisionItem.fromJson(Map<String, dynamic> json) {
    final fechaRaw = json['fecha_revision'] as String?;
    // Support both revisionets (id_revision) and revisionetsespecial (id_revision_esp)
    final idRev =
        (json['id_revision'] ?? json['id_revision_esp'] ?? '') as String;
    return RevisionItem(
      idRevision: idRev,
      estado: json['estado'] as String? ?? 'solicitada',
      fechaRevision: fechaRaw != null ? DateTime.tryParse(fechaRaw) : null,
      lugar: json['lugar'] as String?,
      calificacion: (json['calificacion'] as num?)?.toDouble(),
    );
  }

  @override
  List<Object?> get props =>
      [idRevision, estado, fechaRevision, lugar, calificacion];
}
