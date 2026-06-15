import 'dart:convert';
import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:share_plus/share_plus.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/core/usecases/usecase.dart';
import 'package:etsAndroid/features/search/domain/entities/exam.dart';

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
        buffer.writeln('DTSTAMP:${_toICSDate(DateTime.now().toUtc())}Z');
        buffer.writeln('DTSTART:${_toICSDate(exam.fechaInicio.toUtc())}Z');
        buffer.writeln('DTEND:${_toICSDate(exam.fechaFin.toUtc())}Z');
        buffer.writeln('SUMMARY:${exam.materia} — ETS');
        buffer.writeln('LOCATION:Salón ${exam.salon} · Edificio ${exam.edificio} · ESCOM IPN');
        buffer.writeln('DESCRIPTION:Profesor: ${exam.profesor}\\nCarrera: ${exam.carrera}\\nPlan: ${exam.plan}\\nSemestre: ${exam.semestre}');
        buffer.writeln('END:VEVENT');
      }

      buffer.writeln('END:VCALENDAR');

      final bytes = Uint8List.fromList(utf8.encode(buffer.toString()));
      final xFile = XFile.fromData(
        bytes,
        mimeType: 'text/calendar',
        name: 'ETS_ESCOM.ics',
      );

      await Share.shareXFiles(
        [xFile],
        subject: 'Calendario ETS ESCOM',
      );

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Error al generar el archivo ICS: $e'));
    }
  }

  String _toICSDate(DateTime dt) {
    return '${dt.year.toString().padLeft(4, '0')}'
        '${dt.month.toString().padLeft(2, '0')}'
        '${dt.day.toString().padLeft(2, '0')}T'
        '${dt.hour.toString().padLeft(2, '0')}'
        '${dt.minute.toString().padLeft(2, '0')}'
        '${dt.second.toString().padLeft(2, '0')}';
  }
}

class ExportIcsParams extends Equatable {
  final List<Exam> exams;
  const ExportIcsParams({required this.exams});

  @override
  List<Object> get props => [exams];
}