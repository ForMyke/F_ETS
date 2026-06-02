import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/exam.dart';

class ExportIcsUseCase implements UseCase<void, ExportIcsParams> {
  const ExportIcsUseCase();

  @override
  Future<Either<Failure, void>> call(ExportIcsParams params) async {
    try {
      final buffer = StringBuffer();
      buffer.writeln('BEGIN:VCALENDAR');
      buffer.writeln('VERSION:2.0');
      buffer.writeln('PRODID:-//ESCOM IPN//ETS App//ES');
      buffer.writeln('CALSCALE:GREGORIAN');

      for (final exam in params.exams) {
        buffer.writeln('BEGIN:VEVENT');
        buffer.writeln('UID:${exam.id}@escom.ipn.mx');
        buffer.writeln('DTSTAMP:${_toICSDate(DateTime.now())}');
        buffer.writeln('DTSTART:${_toICSDate(exam.fechaInicio)}');
        buffer.writeln('DTEND:${_toICSDate(exam.fechaFin)}');
        buffer.writeln('SUMMARY:${exam.materia} — ETS');
        buffer.writeln('LOCATION:Salón ${exam.salon} · Edificio ${exam.edificio} · ESCOM IPN');
        buffer.writeln('DESCRIPTION:Profesor: ${exam.profesor}\\nCarrera: ${exam.carrera}\\nPlan: ${exam.plan}\\nSemestre: ${exam.semestre}');
        buffer.writeln('END:VEVENT');
      }

      buffer.writeln('END:VCALENDAR');

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/ETS_${DateTime.now().millisecondsSinceEpoch}.ics');
      await file.writeAsString(buffer.toString());

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Calendario ETS ESCOM',
      );

      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure('Error al generar el archivo ICS.'));
    }
  }

  String _toICSDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final mo = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final mi = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '${y}${mo}${d}T${h}${mi}${s}';
  }
}

class ExportIcsParams extends Equatable {
  final List<Exam> exams;
  const ExportIcsParams({required this.exams});

  @override
  List<Object> get props => [exams];
}