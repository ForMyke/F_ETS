import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import 'package:etsAndroid/features/alumno/domain/entities/alumno_profile.dart';
import 'package:etsAndroid/features/alumno/domain/entities/inscripcion_item.dart';
import 'package:etsAndroid/features/alumno/presentation/bloc/alumno_bloc.dart';

// Estado string constants (match DB values)
const String _kEstadoPendiente = 'pendiente';
const String _kEstadoConfirmada = 'confirmada';
const String _kEstadoBajaSolicitada = 'baja_solicitada';
const String _kEstadoRechazada = 'rechazada';
const String _kEstadoBajaAprobada = 'baja_aprobada';
const String _kEstadoAprobado = 'aprobado';
const String _kEstadoReprobado = 'reprobado';
const String _kEstadoCalificado = 'calificado';

class AlumnoInscripcionesPage extends StatefulWidget {
  final AlumnoProfile perfil;

  const AlumnoInscripcionesPage({super.key, required this.perfil});

  @override
  State<AlumnoInscripcionesPage> createState() =>
      _AlumnoInscripcionesPageState();
}

class _AlumnoInscripcionesPageState extends State<AlumnoInscripcionesPage> {
  bool _exportando = false;
  bool _exportandoIcs = false;

  @override
  void initState() {
    super.initState();
    context
        .read<AlumnoBloc>()
        .add(AlumnoInscripcionesLoaded(perfil: widget.perfil));
  }

  Future<void> _exportarPdf(List<InscripcionItem> inscripciones) async {
    setState(() => _exportando = true);
    try {
      final pdf = pw.Document();
      final now = DateTime.now();
      final meses = [
        'ene','feb','mar','abr','may','jun',
        'jul','ago','sep','oct','nov','dic'
      ];
      String fmtDate(DateTime d) => '${d.day} ${meses[d.month - 1]} ${d.year}';
      String estadoLabel(String e) {
        switch (e) {
          case 'aprobado': return 'Aprobado';
          case 'reprobado': return 'Reprobado';
          case 'calificado': return 'Calificado';
          default: return 'Pendiente';
        }
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context ctx) => [
            // Encabezado
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('ESCOM · IPN',
                        style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue900)),
                    pw.Text('Comprobante de Inscripciones ETS',
                        style: pw.TextStyle(
                            fontSize: 11, color: PdfColors.grey700)),
                  ],
                ),
                pw.Text(fmtDate(now),
                    style: pw.TextStyle(
                        fontSize: 10, color: PdfColors.grey600)),
              ],
            ),
            pw.SizedBox(height: 6),
            pw.Divider(color: PdfColors.blue200, thickness: 1.5),
            pw.SizedBox(height: 8),
            // Datos del alumno
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue50,
                borderRadius:
                    const pw.BorderRadius.all(pw.Radius.circular(8)),
                border: pw.Border.all(color: PdfColors.blue100),
              ),
              child: pw.Row(
                children: [
                  pw.Text('Alumno: ',
                      style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900)),
                  pw.Text(
                      '${widget.perfil.nombre} ${widget.perfil.apellidoPaterno} ${widget.perfil.apellidoMaterno}',
                      style: const pw.TextStyle(fontSize: 10)),
                  pw.SizedBox(width: 24),
                  pw.Text('Boleta: ',
                      style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900)),
                  pw.Text(widget.perfil.boleta,
                      style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
            ),
            pw.SizedBox(height: 16),
            // Tabla
            pw.Table(
              border: pw.TableBorder.all(
                  color: PdfColors.blue100, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(1.6),
                2: const pw.FlexColumnWidth(1.1),
                3: const pw.FlexColumnWidth(1.2),
                4: const pw.FlexColumnWidth(1.3),
                5: const pw.FlexColumnWidth(1.4),
                6: const pw.FlexColumnWidth(1),
              },
              children: [
                pw.TableRow(
                  decoration:
                      const pw.BoxDecoration(color: PdfColors.blue800),
                  children: ['Materia', 'Fecha', 'Hora', 'Turno',
                      'Salón', 'Estado', 'Cal.']
                      .map((h) => pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                                horizontal: 6, vertical: 6),
                            child: pw.Text(h,
                                style: pw.TextStyle(
                                    fontSize: 8,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.white)),
                          ))
                      .toList(),
                ),
                ...inscripciones.asMap().entries.map((e) {
                  final i = e.key;
                  final item = e.value;
                  return pw.TableRow(
                    decoration: pw.BoxDecoration(
                        color: i % 2 == 0
                            ? PdfColors.white
                            : PdfColors.blue50),
                    children: [
                      item.materia,
                      fmtDate(item.fechaInicio),
                      item.hora,
                      item.turno,
                      '${item.salon}·E${item.edificio}',
                      estadoLabel(item.estado),
                      item.calificacion != null
                          ? item.calificacion!.toStringAsFixed(1)
                          : '—',
                    ]
                        .map((cell) => pw.Padding(
                              padding: const pw.EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 5),
                              child: pw.Text(cell,
                                  style:
                                      const pw.TextStyle(fontSize: 8)),
                            ))
                        .toList(),
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 16),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Generado por la app ESCOM · IPN',
                    style: pw.TextStyle(
                        fontSize: 8, color: PdfColors.grey500)),
                pw.Text(
                    'Documento informativo — sujeto a cambios.',
                    style: pw.TextStyle(
                        fontSize: 8, color: PdfColors.grey500)),
              ],
            ),
          ],
        ),
      );

      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename:
            'inscripciones_${widget.perfil.boleta}_${now.millisecondsSinceEpoch}.pdf',
      );
    } finally {
      if (mounted) setState(() => _exportando = false);
    }
  }

  Future<void> _exportarIcs(List<InscripcionItem> inscripciones) async {
    if (_exportandoIcs) return;
    HapticFeedback.mediumImpact();
    setState(() => _exportandoIcs = true);
    try {
      final buf = StringBuffer();
      buf.writeln('BEGIN:VCALENDAR');
      buf.writeln('VERSION:2.0');
      buf.writeln('PRODID:-//ESCOM IPN//ETS App//ES');
      buf.writeln('CALSCALE:GREGORIAN');

      for (final ins in inscripciones) {
        final inicio = ins.fechaInicio.toUtc();
        final fin = inicio.add(const Duration(hours: 2));
        String fmt(DateTime d) =>
            '${d.year.toString().padLeft(4, '0')}'
            '${d.month.toString().padLeft(2, '0')}'
            '${d.day.toString().padLeft(2, '0')}T'
            '${d.hour.toString().padLeft(2, '0')}'
            '${d.minute.toString().padLeft(2, '0')}'
            '${d.second.toString().padLeft(2, '0')}Z';

        buf.writeln('BEGIN:VEVENT');
        buf.writeln('UID:${ins.idEts}@escom.ipn.mx');
        buf.writeln('DTSTAMP:${fmt(DateTime.now().toUtc())}');
        buf.writeln('DTSTART:${fmt(inicio)}');
        buf.writeln('DTEND:${fmt(fin)}');
        buf.writeln('SUMMARY:${ins.materia} — ETS');
        buf.writeln('LOCATION:Salón ${ins.salon} · Edificio ${ins.edificio} · ESCOM IPN');
        buf.writeln('DESCRIPTION:Carrera: ${ins.carrera}');
        buf.writeln('END:VEVENT');
      }

      buf.writeln('END:VCALENDAR');

      final bytes = Uint8List.fromList(utf8.encode(buf.toString()));
      await Share.shareXFiles(
        [XFile.fromData(bytes, mimeType: 'text/calendar', name: 'mis_ets.ics')],
        subject: 'Mis ETS — ESCOM IPN',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error al exportar calendario: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    } finally {
      if (mounted) setState(() => _exportandoIcs = false);
    }
  }

  Future<void> _generarFichaEts(InscripcionItem item) async {
    pw.Widget infoRow(String label, String value) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 3),
          child: pw.Row(children: [
            pw.Text('$label ', style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold)),
            pw.Expanded(child: pw.Text(value, style: const pw.TextStyle(fontSize: 9.5))),
          ]),
        );

    pw.Widget fillField(String label) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            pw.Container(
              height: 14,
              decoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(width: 0.8, color: PdfColors.grey700)),
              ),
            ),
          ],
        );

    try {
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.symmetric(horizontal: 52, vertical: 44),
          build: (pw.Context ctx) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // ── Encabezado ──────────────────────────────────────────
              pw.Center(child: pw.Column(children: [
                pw.Text('INSTITUTO POLITÉCNICO NACIONAL',
                    style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
                pw.Text('ESCOM',
                    style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                pw.Text('ESCOMUNIDAD', style: const pw.TextStyle(fontSize: 10)),
              ])),
              pw.SizedBox(height: 8),
              pw.Divider(color: PdfColors.grey500, thickness: 0.8),
              pw.SizedBox(height: 6),
              pw.Center(child: pw.Column(children: [
                pw.Text('Evaluación a Título de Suficiencia (ETS)',
                    style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                pw.Text('Semestre 2026/2/2', style: const pw.TextStyle(fontSize: 10)),
              ])),
              pw.SizedBox(height: 10),
              // ── Texto informativo ───────────────────────────────────
              pw.Text('Las inscripciones a ETS se realizarán los días 9, 10 y 11 de julio de 2026',
                  style: const pw.TextStyle(fontSize: 9.5)),
              pw.Text('directamente en ventanillas de Gestión Escolar',
                  style: const pw.TextStyle(fontSize: 9.5)),
              pw.Text('en un horario de 10:00 a 19:00 hrs.',
                  style: const pw.TextStyle(fontSize: 9.5)),
              pw.Text('Presentar copia del dictamen vigente (en caso de aplicar)',
                  style: const pw.TextStyle(fontSize: 9.5)),
              pw.SizedBox(height: 8),
              pw.Divider(color: PdfColors.grey400, thickness: 0.5),
              pw.SizedBox(height: 6),
              pw.Text('Los ETS se aplicarán:',
                  style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold)),
              pw.Text('Del 15 al 18 de julio de 2025', style: const pw.TextStyle(fontSize: 9.5)),
              pw.SizedBox(height: 8),
              pw.Divider(color: PdfColors.grey400, thickness: 0.5),
              pw.SizedBox(height: 6),
              pw.Text('Deberás realizar el pago del ETS en:',
                  style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              infoRow('Banco:', 'BBVA'),
              infoRow('Cuenta:', '0120599727'),
              infoRow('Nombre:', 'INSTITUTO POLITÉCNICO NACIONAL R11 B00 IPN ING LIF ESCOM'),
              infoRow('Concepto:', 'Número de boleta'),
              infoRow('Monto:', '\$20.00 (Veinte pesos 00/100 M.N.)'),
              pw.SizedBox(height: 8),
              pw.Divider(color: PdfColors.grey400, thickness: 0.5),
              pw.SizedBox(height: 6),
              pw.Text('En el anverso del comprobante de pago deberás anotar:',
                  style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 14),
              // ── Campos para rellenar con pluma ──────────────────────
              fillField('Boleta'),
              pw.SizedBox(height: 14),
              fillField('Nombre Completo'),
              pw.SizedBox(height: 14),
              fillField('Unidad de Aprendizaje a presentar ETS'),
              pw.SizedBox(height: 14),
              fillField('Turno a presentar ETS'),
              pw.SizedBox(height: 14),
              pw.Divider(color: PdfColors.grey400, thickness: 0.5),
              pw.SizedBox(height: 6),
              pw.Text('Consulta horario y logística para la presentación de los ETS en:',
                  style: const pw.TextStyle(fontSize: 9)),
              pw.Text('https://uteycv.escom.ipn.mx/sacad/ets/',
                  style: pw.TextStyle(fontSize: 9, color: PdfColors.blue600)),
              pw.Spacer(),
              pw.Center(child: pw.Column(children: [
                pw.Text('escom.ipn.mx',
                    style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                pw.Text('ESCUELA SUPERIOR DE CÓMPUTO',
                    style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                pw.Text('2  0  2  6',
                    style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              ])),
            ],
          ),
        ),
      );

      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'ficha_ets_${item.idEts}.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error al generar ficha: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<AlumnoBloc, AlumnoState>(
      listener: (context, state) {
        if (state is AlumnoBajaSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Solicitud de baja enviada al administrador'),
            backgroundColor: AppColors.warning,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ));
        } else if (state is AlumnoBajaFailure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ));
        }
      },
      child: Scaffold(
      backgroundColor: isDark ? AppColors.darkBgPrimary : AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkBlueLight
                          : AppColors.blueSurface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark
                                ? AppColors.darkBlueMid
                                : AppColors.blueMid,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          'MIS INSCRIPCIONES',
                          style: AppTextStyles.labelCaps.copyWith(
                            color: isDark
                                ? AppColors.darkBlueMid
                                : AppColors.blueMid,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.2, curve: Curves.easeOutCubic),
                  const SizedBox(height: 12),
                  BlocBuilder<AlumnoBloc, AlumnoState>(
                    builder: (context, state) {
                      final inscripciones =
                          state is AlumnoInscripcionesSuccess
                              ? state.inscripciones
                              : <InscripcionItem>[];
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Mis ',
                                  style: AppTextStyles.displayLarge.copyWith(
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.textPrimary,
                                  ),
                                ),
                                TextSpan(
                                  text: 'exámenes',
                                  style: AppTextStyles.displayItalic.copyWith(
                                    color: isDark
                                        ? AppColors.darkBlueMid
                                        : AppColors.blueMid,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (inscripciones.isNotEmpty)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                            // ── Botón ICS ──
                            GestureDetector(
                              onTap: _exportandoIcs
                                  ? null
                                  : () => _exportarIcs(inscripciones),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.darkBlueLight
                                      : AppColors.blueSurface,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isDark
                                        ? AppColors.darkBlueMid.withOpacity(0.3)
                                        : AppColors.blueLight,
                                  ),
                                ),
                                child: _exportandoIcs
                                    ? SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: isDark
                                              ? AppColors.darkBlueMid
                                              : AppColors.blueMid,
                                        ),
                                      )
                                    : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.calendar_month_outlined,
                                              size: 16,
                                              color: isDark
                                                  ? AppColors.darkBlueMid
                                                  : AppColors.blueMid),
                                          const SizedBox(width: 6),
                                          Text('ICS',
                                              style: AppTextStyles.caption
                                                  .copyWith(
                                                color: isDark
                                                    ? AppColors.darkBlueMid
                                                    : AppColors.blueMid,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                              )),
                                        ],
                                      ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // ── Botón PDF ──
                            GestureDetector(
                              onTap: _exportando
                                  ? null
                                  : () => _exportarPdf(inscripciones),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.darkBlueLight
                                      : AppColors.blueSurface,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isDark
                                        ? AppColors.darkBlueMid
                                            .withOpacity(0.3)
                                        : AppColors.blueLight,
                                  ),
                                ),
                                child: _exportando
                                    ? SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: isDark
                                              ? AppColors.darkBlueMid
                                              : AppColors.blueMid,
                                        ),
                                      )
                                    : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.picture_as_pdf_rounded,
                                            size: 16,
                                            color: isDark
                                                ? AppColors.darkBlueMid
                                                : AppColors.blueMid,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'PDF',
                                            style:
                                                AppTextStyles.caption.copyWith(
                                              color: isDark
                                                  ? AppColors.darkBlueMid
                                                  : AppColors.blueMid,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  );
                    },
                  )
                      .animate()
                      .fadeIn(delay: 100.ms, duration: 500.ms)
                      .slideY(begin: 0.2, curve: Curves.easeOutCubic),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<AlumnoBloc, AlumnoState>(
                builder: (context, state) {
                  if (state is AlumnoInscripcionesLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: isDark
                            ? AppColors.darkBlueMid
                            : AppColors.blueMid,
                        strokeWidth: 2.5,
                      ),
                    );
                  }
                  if (state is AlumnoInscripcionesFailure) {
                    return Center(
                      child: Text(state.message,
                          style: AppTextStyles.bodyMuted.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          )),
                    );
                  }
                  if (state is AlumnoInscripcionesSuccess) {
                    if (state.inscripciones.isEmpty) {
                      return _EmptyState(isDark: isDark);
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      itemCount: state.inscripciones.length,
                      itemBuilder: (ctx, i) {
                        final ins = state.inscripciones[i];
                        return _InscripcionCard(
                          item: ins,
                          index: i,
                          isDark: isDark,
                          onGenerarFicha: () => _generarFichaEts(ins),
                          onSolicitarBaja: ins.estado == _kEstadoConfirmada
                              ? () => ctx.read<AlumnoBloc>().add(
                                    AlumnoSolicitarBajaRequested(
                                      perfil: state.perfil,
                                      idInscripcion: ins.idInscripcion,
                                    ),
                                  )
                              : null,
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
  }
}

class _InscripcionCard extends StatelessWidget {
  final InscripcionItem item;
  final int index;
  final bool isDark;
  final VoidCallback onGenerarFicha;
  final VoidCallback? onSolicitarBaja;

  const _InscripcionCard({
    required this.item,
    required this.index,
    required this.isDark,
    required this.onGenerarFicha,
    this.onSolicitarBaja,
  });

  String _formatDate(DateTime date) {
    const months = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Color _estadoColor(String estado) {
    switch (estado) {
      case _kEstadoConfirmada:
      case _kEstadoAprobado:
        return AppColors.success;
      case _kEstadoReprobado:
      case _kEstadoRechazada:
        return AppColors.error;
      case _kEstadoBajaSolicitada:
        return AppColors.warning;
      case _kEstadoBajaAprobada:
        return AppColors.textMuted;
      case _kEstadoPendiente:
      default:
        return AppColors.warning;
    }
  }

  String _estadoLabel(String estado) {
    switch (estado) {
      case _kEstadoPendiente:
        return 'Pend. confirmación';
      case _kEstadoConfirmada:
        return 'Confirmada';
      case _kEstadoBajaSolicitada:
        return 'Baja solicitada';
      case _kEstadoRechazada:
        return 'Rechazada';
      case _kEstadoBajaAprobada:
        return 'Baja aprobada';
      case _kEstadoAprobado:
        return 'Aprobado';
      case _kEstadoReprobado:
        return 'Reprobado';
      case _kEstadoCalificado:
        return 'Calificado';
      default:
        return 'Pendiente';
    }
  }

  // Progreso desde inicio del mes actual hasta la fecha del ETS.
  double _calcProgress() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = item.fechaInicio;
    if (!end.isAfter(start)) return 1.0;
    final total = end.difference(start).inSeconds;
    final elapsed = now.difference(start).inSeconds;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  Color _barColor(double progress) {
    if (progress >= 1.0) return AppColors.textMuted;
    if (progress >= 0.75) return AppColors.error;
    if (progress >= 0.5) return AppColors.warning;
    return AppColors.success;
  }

  String _diasRestantes() {
    final diff = item.fechaInicio.difference(DateTime.now());
    if (diff.isNegative) return 'Examen aplicado';
    if (diff.inDays == 0) return 'Hoy';
    if (diff.inDays == 1) return 'Mañana';
    return '${diff.inDays} días restantes';
  }

  @override
  Widget build(BuildContext context) {
    final color = _estadoColor(item.estado);
    final progress = _calcProgress();
    final barColor = _barColor(progress);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBgSurface : AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.borderLight,
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: isDark ? AppColors.darkBlueLight : AppColors.blueSurface,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.materia,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkBlueMid : AppColors.blue,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      _estadoLabel(item.estado),
                      style: AppTextStyles.caption.copyWith(
                        color: color,
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Barra de progreso temporal ───────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Inicio del mes',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 10,
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.textMuted,
                        ),
                      ),
                      Text(
                        _diasRestantes(),
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: barColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      height: 6,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: progress),
                        duration: Duration(
                            milliseconds: 600 + (index * 80).clamp(0, 400)),
                        curve: Curves.easeOutCubic,
                        builder: (_, value, __) => LinearProgressIndicator(
                          value: value,
                          backgroundColor: isDark
                              ? AppColors.darkBorder
                              : AppColors.borderLight,
                          valueColor: AlwaysStoppedAnimation<Color>(barColor),
                          minHeight: 6,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Detalles ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _Row(
                      icon: Icons.calendar_today_outlined,
                      label: 'Fecha',
                      value: _formatDate(item.fechaInicio),
                      isDark: isDark),
                  const SizedBox(height: 8),
                  _Row(
                      icon: Icons.access_time_rounded,
                      label: 'Hora',
                      value: item.hora,
                      isDark: isDark),
                  const SizedBox(height: 8),
                  _Row(
                      icon: Icons.room_outlined,
                      label: 'Salón',
                      value: '${item.salon} · Edif. ${item.edificio}',
                      isDark: isDark),
                  const SizedBox(height: 8),
                  _Row(
                      icon: Icons.school_outlined,
                      label: 'Carrera',
                      value: item.carrera,
                      isDark: isDark),
                  if (item.calificacion != null) ...[
                    const SizedBox(height: 8),
                    _Row(
                        icon: Icons.grade_outlined,
                        label: 'Calificación',
                        value: item.calificacion!.toStringAsFixed(1),
                        isDark: isDark),
                  ],
                ],
              ),
            ),

            // ── Acciones ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _CardButton(
                    label: 'Ficha ETS',
                    icon: Icons.download_rounded,
                    onTap: onGenerarFicha,
                    isDark: isDark,
                  ),
                  if (onSolicitarBaja != null) ...[
                    const SizedBox(width: 8),
                    _CardButton(
                      label: 'Solicitar baja',
                      icon: Icons.remove_circle_outline_rounded,
                      onTap: onSolicitarBaja!,
                      isDark: isDark,
                      isDestructive: true,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 60 * index), duration: 400.ms)
        .slideY(begin: 0.1, curve: Curves.easeOutCubic);
  }
}

class _CardButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;
  final bool isDestructive;

  const _CardButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.isDark,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? AppColors.error
        : (isDark ? AppColors.darkBlueMid : AppColors.blueMid);
    final bg = isDestructive
        ? AppColors.error.withValues(alpha: 0.08)
        : (isDark ? AppColors.darkBlueLight : AppColors.blueSurface);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
            Text(label,
                style: AppTextStyles.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                )),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _Row(
      {required this.icon,
      required this.label,
      required this.value,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon,
            size: 16,
            color: isDark ? AppColors.darkBlueMid : AppColors.blueMid),
        const SizedBox(width: 8),
        Text('$label: ',
            style: AppTextStyles.caption.copyWith(
              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
              fontSize: 12,
            )),
        Expanded(
          child: Text(value,
              style: AppTextStyles.caption.copyWith(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBlueLight : AppColors.blueSurface,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.assignment_outlined,
                  color: isDark ? AppColors.darkBlueMid : AppColors.blueMid,
                  size: 32),
            )
                .animate()
                .scale(
                    begin: const Offset(0.7, 0.7),
                    duration: 500.ms,
                    curve: Curves.elasticOut)
                .fadeIn(delay: 200.ms),
            const SizedBox(height: 24),
            Text('Sin inscripciones',
                style: AppTextStyles.displayLarge.copyWith(
                  fontSize: 20,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                )).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 8),
            Text('Busca un examen e inscríbete desde la pestaña de búsqueda.',
                style: AppTextStyles.bodyMuted.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center).animate().fadeIn(delay: 380.ms),
          ],
        ),
      ),
    );
  }
}
