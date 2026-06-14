import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import 'package:etsAndroid/features/alumno/domain/entities/alumno_profile.dart';
import 'package:etsAndroid/features/alumno/domain/entities/inscripcion_item.dart';
import 'package:etsAndroid/features/alumno/presentation/bloc/alumno_bloc.dart';

// Estado string constants (match DB values)
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
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
                      itemBuilder: (_, i) => _InscripcionCard(
                        item: state.inscripciones[i],
                        index: i,
                        isDark: isDark,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InscripcionCard extends StatelessWidget {
  final InscripcionItem item;
  final int index;
  final bool isDark;

  const _InscripcionCard({
    required this.item,
    required this.index,
    required this.isDark,
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
      case _kEstadoAprobado:
        return AppColors.success;
      case _kEstadoReprobado:
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  String _estadoLabel(String estado) {
    switch (estado) {
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

  @override
  Widget build(BuildContext context) {
    final color = _estadoColor(item.estado);

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
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color.withOpacity(0.3)),
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
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 60 * index), duration: 400.ms)
        .slideY(begin: 0.1, curve: Curves.easeOutCubic);
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
