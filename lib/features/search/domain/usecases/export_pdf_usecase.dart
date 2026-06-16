import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/core/usecases/usecase.dart';
import 'package:etsAndroid/features/search/domain/entities/exam.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ExportPdfUseCase implements UseCase<void, ExportPdfParams> {
  const ExportPdfUseCase();

  @override
  Future<Either<Failure, void>> call(ExportPdfParams params) async {
    try {
      pw.ImageProvider? logo;
      try {
        final logoBytes = await rootBundle.load('assets/images/escom_logo.png');
        logo = pw.MemoryImage(logoBytes.buffer.asUint8List());
      } catch (_) {}

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) => [
            _buildHeader(params, logo),
            pw.SizedBox(height: 20),
            _buildTable(params.exams),
            pw.SizedBox(height: 16),
            _buildFooter(),
          ],
        ),
      );

      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'ETS_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );

      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure('Error al generar el PDF.'));
    }
  }

  pw.Widget _buildHeader(ExportPdfParams params, pw.ImageProvider? logo) {
    final filters = <String>[];
    if (params.carrera != null) filters.add('Carrera: ${params.carrera}');
    if (params.plan != null) filters.add('Plan: ${params.plan}');
    if (params.semestre != null) filters.add('Semestre: ${params.semestre}');

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                if (logo != null) ...[
                  pw.Image(logo, width: 48, height: 48),
                  pw.SizedBox(width: 12),
                ],
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'INSTITUTO POLITÉCNICO NACIONAL',
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.Text(
                      'ESCOM',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                    pw.Text(
                      'Calendario de Exámenes a Título de Suficiencia',
                      style: pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.Text(
              _formatDate(DateTime.now()),
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Divider(color: PdfColors.blue200, thickness: 1.5),
        if (filters.isNotEmpty) ...[
          pw.SizedBox(height: 6),
          pw.Wrap(
            spacing: 12,
            children: filters
                .map((f) => pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.blue50,
                        borderRadius:
                            const pw.BorderRadius.all(pw.Radius.circular(20)),
                        border: pw.Border.all(color: PdfColors.blue200),
                      ),
                      child: pw.Text(
                        f,
                        style:
                            pw.TextStyle(fontSize: 9, color: PdfColors.blue800),
                      ),
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }

  pw.Widget _buildTable(List<Exam> exams) {
    const headers = [
      'Materia',
      'Fecha',
      'Hora',
      'Turno',
      'Salón',
      'Profesor',
      'Carrera',
    ];

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.blue100, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1.4),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1.2),
        4: const pw.FlexColumnWidth(1),
        5: const pw.FlexColumnWidth(2.5),
        6: const pw.FlexColumnWidth(1.2),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.blue800),
          children: headers
              .map((h) => pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 8, vertical: 6),
                    child: pw.Text(
                      h,
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                  ))
              .toList(),
        ),
        ...exams.asMap().entries.map((entry) {
          final i = entry.key;
          final exam = entry.value;
          final isEven = i % 2 == 0;

          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: isEven ? PdfColors.white : PdfColors.blue50,
            ),
            children: [
              exam.materia,
              _formatDate(exam.fecha),
              exam.hora,
              exam.turno,
              exam.salon,
              exam.profesor,
              '${exam.carrera}\nPlan ${exam.plan}\nSem. ${exam.semestre}',
            ]
                .map((cell) => pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 8, vertical: 5),
                      child: pw.Text(
                        cell,
                        style: const pw.TextStyle(fontSize: 8),
                      ),
                    ))
                .toList(),
          );
        }),
      ],
    );
  }

  pw.Widget _buildFooter() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'Generado por la app ESCOM · IPN',
          style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
        ),
        pw.Text(
          'Este documento es informativo y puede cambiar.',
          style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class ExportPdfParams extends Equatable {
  final List<Exam> exams;
  final String? carrera;
  final int? semestre;
  final String? plan;

  const ExportPdfParams({
    required this.exams,
    this.carrera,
    this.semestre,
    this.plan,
  });

  @override
  List<Object?> get props => [exams, carrera, semestre, plan];
}
