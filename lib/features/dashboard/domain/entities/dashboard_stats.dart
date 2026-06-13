import 'package:equatable/equatable.dart';

class DashboardStats extends Equatable {
  final int totalExams;
  final String periodoNombre;
  final Map<String, int> examsByCarrera;
  final DateTime? proximoExamen;
  final int salonesEnUso;

  const DashboardStats({
    required this.totalExams,
    required this.periodoNombre,
    required this.examsByCarrera,
    required this.proximoExamen,
    required this.salonesEnUso,
  });

  @override
  List<Object?> get props => [
        totalExams,
        periodoNombre,
        examsByCarrera,
        proximoExamen,
        salonesEnUso,
      ];
}
