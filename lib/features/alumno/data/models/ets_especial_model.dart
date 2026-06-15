import 'package:etsAndroid/features/alumno/domain/entities/ets_especial_item.dart';
import 'package:etsAndroid/features/alumno/domain/entities/revision_item.dart';

class EtsEspecialModel extends EtsEspecialItem {
  const EtsEspecialModel({
    required super.idEtsEspecial,
    required super.estado,
    super.calificacion,
    super.resultado,
    super.revision,
  });

  factory EtsEspecialModel.fromJson(Map<String, dynamic> json) {
    final revList =
        (json['revisionetsespecial'] as List<dynamic>?) ?? [];
    final revMap = revList.isNotEmpty
        ? revList.first as Map<String, dynamic>
        : null;

    return EtsEspecialModel(
      idEtsEspecial: json['id_ets_especial'] as String? ?? '',
      estado: json['estado'] as String? ?? 'pendiente',
      calificacion: (json['calificacion'] as num?)?.toDouble(),
      resultado: json['resultado'] as String?,
      revision: revMap != null ? RevisionItem.fromJson(revMap) : null,
    );
  }
}
