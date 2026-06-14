import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import 'package:etsAndroid/features/alumno/domain/entities/alumno_profile.dart';
import 'package:etsAndroid/features/alumno/presentation/bloc/alumno_bloc.dart';
import 'alumno_ets_detail_page.dart';

class AlumnoExamsPage extends StatefulWidget {
  final AlumnoProfile perfil;

  const AlumnoExamsPage({super.key, required this.perfil});

  @override
  State<AlumnoExamsPage> createState() => _AlumnoExamsPageState();
}

class _AlumnoExamsPageState extends State<AlumnoExamsPage> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    context
        .read<AlumnoBloc>()
        .add(AlumnoExamsLoaded(perfil: widget.perfil));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
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
                          'ALUMNO · ESCOM',
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
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Busca tu ',
                          style: AppTextStyles.displayLarge.copyWith(
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                          ),
                        ),
                        TextSpan(
                          text: 'ETS',
                          style: AppTextStyles.displayItalic.copyWith(
                            color: isDark
                                ? AppColors.darkBlueMid
                                : AppColors.blueMid,
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 100.ms, duration: 500.ms)
                      .slideY(begin: 0.2, curve: Curves.easeOutCubic),
                  const SizedBox(height: 16),
                  // Barra de búsqueda
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkBgSurface
                          : AppColors.bgSurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.borderLight,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 14),
                        Icon(Icons.search_rounded,
                            color: isDark
                                ? AppColors.darkBlueMid
                                : AppColors.blueMid,
                            size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            onChanged: (v) =>
                                setState(() => _query = v.toLowerCase()),
                            style: AppTextStyles.body.copyWith(
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Buscar materia...',
                              hintStyle: AppTextStyles.body.copyWith(
                                color: isDark
                                    ? AppColors.darkTextMuted
                                    : AppColors.textHint,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        if (_query.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchCtrl.clear();
                              setState(() => _query = '');
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Icon(Icons.close_rounded,
                                  size: 18,
                                  color: isDark
                                      ? AppColors.darkTextMuted
                                      : AppColors.textMuted),
                            ),
                          ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 180.ms, duration: 500.ms)
                      .slideY(begin: 0.2, curve: Curves.easeOutCubic),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<AlumnoBloc, AlumnoState>(
                builder: (context, state) {
                  if (state is AlumnoExamsLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: isDark
                            ? AppColors.darkBlueMid
                            : AppColors.blueMid,
                        strokeWidth: 2.5,
                      ),
                    );
                  }
                  if (state is AlumnoExamsFailure) {
                    return Center(
                      child: Text(state.message,
                          style: AppTextStyles.bodyMuted.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          )),
                    );
                  }
                  if (state is AlumnoExamsSuccess) {
                    final filtered = _query.isEmpty
                        ? state.exams
                        : state.exams
                            .where((e) =>
                                e.materia.toLowerCase().contains(_query) ||
                                e.carrera.toLowerCase().contains(_query))
                            .toList();

                    if (filtered.isEmpty) {
                      return Center(
                        child: Text(
                          'Sin resultados',
                          style: AppTextStyles.bodyMuted.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) => _AlumnoExamCard(
                        exam: filtered[i],
                        index: i,
                        isDark: isDark,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: context.read<AlumnoBloc>(),
                                child: AlumnoEtsDetailPage(
                                  exam: filtered[i],
                                  perfil: widget.perfil,
                                ),
                              ),
                            ),
                          );
                        },
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

class _AlumnoExamCard extends StatelessWidget {
  final dynamic exam;
  final int index;
  final bool isDark;
  final VoidCallback onTap;

  const _AlumnoExamCard({
    required this.exam,
    required this.index,
    required this.isDark,
    required this.onTap,
  });

  String _formatDate(DateTime date) {
    const months = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                        exam.materia,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                          color:
                              isDark ? AppColors.darkBlueMid : AppColors.blue,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkBlueMid.withOpacity(0.2)
                            : AppColors.blueGlow,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBlueMid.withOpacity(0.3)
                              : AppColors.blueLight,
                        ),
                      ),
                      child: Text(
                        exam.turno,
                        style: AppTextStyles.caption.copyWith(
                          color: isDark
                              ? AppColors.darkBlueMid
                              : AppColors.blueMid,
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color:
                          isDark ? AppColors.darkBlueMid : AppColors.blueMid,
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
                        value: _formatDate(exam.fechaInicio),
                        isDark: isDark),
                    const SizedBox(height: 8),
                    _Row(
                        icon: Icons.access_time_rounded,
                        label: 'Hora',
                        value: exam.hora,
                        isDark: isDark),
                    const SizedBox(height: 8),
                    _Row(
                        icon: Icons.room_outlined,
                        label: 'Salón',
                        value: '${exam.salon} · Edif. ${exam.edificio}',
                        isDark: isDark),
                    const SizedBox(height: 8),
                    _Row(
                        icon: Icons.school_outlined,
                        label: 'Carrera',
                        value: exam.carrera,
                        isDark: isDark),
                  ],
                ),
              ),
            ],
          ),
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
                color:
                    isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
