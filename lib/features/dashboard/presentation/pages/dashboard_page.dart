import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/datasources/dashboard_remote_datasource.dart';
import '../bloc/dashboard_bloc.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DashboardBloc(
        dataSource: DashboardRemoteDataSourceImpl(
          client: Supabase.instance.client,
        ),
      )..add(const DashboardStarted()),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBgPrimary : AppColors.bgPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
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
                      'PANEL ADMIN',
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
                      text: 'Dashboard ',
                      style: AppTextStyles.displayLarge.copyWith(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                    TextSpan(
                      text: 'estadísticas',
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
              const SizedBox(height: 24),

              // Contenido
              Expanded(
                child: BlocBuilder<DashboardBloc, DashboardState>(
                  builder: (context, state) {
                    if (state is DashboardLoading) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: isDark ? AppColors.darkBlueMid : AppColors.blueMid,
                          strokeWidth: 2.5,
                        ),
                      );
                    }
                    if (state is DashboardFailure) {
                      return Center(
                        child: Text(
                          state.message,
                          style: AppTextStyles.bodyMuted.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          ),
                        ),
                      );
                    }
                    if (state is DashboardSuccess) {
                      return _DashboardContent(stats: state.stats, isDark: isDark);
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

class _DashboardContent extends StatelessWidget {
  final DashboardStats stats;
  final bool isDark;

  const _DashboardContent({required this.stats, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final maxCount = stats.examsByCarrera.values.isEmpty
        ? 1
        : stats.examsByCarrera.values.reduce((a, b) => a > b ? a : b);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero number
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBgSurface : AppColors.bgSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.borderLight,
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Text(
                  '${stats.totalExams}',
                  style: AppTextStyles.displayLarge.copyWith(
                    fontSize: 64,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkBlueMid : AppColors.blueMid,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 500.ms)
                    .slideY(begin: 0.2, curve: Curves.easeOutCubic),
                const SizedBox(height: 4),
                Text(
                  'exámenes activos',
                  style: AppTextStyles.bodyMuted.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                const SizedBox(height: 4),
                Text(
                  stats.periodoNombre,
                  style: AppTextStyles.labelCaps.copyWith(
                    color: isDark ? AppColors.darkBlueMid : AppColors.blueMid,
                    fontSize: 10,
                  ),
                ).animate().fadeIn(delay: 380.ms, duration: 400.ms),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: 150.ms, duration: 500.ms)
              .slideY(begin: 0.1, curve: Curves.easeOutCubic),

          const SizedBox(height: 16),
          _MiniCards(stats: stats, isDark: isDark),

          const SizedBox(height: 24),

          Text(
            'POR CARRERA',
            style: AppTextStyles.fieldLabel.copyWith(
              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
            ),
          ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

          const SizedBox(height: 12),

          // Tarjetas por carrera
          ...stats.examsByCarrera.entries.toList().asMap().entries.map((entry) {
            final i = entry.key;
            final carrera = entry.value.key;
            final count = entry.value.value;
            final ratio = count / maxCount;

            return _CarreraCard(
              carrera: carrera,
              count: count,
              ratio: ratio,
              isDark: isDark,
              delay: 450 + (i * 80),
            );
          }),
        ],
      ),
    );
  }
}

class _CarreraCard extends StatefulWidget {
  final String carrera;
  final int count;
  final double ratio;
  final bool isDark;
  final int delay;

  const _CarreraCard({
    required this.carrera,
    required this.count,
    required this.ratio,
    required this.isDark,
    required this.delay,
  });

  @override
  State<_CarreraCard> createState() => _CarreraCardState();
}

class _CarreraCardState extends State<_CarreraCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.darkBgSurface : AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isDark ? AppColors.darkBorder : AppColors.borderLight,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.carrera,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: widget.isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
              Text(
                '${widget.count} examen${widget.count != 1 ? 'es' : ''}',
                style: AppTextStyles.caption.copyWith(
                  color: widget.isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 6,
              color: widget.isDark ? AppColors.darkBorder : AppColors.borderLight,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (_, __) => FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _animation.value * widget.ratio,
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.isDark ? AppColors.darkBlueMid : AppColors.blueMid,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: widget.delay), duration: 400.ms)
        .slideY(begin: 0.1, curve: Curves.easeOutCubic);
  }
}

class _MiniCards extends StatelessWidget {
  final DashboardStats stats;
  final bool isDark;

  const _MiniCards({required this.stats, required this.isDark});

  String _formatDate(DateTime date) {
    const months = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBgSurface : AppColors.bgPrimary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.borderLight,
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBlueLight : AppColors.blueSurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: isDark ? AppColors.darkBlueMid : AppColors.blueMid,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Próximo examen',
                  style: AppTextStyles.caption.copyWith(
                    color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stats.proximoExamen != null
                      ? _formatDate(stats.proximoExamen!)
                      : 'Sin fecha',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBgSurface : AppColors.bgPrimary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.borderLight,
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBlueLight : AppColors.blueSurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.door_front_door_outlined,
                    size: 16,
                    color: isDark ? AppColors.darkBlueMid : AppColors.blueMid,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Salones en uso',
                  style: AppTextStyles.caption.copyWith(
                    color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${stats.salonesEnUso}',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 350.ms, duration: 400.ms)
        .slideY(begin: 0.1, curve: Curves.easeOutCubic);
  }
}