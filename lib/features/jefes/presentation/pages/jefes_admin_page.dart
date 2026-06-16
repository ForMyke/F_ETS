import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:etsAndroid/core/theme/app_colors.dart';
import 'package:etsAndroid/core/theme/app_text_styles.dart';
import 'package:etsAndroid/features/jefes/data/datasources/jefes_admin_datasource.dart';
import 'package:etsAndroid/features/jefes/presentation/bloc/jefes_admin_bloc.dart';

class JefesAdminPage extends StatelessWidget {
  const JefesAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => JefesAdminBloc(
        dataSource: JefesAdminDataSourceImpl(
          client: Supabase.instance.client,
        ),
      )..add(const JefesAdminStarted()),
      child: const _JefesAdminView(),
    );
  }
}

class _JefesAdminView extends StatefulWidget {
  const _JefesAdminView();

  @override
  State<_JefesAdminView> createState() => _JefesAdminViewState();
}

class _JefesAdminViewState extends State<_JefesAdminView> {
  final _searchCtrl = TextEditingController();
  String _query = '';

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
      floatingActionButton: BlocBuilder<JefesAdminBloc, JefesAdminState>(
        builder: (context, state) {
          if (state is! JefesAdminSuccess) return const SizedBox.shrink();
          return FloatingActionButton(
            backgroundColor: isDark ? AppColors.blueMid : AppColors.blue,
            onPressed: () => _showForm(context, state.academias, isDark),
            child: const Icon(Icons.add_rounded, color: Colors.white),
          );
        },
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
                          'GESTIÓN',
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
                          text: 'Jefes de ',
                          style: AppTextStyles.displayLarge.copyWith(
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                          ),
                        ),
                        TextSpan(
                          text: 'academia',
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
                  // Buscador
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBgSurface : AppColors.bgSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.borderLight,
                        width: 1.5,
                      ),
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
                      style: AppTextStyles.body.copyWith(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Buscar por nombre o academia…',
                        hintStyle: AppTextStyles.body.copyWith(
                          color: isDark ? AppColors.darkTextMuted : AppColors.textHint,
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                          size: 20,
                        ),
                        suffixIcon: _query.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  _searchCtrl.clear();
                                  setState(() => _query = '');
                                },
                                child: Icon(
                                  Icons.close_rounded,
                                  color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                                  size: 18,
                                ),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                      ),
                    ),
                  ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            Expanded(
              child: BlocConsumer<JefesAdminBloc, JefesAdminState>(
                listener: (context, state) {
                  if (state is JefesAdminFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.error,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is JefesAdminLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: isDark
                            ? AppColors.darkBlueMid
                            : AppColors.blueMid,
                        strokeWidth: 2.5,
                      ),
                    );
                  }
                  if (state is JefesAdminSuccess) {
                    final filtered = _query.isEmpty
                        ? state.jefes
                        : state.jefes.where((j) {
                            final nombre = j.nombreCompleto.toLowerCase();
                            final academia = (j.nombreAcademia ?? '').toLowerCase();
                            return nombre.contains(_query) || academia.contains(_query);
                          }).toList();
                    if (filtered.isEmpty) {
                      return _EmptyState(isDark: isDark);
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) => _JefeTile(
                        jefe: filtered[i],
                        index: i,
                        isDark: isDark,
                        onDelete: () => _confirmDelete(
                          context,
                          isDark,
                          filtered[i],
                          () => context.read<JefesAdminBloc>().add(
                                JefeAdminDeleted(
                                    idJefe: filtered[i].idJefe),
                              ),
                        ),
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

  void _showForm(
      BuildContext context, List<AcademiaItem> academias, bool isDark) {
    final nombreCtrl = TextEditingController();
    final apPaternoCtrl = TextEditingController();
    final apMaternoCtrl = TextEditingController();
    final correoCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    String? selectedAcademiaId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBgSurface : AppColors.bgPrimary,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.borderLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Nuevo jefe de academia',
                    style: AppTextStyles.displayLarge.copyWith(
                      fontSize: 22,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _Field(label: 'NOMBRE(S)', ctrl: nombreCtrl, isDark: isDark),
                  const SizedBox(height: 16),
                  _Field(
                      label: 'APELLIDO PATERNO',
                      ctrl: apPaternoCtrl,
                      isDark: isDark),
                  const SizedBox(height: 16),
                  _Field(
                      label: 'APELLIDO MATERNO',
                      ctrl: apMaternoCtrl,
                      isDark: isDark),
                  const SizedBox(height: 16),
                  _Field(
                    label: 'CORREO',
                    ctrl: correoCtrl,
                    isDark: isDark,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  _Field(
                    label: 'CONTRASEÑA',
                    ctrl: passwordCtrl,
                    isDark: isDark,
                    obscure: true,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ACADEMIA',
                    style: AppTextStyles.fieldLabel.copyWith(
                      color:
                          isDark ? AppColors.darkBlueMid : AppColors.blueMid,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkBgSurface
                          : AppColors.bgSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.border,
                        width: 1.5,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedAcademiaId,
                        hint: Text(
                          'Selecciona una academia',
                          style: AppTextStyles.body.copyWith(
                            color: isDark
                                ? AppColors.darkTextMuted
                                : AppColors.textHint,
                          ),
                        ),
                        isExpanded: true,
                        dropdownColor: isDark
                            ? AppColors.darkBgSurface
                            : AppColors.bgPrimary,
                        style: AppTextStyles.body.copyWith(
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.textMuted,
                        ),
                        items: academias
                            .map((a) => DropdownMenuItem(
                                  value: a.idAcademia,
                                  child: Text(
                                      '${a.acronimo} — ${a.nombre}'),
                                ))
                            .toList(),
                        onChanged: (val) =>
                            setModalState(() => selectedAcademiaId = val),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: () {
                      if (nombreCtrl.text.isEmpty ||
                          apPaternoCtrl.text.isEmpty ||
                          apMaternoCtrl.text.isEmpty ||
                          correoCtrl.text.isEmpty ||
                          passwordCtrl.text.isEmpty ||
                          selectedAcademiaId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                const Text('Completa todos los campos.'),
                            backgroundColor: AppColors.error,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                        return;
                      }
                      Navigator.of(ctx).pop();
                      context.read<JefesAdminBloc>().add(JefeAdminCreated(
                            nombre: nombreCtrl.text.trim(),
                            apellidoPaterno: apPaternoCtrl.text.trim(),
                            apellidoMaterno: apMaternoCtrl.text.trim(),
                            correo: correoCtrl.text.trim(),
                            password: passwordCtrl.text,
                            idAcademia: selectedAcademiaId!,
                          ));
                    },
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.blueMid : AppColors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Crear jefe',
                          style: AppTextStyles.body.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    bool isDark,
    JefeAdminItem jefe,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor:
            isDark ? AppColors.darkBgSurface : AppColors.bgPrimary,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Eliminar jefe',
          style: AppTextStyles.displayLarge.copyWith(
            fontSize: 18,
            color:
                isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        content: Text(
          '¿Eliminar a ${jefe.nombreCompleto}? Esta acción no se puede deshacer.',
          style: AppTextStyles.bodyMuted.copyWith(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: AppTextStyles.body.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              HapticFeedback.mediumImpact();
              onConfirm();
            },
            child: Text(
              'Eliminar',
              style:
                  AppTextStyles.body.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tile de jefe ──────────────────────────────────────────────────────────────

class _JefeTile extends StatelessWidget {
  final JefeAdminItem jefe;
  final int index;
  final bool isDark;
  final VoidCallback onDelete;

  const _JefeTile({
    required this.jefe,
    required this.index,
    required this.isDark,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBgSurface : AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.borderLight,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBlueLight : AppColors.blueSurface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.supervisor_account_outlined,
              size: 22,
              color: isDark ? AppColors.darkBlueMid : AppColors.blueMid,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  jefe.nombreCompleto,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  jefe.correo,
                  style: AppTextStyles.caption.copyWith(
                    color:
                        isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
                if (jefe.nombreAcademia != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkBlueLight
                          : AppColors.blueSurface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      jefe.nombreAcademia!,
                      style: AppTextStyles.caption.copyWith(
                        color: isDark
                            ? AppColors.darkBlueMid
                            : AppColors.blueMid,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          GestureDetector(
            onTap: onDelete,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.error.withOpacity(0.2)),
              ),
              child: Icon(Icons.delete_outline_rounded,
                  size: 16, color: AppColors.error),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 60 * index), duration: 400.ms)
        .slideY(begin: 0.1, curve: Curves.easeOutCubic);
  }
}

// ── Widgets auxiliares ────────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final bool isDark;
  final bool obscure;
  final TextInputType keyboardType;

  const _Field({
    required this.label,
    required this.ctrl,
    required this.isDark,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.fieldLabel.copyWith(
            color: isDark ? AppColors.darkBlueMid : AppColors.blueMid,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          obscureText: obscure,
          keyboardType: keyboardType,
          style: AppTextStyles.body.copyWith(
            color:
                isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: label.toLowerCase(),
            hintStyle: AppTextStyles.body.copyWith(
              color: isDark ? AppColors.darkTextMuted : AppColors.textHint,
            ),
          ),
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
            child: Icon(Icons.supervisor_account_outlined,
                color: isDark ? AppColors.darkBlueMid : AppColors.blueMid,
                size: 32),
          ),
          const SizedBox(height: 20),
          Text(
            'Sin jefes registrados',
            style: AppTextStyles.displayLarge.copyWith(
              fontSize: 20,
              color:
                  isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega un jefe con el botón +',
            style: AppTextStyles.bodyMuted.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
