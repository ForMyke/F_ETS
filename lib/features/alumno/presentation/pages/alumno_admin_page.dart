import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:etsAndroid/core/theme/app_colors.dart';
import 'package:etsAndroid/core/theme/app_text_styles.dart';
import 'package:etsAndroid/core/util/form_validators.dart';
import 'package:etsAndroid/features/alumno/data/datasources/alumno_admin_datasource.dart';
import 'package:etsAndroid/features/alumno/presentation/bloc/alumno_admin_bloc.dart';
import 'package:etsAndroid/features/alumno/data/datasources/alumno_remote_datasource.dart';

class AlumnosAdminPage extends StatelessWidget {
  const AlumnosAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AlumnosAdminBloc(
        dataSource: AlumnosAdminDataSourceImpl(
          client: Supabase.instance.client,
        ),
        catalogosDataSource: AlumnoRemoteDataSourceImpl(
          client: Supabase.instance.client,
        ),
      )..add(const AlumnoAdminStarted()),
      child: const _AlumnosAdminView(),
    );
  }
}

class _AlumnosAdminView extends StatefulWidget {
  const _AlumnosAdminView();

  @override
  State<_AlumnosAdminView> createState() => _AlumnosAdminViewState();
}

class _AlumnosAdminViewState extends State<_AlumnosAdminView> {
  final _searchCtrl = TextEditingController();

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
      floatingActionButton: BlocBuilder<AlumnosAdminBloc, AlumnoAdminState>(
        builder: (context, state) {
          if (state is! AlumnoAdminSuccess) return const SizedBox.shrink();
          return FloatingActionButton(
            backgroundColor: isDark ? AppColors.blueMid : AppColors.blue,
            onPressed: () => _showForm(context, state, isDark),
            child: const Icon(Icons.person_add_rounded, color: Colors.white),
          );
        },
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                          text: 'Alumnos ',
                          style: AppTextStyles.displayLarge.copyWith(
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                          ),
                        ),
                        TextSpan(
                          text: 'registrados',
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

                  // ── Buscador ─────────────────────────────────────
                  BlocBuilder<AlumnosAdminBloc, AlumnoAdminState>(
                    builder: (context, state) {
                      if (state is! AlumnoAdminSuccess) {
                        return const SizedBox.shrink();
                      }
                      return Container(
                        height: 48,
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
                                size: 20,
                                color: isDark
                                    ? AppColors.darkBlueMid
                                    : AppColors.blueMid),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _searchCtrl,
                                onChanged: (v) =>
                                    context.read<AlumnosAdminBloc>().add(
                                          AlumnoAdminSearchChanged(query: v),
                                        ),
                                style: AppTextStyles.body.copyWith(
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  hintText:
                                      'Buscar por nombre, boleta o correo…',
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
                            if (_searchCtrl.text.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  _searchCtrl.clear();
                                  context.read<AlumnosAdminBloc>().add(
                                        const AlumnoAdminSearchChanged(
                                            query: ''),
                                      );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 12),
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
                          .fadeIn(delay: 180.ms, duration: 400.ms)
                          .slideY(begin: 0.1, curve: Curves.easeOutCubic);
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // ── Lista ────────────────────────────────────────────────
            Expanded(
              child: BlocConsumer<AlumnosAdminBloc, AlumnoAdminState>(
                listener: (context, state) {
                  if (state is AlumnoAdminFailure) {
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
                  if (state is AlumnoAdminLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        color:
                            isDark ? AppColors.darkBlueMid : AppColors.blueMid,
                        strokeWidth: 2.5,
                      ),
                    );
                  }
                  if (state is AlumnoAdminSuccess) {
                    final items = state.filtered;

                    if (state.alumnos.isEmpty) {
                      return _EmptyState(isDark: isDark);
                    }
                    if (items.isEmpty) {
                      return _NoResultsState(isDark: isDark);
                    }

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                          child: Row(
                            children: [
                              Text(
                                '${items.length} alumno${items.length != 1 ? 's' : ''}',
                                style: AppTextStyles.caption.copyWith(
                                  color: isDark
                                      ? AppColors.darkTextMuted
                                      : AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                            itemCount: items.length,
                            itemBuilder: (_, i) => _AlumnoTile(
                              alumno: items[i],
                              index: i,
                              isDark: isDark,
                              onToggleActivo: () {
                                context.read<AlumnosAdminBloc>().add(
                                      AlumnoAdminToggleActivo(
                                        idAlumno: items[i].idAlumno,
                                        activo: !items[i].activo,
                                      ),
                                    );
                              },
                              onDelete: () => _confirmDelete(
                                context,
                                isDark,
                                items[i].nombreCompleto,
                                () => context.read<AlumnosAdminBloc>().add(
                                      AlumnoAdminDeleted(
                                          idAlumno: items[i].idAlumno),
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ],
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

  // ── Formulario nuevo alumno ──────────────────────────────────────────────

  void _showForm(BuildContext context, AlumnoAdminSuccess state, bool isDark) {
    final formKey = GlobalKey<FormState>();
    final nombreCtrl = TextEditingController();
    final apPaternoCtrl = TextEditingController();
    final apMaternoCtrl = TextEditingController();
    final correoCtrl = TextEditingController();
    final boletaCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    bool obscure = true;
    String? selectedCarreraId;
    String? selectedPlanId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBgSurface : AppColors.bgPrimary,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle
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
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Nuevo ',
                            style: AppTextStyles.displayLarge.copyWith(
                              fontSize: 22,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          TextSpan(
                            text: 'alumno',
                            style: AppTextStyles.displayItalic.copyWith(
                              fontSize: 22,
                              color: isDark
                                  ? AppColors.darkBlueMid
                                  : AppColors.blueMid,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    _FormField(
                      label: 'NOMBRE(S)',
                      controller: nombreCtrl,
                      isDark: isDark,
                      validator: (v) =>
                          FormValidators.nombre(v, campo: 'Nombre'),
                    ),
                    const SizedBox(height: 14),
                    _FormField(
                      label: 'APELLIDO PATERNO',
                      controller: apPaternoCtrl,
                      isDark: isDark,
                      validator: (v) =>
                          FormValidators.nombre(v, campo: 'Apellido paterno'),
                    ),
                    const SizedBox(height: 14),
                    _FormField(
                      label: 'APELLIDO MATERNO',
                      controller: apMaternoCtrl,
                      isDark: isDark,
                      validator: (v) =>
                          FormValidators.nombre(v, campo: 'Apellido materno'),
                    ),
                    const SizedBox(height: 14),
                    _FormField(
                      label: 'BOLETA',
                      controller: boletaCtrl,
                      isDark: isDark,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      validator: FormValidators.boleta,
                    ),
                    const SizedBox(height: 14),
                    _FormField(
                      label: 'CORREO INSTITUCIONAL',
                      controller: correoCtrl,
                      isDark: isDark,
                      hint: 'alumno@alumno.ipn.mx',
                      keyboardType: TextInputType.emailAddress,
                      validator: FormValidators.correoAlumno,
                    ),
                    const SizedBox(height: 14),
                    _FormField(
                      label: 'CONTRASEÑA INICIAL',
                      controller: passwordCtrl,
                      isDark: isDark,
                      obscure: obscure,
                      validator: FormValidators.password,
                      suffix: GestureDetector(
                        onTap: () => setSheet(() => obscure = !obscure),
                        child: Icon(
                          obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 18,
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ── Carrera ──────────────────────────────────────
                    Text(
                      'CARRERA',
                      style: AppTextStyles.fieldLabel.copyWith(
                        color:
                            isDark ? AppColors.darkBlueMid : AppColors.blueMid,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _DropdownField(
                      hint: 'Selecciona una carrera',
                      value: selectedCarreraId,
                      isDark: isDark,
                      items: state.carreras
                          .map((c) => DropdownMenuItem(
                                value: c['id_carrera'] as String,
                                child:
                                    Text('${c['acronimo']} — ${c['nombre']}'),
                              ))
                          .toList(),
                      onChanged: (val) =>
                          setSheet(() => selectedCarreraId = val),
                      validator: (v) =>
                          v == null ? 'Selecciona una carrera' : null,
                    ),
                    const SizedBox(height: 14),

                    // ── Plan ─────────────────────────────────────────
                    Text(
                      'PLAN DE ESTUDIOS',
                      style: AppTextStyles.fieldLabel.copyWith(
                        color:
                            isDark ? AppColors.darkBlueMid : AppColors.blueMid,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _DropdownField(
                      hint: 'Selecciona un plan',
                      value: selectedPlanId,
                      isDark: isDark,
                      items: state.planes
                          .map((p) => DropdownMenuItem(
                                value: p['id_plan'] as String,
                                child: Text(p['nombre'] as String),
                              ))
                          .toList(),
                      onChanged: (val) => setSheet(() => selectedPlanId = val),
                      validator: (v) => v == null ? 'Selecciona un plan' : null,
                    ),

                    const SizedBox(height: 10),
                    Text(
                      'El alumno podrá cambiar su contraseña después del primer inicio de sesión.',
                      style: AppTextStyles.caption.copyWith(
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 28),

                    GestureDetector(
                      onTap: () {
                        if (!(formKey.currentState?.validate() ?? false)) {
                          HapticFeedback.mediumImpact();
                          return;
                        }
                        if (selectedCarreraId == null ||
                            selectedPlanId == null) {
                          HapticFeedback.mediumImpact();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                  'Selecciona carrera y plan de estudios.'),
                              backgroundColor: AppColors.error,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                          return;
                        }
                        Navigator.of(ctx).pop();
                        context.read<AlumnosAdminBloc>().add(
                              AlumnoAdminCreated(
                                nombre: nombreCtrl.text.trim(),
                                apellidoPaterno: apPaternoCtrl.text.trim(),
                                apellidoMaterno: apMaternoCtrl.text.trim(),
                                correo: correoCtrl.text.trim(),
                                boleta: boletaCtrl.text.trim(),
                                password: passwordCtrl.text,
                                idCarrera: selectedCarreraId!,
                                idPlan: selectedPlanId!,
                              ),
                            );
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
                            'Registrar alumno',
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
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    bool isDark,
    String nombre,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkBgSurface : AppColors.bgPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Eliminar alumno',
          style: AppTextStyles.displayLarge.copyWith(
            fontSize: 18,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        content: Text(
          '¿Eliminar a $nombre? Esta acción no se puede deshacer.',
          style: AppTextStyles.bodyMuted.copyWith(
            color:
                isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
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
              style: AppTextStyles.body.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TILE
// ═══════════════════════════════════════════════════════════════════════════════

class _AlumnoTile extends StatelessWidget {
  final AlumnoAdminItem alumno;
  final int index;
  final bool isDark;
  final VoidCallback onToggleActivo;
  final VoidCallback onDelete;

  const _AlumnoTile({
    required this.alumno,
    required this.index,
    required this.isDark,
    required this.onToggleActivo,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final activoColor = alumno.activo ? AppColors.success : AppColors.textMuted;

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
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: isDark ? AppColors.darkBlueLight : AppColors.blueSurface,
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkBlueMid.withOpacity(0.2)
                          : AppColors.blueGlow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        alumno.nombre.isNotEmpty
                            ? alumno.nombre[0].toUpperCase()
                            : '?',
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkBlueMid
                              : AppColors.blueMid,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      alumno.nombreCompleto,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkBlueMid : AppColors.blue,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: activoColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: activoColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      alumno.activo ? 'Activo' : 'Inactivo',
                      style: AppTextStyles.caption.copyWith(
                        color: activoColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                children: [
                  _DetailRow(
                    icon: Icons.badge_outlined,
                    label: 'Boleta',
                    value: alumno.boleta,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 6),
                  _DetailRow(
                    icon: Icons.mail_outline_rounded,
                    label: 'Correo',
                    value: alumno.correo,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),

                  // Acciones
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Toggle activo
                      GestureDetector(
                        onTap: onToggleActivo,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: alumno.activo
                                ? AppColors.warning.withOpacity(0.08)
                                : AppColors.success.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: alumno.activo
                                  ? AppColors.warning.withOpacity(0.3)
                                  : AppColors.success.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                alumno.activo
                                    ? Icons.block_rounded
                                    : Icons.check_circle_outline_rounded,
                                size: 14,
                                color: alumno.activo
                                    ? AppColors.warning
                                    : AppColors.success,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                alumno.activo ? 'Desactivar' : 'Activar',
                                style: AppTextStyles.caption.copyWith(
                                  color: alumno.activo
                                      ? AppColors.warning
                                      : AppColors.success,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Eliminar
                      GestureDetector(
                        onTap: onDelete,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AppColors.error.withOpacity(0.2)),
                          ),
                          child: Icon(Icons.delete_outline_rounded,
                              size: 16, color: AppColors.error),
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

// ═══════════════════════════════════════════════════════════════════════════════
// WIDGETS AUXILIARES
// ═══════════════════════════════════════════════════════════════════════════════

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

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

class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isDark;
  final bool obscure;
  final String? hint;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final Widget? suffix;

  const _FormField({
    required this.label,
    required this.controller,
    required this.isDark,
    this.obscure = false,
    this.hint,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.validator,
    this.suffix,
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
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          style: AppTextStyles.body.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint ?? label.toLowerCase(),
            hintStyle: AppTextStyles.body.copyWith(
              color: isDark ? AppColors.darkTextMuted : AppColors.textHint,
            ),
            suffixIcon: suffix != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: suffix,
                  )
                : null,
            suffixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
          ),
        ),
      ],
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String hint;
  final String? value;
  final bool isDark;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;

  const _DropdownField({
    required this.hint,
    required this.value,
    required this.isDark,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.body.copyWith(
          color: isDark ? AppColors.darkTextMuted : AppColors.textHint,
        ),
      ),
      dropdownColor: isDark ? AppColors.darkBgSurface : AppColors.bgPrimary,
      style: AppTextStyles.body.copyWith(
        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
      ),
      icon: Icon(Icons.keyboard_arrow_down_rounded,
          color: isDark ? AppColors.darkTextMuted : AppColors.textMuted),
      items: items,
      onChanged: onChanged,
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
            child: Icon(Icons.group_outlined,
                color: isDark ? AppColors.darkBlueMid : AppColors.blueMid,
                size: 32),
          ),
          const SizedBox(height: 20),
          Text(
            'Sin alumnos registrados',
            style: AppTextStyles.displayLarge.copyWith(
              fontSize: 20,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega un alumno con el botón +',
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

class _NoResultsState extends StatelessWidget {
  final bool isDark;
  const _NoResultsState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded,
              size: 48,
              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted),
          const SizedBox(height: 16),
          Text(
            'Sin resultados',
            style: AppTextStyles.body.copyWith(
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
