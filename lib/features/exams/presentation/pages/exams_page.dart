import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:etsAndroid/core/theme/app_colors.dart';
import 'package:etsAndroid/core/theme/app_text_styles.dart';
import 'package:etsAndroid/features/exams/data/datasources/exams_remote_datasource.dart';
import 'package:etsAndroid/features/exams/presentation/bloc/exams_bloc.dart';
import 'exam_form_page.dart';

class ExamsPage extends StatelessWidget {
  const ExamsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ExamsBloc(
        dataSource: ExamsRemoteDataSourceImpl(
          client: Supabase.instance.client,
        ),
      )..add(const ExamsStarted()),
      child: const _ExamsView(),
    );
  }
}

class _ExamsView extends StatelessWidget {
  const _ExamsView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBgPrimary : AppColors.bgPrimary,
      floatingActionButton: FloatingActionButton(
        backgroundColor: isDark ? AppColors.blueMid : AppColors.blue,
        onPressed: () async {
          final bloc = context.read<ExamsBloc>();
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ExamFormPage(dataSource: ExamsRemoteDataSourceImpl(
                client: Supabase.instance.client,
              )),
            ),
          );
          bloc.add(const ExamsStarted());
        },
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBlueLight : AppColors.blueSurface,
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
                            color: isDark ? AppColors.darkBlueMid : AppColors.blueMid,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          'GESTIÓN',
                          style: AppTextStyles.labelCaps.copyWith(
                            color: isDark ? AppColors.darkBlueMid : AppColors.blueMid,
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
                          text: 'Gestión de ',
                          style: AppTextStyles.displayLarge.copyWith(
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          ),
                        ),
                        TextSpan(
                          text: 'exámenes',
                          style: AppTextStyles.displayItalic.copyWith(
                            color: isDark ? AppColors.darkBlueMid : AppColors.blueMid,
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 100.ms, duration: 500.ms)
                      .slideY(begin: 0.2, curve: Curves.easeOutCubic),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<ExamsBloc, ExamsState>(
                builder: (context, state) {
                  if (state is ExamsLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: isDark ? AppColors.darkBlueMid : AppColors.blueMid,
                        strokeWidth: 2.5,
                      ),
                    );
                  }
                  if (state is ExamsFailure) {
                    return Center(
                      child: Text(
                        state.message,
                        style: AppTextStyles.bodyMuted.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                      ),
                    );
                  }
                  if (state is ExamsSuccess) {
                    if (state.exams.isEmpty) {
                      return Center(
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
                              child: Icon(
                                Icons.assignment_outlined,
                                color: isDark ? AppColors.darkBlueMid : AppColors.blueMid,
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Sin exámenes',
                              style: AppTextStyles.displayLarge.copyWith(
                                fontSize: 20,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Agrega un examen con el botón +',
                              style: AppTextStyles.bodyMuted.copyWith(
                                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                      itemCount: state.exams.length,
                      itemBuilder: (_, i) => _ExamTile(
                        exam: state.exams[i],
                        isDark: isDark,
                        index: i,
                        onEdit: () async {
                          final bloc = context.read<ExamsBloc>();
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ExamFormPage(
                                dataSource: ExamsRemoteDataSourceImpl(
                                  client: Supabase.instance.client,
                                ),
                                exam: state.exams[i],
                              ),
                            ),
                          );
                          bloc.add(const ExamsStarted());
                        },
                        onDelete: () => _confirmDelete(context, state.exams[i].id),
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

  void _confirmDelete(BuildContext context, String id) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkBgSurface : AppColors.bgPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Eliminar examen',
          style: AppTextStyles.displayLarge.copyWith(
            fontSize: 18,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        content: Text(
          '¿Estás seguro? Esta acción no se puede deshacer.',
          style: AppTextStyles.bodyMuted.copyWith(
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: AppTextStyles.body.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              HapticFeedback.mediumImpact();
              context.read<ExamsBloc>().add(ExamDeleted(id: id));
            },
            child: Text(
              'Eliminar',
              style: AppTextStyles.body.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExamTile extends StatelessWidget {
  final ExamListItem exam;
  final bool isDark;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ExamTile({
    required this.exam,
    required this.isDark,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  String _formatDate(DateTime date) {
    const months = ['ene','feb','mar','abr','may','jun','jul','ago','sep','oct','nov','dic'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: isDark ? AppColors.darkBlueLight : AppColors.blueSurface,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      exam.materia,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkBlueMid : AppColors.blue,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBlueMid.withOpacity(0.2) : AppColors.blueGlow,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? AppColors.darkBlueMid.withOpacity(0.3) : AppColors.blueLight,
                      ),
                    ),
                    child: Text(
                      exam.turno,
                      style: AppTextStyles.caption.copyWith(
                        color: isDark ? AppColors.darkBlueMid : AppColors.blueMid,
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
                  _Row(icon: Icons.calendar_today_outlined, label: 'Fecha', value: _formatDate(exam.fechaInicio), isDark: isDark),
                  const SizedBox(height: 8),
                  _Row(icon: Icons.access_time_rounded, label: 'Hora', value: '${exam.fechaInicio.hour.toString().padLeft(2,'0')}:${exam.fechaInicio.minute.toString().padLeft(2,'0')}', isDark: isDark),
                  const SizedBox(height: 8),
                  _Row(icon: Icons.room_outlined, label: 'Salón', value: '${exam.salon} · Edif. ${exam.edificio}', isDark: isDark),
                  const SizedBox(height: 8),
                  _Row(icon: Icons.school_outlined, label: 'Carrera', value: exam.carrera, isDark: isDark),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: onEdit,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkBgOverlay : AppColors.bgSurface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark ? AppColors.darkBorder : AppColors.borderLight,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 14,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                              const SizedBox(width: 6),
                              Text('Editar',
                                  style: AppTextStyles.caption.copyWith(
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                  )),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: onDelete,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.error.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline_rounded, size: 14, color: AppColors.error),
                              const SizedBox(width: 6),
                              Text('Eliminar',
                                  style: AppTextStyles.caption.copyWith(color: AppColors.error)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
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

  const _Row({required this.icon, required this.label, required this.value, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: isDark ? AppColors.darkBlueMid : AppColors.blueMid),
        const SizedBox(width: 8),
        Text('$label: ', style: AppTextStyles.caption.copyWith(
          color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
          fontSize: 12,
        )),
        Expanded(
          child: Text(value, style: AppTextStyles.caption.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ), overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}