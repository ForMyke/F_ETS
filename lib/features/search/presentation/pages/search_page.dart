import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/datasources/search_local_datasource.dart';
import '../../data/repositories/search_repository_impl.dart';
import '../../domain/usecases/get_exams_usecase.dart';
import '../bloc/search_bloc.dart';
import '../widgets/exam_card.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/pdf_export_button.dart';
import '../../../favorites/presentation/bloc/favorites_bloc.dart';
import 'package:flutter/services.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SearchBloc(
        getExamsUseCase: GetExamsUseCase(
          SearchRepositoryImpl(
            localDataSource: SearchLocalDataSourceImpl(),
          ),
        ),
      )..add(const SearchStarted()),
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  final _searchController = TextEditingController();
  final List<String> _carreras = ['ISC', 'LCD', 'IIA'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    final state = context.read<SearchBloc>().state;
    context.read<SearchBloc>().add(SearchFiltersChanged(
          carrera: state.carrera,
          semestre: state.semestre,
          plan: state.plan,
          materia: value.isEmpty ? null : value,
        ));
  }

  void _openFilters(BuildContext context, SearchState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterSheet(
        carreras: _carreras,
        selectedCarrera: state.carrera,
        selectedSemestre: state.semestre,
        selectedPlan: state.plan,
        onApply: (carrera, semestre, plan) {
          context.read<SearchBloc>().add(SearchFiltersChanged(
                carrera: carrera,
                semestre: semestre,
                plan: plan,
                materia: state.materia,
              ));
        },
      ),
    );
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
                  // Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                        Text('ESCOM · IPN',
                            style: AppTextStyles.labelCaps.copyWith(
                              color: isDark
                                  ? AppColors.darkBlueMid
                                  : AppColors.blueMid,
                              fontSize: 10,
                            )),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.2, curve: Curves.easeOutCubic),
                  const SizedBox(height: 12),

                  // Título
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Consulta tu ',
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
                  const SizedBox(height: 6),
                  Text(
                    'Encuentra tu examen a título de suficiencia',
                    style: AppTextStyles.bodyMuted.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 160.ms, duration: 500.ms)
                      .slideY(begin: 0.2, curve: Curves.easeOutCubic),
                  const SizedBox(height: 20),

                  // Barra búsqueda + filtro
                  BlocBuilder<SearchBloc, SearchState>(
                    builder: (context, state) {
                      final hasFilters = state.carrera != null ||
                          state.semestre != null ||
                          state.plan != null;
                      return Row(
                        children: [
                          Expanded(
                            child: Container(
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
                                      controller: _searchController,
                                      onChanged: _onSearchChanged,
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
                                  if (_searchController.text.isNotEmpty)
                                    GestureDetector(
                                      onTap: () {
                                        _searchController.clear();
                                        _onSearchChanged('');
                                      },
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 10),
                                        child: Icon(Icons.close_rounded,
                                            size: 18,
                                            color: isDark
                                                ? AppColors.darkTextMuted
                                                : AppColors.textMuted),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () => _openFilters(context, state),
                            child: AnimatedContainer(
                              duration: 200.ms,
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: hasFilters
                                    ? (isDark
                                        ? AppColors.blueMid
                                        : AppColors.blue)
                                    : (isDark
                                        ? AppColors.darkBgSurface
                                        : AppColors.bgSurface),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: hasFilters
                                      ? Colors.transparent
                                      : (isDark
                                          ? AppColors.darkBorder
                                          : AppColors.borderLight),
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(Icons.tune_rounded,
                                  size: 20,
                                  color: hasFilters
                                      ? Colors.white
                                      : (isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.textSecondary)),
                            ),
                          ),
                        ],
                      );
                    },
                  )
                      .animate()
                      .fadeIn(delay: 220.ms, duration: 500.ms)
                      .slideY(begin: 0.2, curve: Curves.easeOutCubic),

                  // Chips de filtros activos
                  BlocBuilder<SearchBloc, SearchState>(
                    builder: (context, state) {
                      final chips = <Widget>[];

                      if (state.carrera != null) {
                        chips.add(_ActiveChip(
                          label: state.carrera!,
                          isDark: isDark,
                          onRemove: () => context.read<SearchBloc>().add(
                                SearchFiltersChanged(
                                  semestre: state.semestre,
                                  plan: state.plan,
                                  materia: state.materia,
                                ),
                              ),
                        ));
                      }
                      if (state.plan != null) {
                        chips.add(_ActiveChip(
                          label: 'Plan ${state.plan}',
                          isDark: isDark,
                          onRemove: () => context.read<SearchBloc>().add(
                                SearchFiltersChanged(
                                  carrera: state.carrera,
                                  semestre: state.semestre,
                                  materia: state.materia,
                                ),
                              ),
                        ));
                      }
                      if (state.semestre != null) {
                        chips.add(_ActiveChip(
                          label: 'Sem. ${state.semestre}',
                          isDark: isDark,
                          onRemove: () => context.read<SearchBloc>().add(
                                SearchFiltersChanged(
                                  carrera: state.carrera,
                                  plan: state.plan,
                                  materia: state.materia,
                                ),
                              ),
                        ));
                      }

                      if (chips.isEmpty) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Wrap(spacing: 8, runSpacing: 8, children: chips),
                      );
                    },
                  ),

                  // Contador + botón exportar PDF
                  BlocBuilder<SearchBloc, SearchState>(
                    builder: (context, state) {
                      if (state is! SearchSuccess || state.exams.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${state.exams.length} examen${state.exams.length != 1 ? 'es' : ''} encontrado${state.exams.length != 1 ? 's' : ''}',
                              style: AppTextStyles.caption.copyWith(
                                color: isDark
                                    ? AppColors.darkTextMuted
                                    : AppColors.textMuted,
                              ),
                            ),
                            PdfExportButton(
                              exams: state.exams,
                              carrera: state.carrera,
                              semestre: state.semestre,
                              plan: state.plan,
                              isDark: isDark,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Resultados
            Expanded(
              child: BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  if (state is SearchLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        color:
                            isDark ? AppColors.darkBlueMid : AppColors.blueMid,
                        strokeWidth: 2.5,
                      ),
                    );
                  }
                  if (state is SearchFailure) {
                    return _ErrorState(message: state.message, isDark: isDark);
                  }
                  if (state is SearchSuccess) {
                    if (state.exams.isEmpty) return _EmptyState(isDark: isDark);
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      itemCount: state.exams.length,
                      itemBuilder: (_, i) {
                        final exam = state.exams[i];
                        final favState = context.watch<FavoritesBloc>().state;
                        final isFav = favState is FavoritesSuccess
                            ? favState.exams.any((e) => e.id == exam.id)
                            : false;

                        return ExamCard(
                          exam: exam,
                          index: i,
                          isDark: isDark,
                          isFavorite: isFav,
                          onFavoriteTap: () {
                            HapticFeedback.lightImpact();
                            if (isFav) {
                              context
                                  .read<FavoritesBloc>()
                                  .add(FavoriteRemoved(examId: exam.id));
                            } else {
                              context
                                  .read<FavoritesBloc>()
                                  .add(FavoriteAdded(exam: exam));
                            }
                          },
                        );
                      },
                    );
                  }
                  return _InitialState(isDark: isDark);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveChip extends StatelessWidget {
  final String label;
  final bool isDark;
  final VoidCallback onRemove;

  const _ActiveChip(
      {required this.label, required this.isDark, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkBlueMid.withOpacity(0.15)
            : AppColors.blueSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppColors.darkBlueMid.withOpacity(0.3)
              : AppColors.blueLight,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: AppTextStyles.caption.copyWith(
                color: isDark ? AppColors.darkBlueMid : AppColors.blueMid,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              )),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close_rounded,
                size: 14,
                color: isDark ? AppColors.darkBlueMid : AppColors.blueMid),
          ),
        ],
      ),
    );
  }
}

class _InitialState extends StatelessWidget {
  final bool isDark;
  const _InitialState({required this.isDark});

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
              child: Icon(Icons.search_rounded,
                  color: isDark ? AppColors.darkBlueMid : AppColors.blueMid,
                  size: 32),
            )
                .animate()
                .scale(
                    begin: const Offset(0.7, 0.7),
                    duration: 500.ms,
                    curve: Curves.elasticOut)
                .fadeIn(delay: 200.ms),
            const SizedBox(height: 20),
            Text('Busca tu examen',
                style: AppTextStyles.displayLarge.copyWith(
                  fontSize: 20,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                )).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 8),
            Text('Usa los filtros o escribe el nombre de la materia.',
                    style: AppTextStyles.bodyMuted.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center)
                .animate()
                .fadeIn(delay: 380.ms),
          ],
        ),
      ),
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
            ),
            const SizedBox(height: 20),
            Text('Sin resultados',
                style: AppTextStyles.displayLarge.copyWith(
                  fontSize: 20,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                )),
            const SizedBox(height: 8),
            Text('No encontramos exámenes con esos filtros. Intenta con otros.',
                style: AppTextStyles.bodyMuted.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final bool isDark;
  const _ErrorState({required this.message, required this.isDark});

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
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded,
                  color: AppColors.error, size: 32),
            ),
            const SizedBox(height: 20),
            Text('Algo salió mal',
                style: AppTextStyles.displayLarge.copyWith(
                  fontSize: 20,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                )),
            const SizedBox(height: 8),
            Text(message,
                style: AppTextStyles.bodyMuted.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
