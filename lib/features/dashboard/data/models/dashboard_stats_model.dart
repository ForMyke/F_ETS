import 'package:etsAndroid/features/dashboard/domain/entities/dashboard_stats.dart';

class DashboardStatsModel extends DashboardStats {
  const DashboardStatsModel({
    required super.totalExams,
    required super.periodoNombre,
    required super.examsByCarrera,
    required super.proximoExamen,
    required super.salonesEnUso,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      totalExams: json['totalExams'] as int,
      periodoNombre: json['periodoNombre'] as String,
      examsByCarrera: Map<String, int>.from(json['examsByCarrera'] as Map),
      proximoExamen: json['proximoExamen'] == null
          ? null
          : DateTime.parse(json['proximoExamen'] as String),
      salonesEnUso: json['salonesEnUso'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalExams': totalExams,
      'periodoNombre': periodoNombre,
      'examsByCarrera': examsByCarrera,
      'proximoExamen': proximoExamen?.toIso8601String(),
      'salonesEnUso': salonesEnUso,
    };
  }
}
