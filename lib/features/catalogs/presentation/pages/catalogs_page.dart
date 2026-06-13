import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:etsAndroid/core/theme/app_colors.dart';
import 'package:etsAndroid/core/theme/app_text_styles.dart';
import 'package:etsAndroid/features/catalogs/data/datasources/catalogs_remote_datasource.dart';
import 'package:etsAndroid/features/catalogs/presentation/bloc/catalogs_bloc.dart';

class CatalogsPage extends StatelessWidget {
  const CatalogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CatalogsBloc(
        dataSource: CatalogsRemoteDataSourceImpl(
          client: Supabase.instance.client,
        ),
      )..add(const CatalogsStarted()),
      child: const _CatalogsView(),
    );
  }
}

class _CatalogsView extends StatefulWidget {
  const _CatalogsView();

  @override
  State<_CatalogsView> createState() => _CatalogsViewState();
}

class _CatalogsViewState extends State<_CatalogsView> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBgPrimary : AppColors.bgPrimary,
      floatingActionButton: BlocBuilder<CatalogsBloc, CatalogsState>(
        builder: (context, state) {
          if (state is! CatalogsSuccess) return const SizedBox.shrink();
          return FloatingActionButton(
            backgroundColor: isDark ? AppColors.blueMid : AppColors.blue,
            onPressed: () => _showForm(context, state, isDark),
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
                          'CATÁLOGOS',
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
                          text: 'Carreras y ',
                          style: AppTextStyles.displayLarge.copyWith(
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          ),
                        ),
                        TextSpan(
                          text: 'salones',
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

                  // Tabs
                  Row(
                    children: ['Carreras', 'Edificios', 'Salones'].asMap().entries.map((e) {
                      final isActive = _tabIndex == e.key;
                      return GestureDetector(
                        onTap: () => setState(() => _tabIndex = e.key),
                        child: AnimatedContainer(
                          duration: 200.ms,
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isActive
                                ? (isDark ? AppColors.blueMid : AppColors.blue)
                                : (isDark ? AppColors.darkBgSurface : AppColors.bgSurface),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isActive
                                  ? Colors.transparent
                                  : (isDark ? AppColors.darkBorder : AppColors.borderLight),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            e.value,
                            style: AppTextStyles.caption.copyWith(
                              color: isActive
                                  ? Colors.white
                                  : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                              fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 400.ms)
                      .slideY(begin: 0.2, curve: Curves.easeOutCubic),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Contenido
            Expanded(
              child: BlocBuilder<CatalogsBloc, CatalogsState>(
                builder: (context, state) {
                  if (state is CatalogsLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: isDark ? AppColors.darkBlueMid : AppColors.blueMid,
                        strokeWidth: 2.5,
                      ),
                    );
                  }
                  if (state is CatalogsFailure) {
                    return Center(
                      child: Text(state.message,
                          style: AppTextStyles.bodyMuted.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          )),
                    );
                  }
                  if (state is CatalogsSuccess) {
                    return AnimatedSwitcher(
                      duration: 250.ms,
                      child: KeyedSubtree(
                        key: ValueKey(_tabIndex),
                        child: _tabIndex == 0
                            ? _CarrerasList(carreras: state.carreras, isDark: isDark)
                            : _tabIndex == 1
                            ? _EdificiosList(edificios: state.edificios, isDark: isDark)
                            : _SalonesList(salones: state.salones, isDark: isDark),
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

  void _showForm(BuildContext context, CatalogsSuccess state, bool isDark) {
    switch (_tabIndex) {
      case 0:
        _showCarreraForm(context, isDark);
        break;
      case 1:
        _showEdificioForm(context, isDark);
        break;
      case 2:
        _showSalonForm(context, state.edificios, isDark);
        break;
    }
  }

  void _showCarreraForm(BuildContext context, bool isDark, {CarreraItem? item}) {
    final nombreCtrl = TextEditingController(text: item?.nombre);
    final acronimoCtrl = TextEditingController(text: item?.acronimo);
    bool activo = item?.activo ?? true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => _FormSheet(
          title: item == null ? 'Nueva carrera' : 'Editar carrera',
          isDark: isDark,
          onSave: () {
            if (nombreCtrl.text.isEmpty || acronimoCtrl.text.isEmpty) return;
            if (item == null) {
              context.read<CatalogsBloc>().add(CarreraCreated(
                nombre: nombreCtrl.text.trim(),
                acronimo: acronimoCtrl.text.trim(),
              ));
            } else {
              context.read<CatalogsBloc>().add(CarreraUpdated(
                id: item.id,
                nombre: nombreCtrl.text.trim(),
                acronimo: acronimoCtrl.text.trim(),
                activo: activo,
              ));
            }
            Navigator.of(ctx).pop();
          },
          children: [
            _FormField(label: 'NOMBRE', controller: nombreCtrl, isDark: isDark),
            const SizedBox(height: 16),
            _FormField(label: 'ACRÓNIMO', controller: acronimoCtrl, isDark: isDark),
            if (item != null) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Activa', style: AppTextStyles.body.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  )),
                  Switch(
                    value: activo,
                    activeColor: isDark ? AppColors.darkBlueMid : AppColors.blueMid,
                    onChanged: (val) => setModalState(() => activo = val),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showEdificioForm(BuildContext context, bool isDark, {EdificioItem? item}) {
    final numeroCtrl = TextEditingController(text: item?.numero);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _FormSheet(
        title: item == null ? 'Nuevo edificio' : 'Editar edificio',
        isDark: isDark,
        onSave: () {
          if (numeroCtrl.text.isEmpty) return;
          if (item == null) {
            context.read<CatalogsBloc>().add(EdificioCreated(numero: numeroCtrl.text.trim()));
          } else {
            context.read<CatalogsBloc>().add(EdificioUpdated(id: item.id, numero: numeroCtrl.text.trim()));
          }
          Navigator.of(ctx).pop();
        },
        children: [
          _FormField(label: 'NÚMERO', controller: numeroCtrl, isDark: isDark),
        ],
      ),
    );
  }

  void _showSalonForm(BuildContext context, List<EdificioItem> edificios, bool isDark, {SalonItem? item}) {
    final codigoCtrl = TextEditingController(text: item?.codigo);
    final pisoCtrl = TextEditingController(text: item?.piso);
    String? edificioId = item?.edificioId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => _FormSheet(
          title: item == null ? 'Nuevo salón' : 'Editar salón',
          isDark: isDark,
          onSave: () {
            if (codigoCtrl.text.isEmpty || pisoCtrl.text.isEmpty || edificioId == null) return;
            if (item == null) {
              context.read<CatalogsBloc>().add(SalonCreated(
                codigo: codigoCtrl.text.trim(),
                piso: pisoCtrl.text.trim(),
                edificioId: edificioId!,
              ));
            } else {
              context.read<CatalogsBloc>().add(SalonUpdated(
                id: item.id,
                codigo: codigoCtrl.text.trim(),
                piso: pisoCtrl.text.trim(),
                edificioId: edificioId!,
              ));
            }
            Navigator.of(ctx).pop();
          },
          children: [
            _FormField(label: 'CÓDIGO', controller: codigoCtrl, isDark: isDark),
            const SizedBox(height: 16),
            _FormField(label: 'PISO', controller: pisoCtrl, isDark: isDark),
            const SizedBox(height: 16),
            Text('EDIFICIO', style: AppTextStyles.fieldLabel.copyWith(
              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
            )),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBgSurface : AppColors.bgSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                  width: 1.5,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: edificioId,
                  hint: Text('Selecciona edificio',
                      style: AppTextStyles.body.copyWith(
                        color: isDark ? AppColors.darkTextMuted : AppColors.textHint,
                      )),
                  isExpanded: true,
                  dropdownColor: isDark ? AppColors.darkBgSurface : AppColors.bgPrimary,
                  style: AppTextStyles.body.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                  icon: Icon(Icons.keyboard_arrow_down_rounded,
                      color: isDark ? AppColors.darkTextMuted : AppColors.textMuted),
                  items: edificios.map((e) => DropdownMenuItem(
                    value: e.id,
                    child: Text('Edificio ${e.numero}'),
                  )).toList(),
                  onChanged: (val) => setModalState(() => edificioId = val),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Listas
class _CarrerasList extends StatelessWidget {
  final List<CarreraItem> carreras;
  final bool isDark;

  const _CarrerasList({required this.carreras, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (carreras.isEmpty) return _EmptyState(isDark: isDark, label: 'Sin carreras');
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
      itemCount: carreras.length,
      itemBuilder: (_, i) {
        final c = carreras[i];
        return _CatalogTile(
          isDark: isDark,
          index: i,
          title: c.nombre,
          subtitle: c.acronimo,
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: c.activo
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              c.activo ? 'Activa' : 'Inactiva',
              style: AppTextStyles.caption.copyWith(
                color: c.activo ? AppColors.success : AppColors.error,
                fontSize: 11,
              ),
            ),
          ),
          onEdit: () {
            final state = context.read<CatalogsBloc>().state;
            if (state is CatalogsSuccess) {
              _showCarreraFormFromParent(context, isDark, item: c);
            }
          },
          onDelete: () => _confirmDelete(context, isDark, () {
            context.read<CatalogsBloc>().add(CarreraDeleted(id: c.id));
          }),
        );
      },
    );
  }

  void _showCarreraFormFromParent(BuildContext context, bool isDark, {CarreraItem? item}) {
    final nombreCtrl = TextEditingController(text: item?.nombre);
    final acronimoCtrl = TextEditingController(text: item?.acronimo);
    bool activo = item?.activo ?? true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => _FormSheet(
          title: 'Editar carrera',
          isDark: isDark,
          onSave: () {
            if (nombreCtrl.text.isEmpty || acronimoCtrl.text.isEmpty) return;
            context.read<CatalogsBloc>().add(CarreraUpdated(
              id: item!.id,
              nombre: nombreCtrl.text.trim(),
              acronimo: acronimoCtrl.text.trim(),
              activo: activo,
            ));
            Navigator.of(ctx).pop();
          },
          children: [
            _FormField(label: 'NOMBRE', controller: nombreCtrl, isDark: isDark),
            const SizedBox(height: 16),
            _FormField(label: 'ACRÓNIMO', controller: acronimoCtrl, isDark: isDark),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Activa', style: AppTextStyles.body.copyWith(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                )),
                Switch(
                  value: activo,
                  activeColor: isDark ? AppColors.darkBlueMid : AppColors.blueMid,
                  onChanged: (val) => setModalState(() => activo = val),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EdificiosList extends StatelessWidget {
  final List<EdificioItem> edificios;
  final bool isDark;

  const _EdificiosList({required this.edificios, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (edificios.isEmpty) return _EmptyState(isDark: isDark, label: 'Sin edificios');
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
      itemCount: edificios.length,
      itemBuilder: (_, i) {
        final e = edificios[i];
        return _CatalogTile(
          isDark: isDark,
          index: i,
          title: 'Edificio ${e.numero}',
          subtitle: 'ID: ${e.id}',
          onEdit: () => _showEdificioForm(context, isDark, item: e),
          onDelete: () => _confirmDelete(context, isDark, () {
            context.read<CatalogsBloc>().add(EdificioDeleted(id: e.id));
          }),
        );
      },
    );
  }

  void _showEdificioForm(BuildContext context, bool isDark, {EdificioItem? item}) {
    final numeroCtrl = TextEditingController(text: item?.numero);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _FormSheet(
        title: 'Editar edificio',
        isDark: isDark,
        onSave: () {
          if (numeroCtrl.text.isEmpty) return;
          context.read<CatalogsBloc>().add(EdificioUpdated(id: item!.id, numero: numeroCtrl.text.trim()));
          Navigator.of(ctx).pop();
        },
        children: [
          _FormField(label: 'NÚMERO', controller: numeroCtrl, isDark: isDark),
        ],
      ),
    );
  }
}

class _SalonesList extends StatelessWidget {
  final List<SalonItem> salones;
  final bool isDark;

  const _SalonesList({required this.salones, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (salones.isEmpty) return _EmptyState(isDark: isDark, label: 'Sin salones');
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
      itemCount: salones.length,
      itemBuilder: (_, i) {
        final s = salones[i];
        return _CatalogTile(
          isDark: isDark,
          index: i,
          title: s.codigo,
          subtitle: 'Piso ${s.piso} · Edificio ${s.edificioNumero}',
          onEdit: () => _showSalonForm(context, isDark, item: s),
          onDelete: () => _confirmDelete(context, isDark, () {
            context.read<CatalogsBloc>().add(SalonDeleted(id: s.id));
          }),
        );
      },
    );
  }

  void _showSalonForm(BuildContext context, bool isDark, {SalonItem? item}) {
    final codigoCtrl = TextEditingController(text: item?.codigo);
    final pisoCtrl = TextEditingController(text: item?.piso);
    String? edificioId = item?.edificioId;

    final state = context.read<CatalogsBloc>().state;
    final edificios = state is CatalogsSuccess ? state.edificios : <EdificioItem>[];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => _FormSheet(
          title: 'Editar salón',
          isDark: isDark,
          onSave: () {
            if (codigoCtrl.text.isEmpty || pisoCtrl.text.isEmpty || edificioId == null) return;
            context.read<CatalogsBloc>().add(SalonUpdated(
              id: item!.id,
              codigo: codigoCtrl.text.trim(),
              piso: pisoCtrl.text.trim(),
              edificioId: edificioId!,
            ));
            Navigator.of(ctx).pop();
          },
          children: [
            _FormField(label: 'CÓDIGO', controller: codigoCtrl, isDark: isDark),
            const SizedBox(height: 16),
            _FormField(label: 'PISO', controller: pisoCtrl, isDark: isDark),
            const SizedBox(height: 16),
            Text('EDIFICIO', style: AppTextStyles.fieldLabel.copyWith(
              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
            )),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBgSurface : AppColors.bgSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                  width: 1.5,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: edificioId,
                  isExpanded: true,
                  dropdownColor: isDark ? AppColors.darkBgSurface : AppColors.bgPrimary,
                  style: AppTextStyles.body.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                  icon: Icon(Icons.keyboard_arrow_down_rounded,
                      color: isDark ? AppColors.darkTextMuted : AppColors.textMuted),
                  items: edificios.map((e) => DropdownMenuItem(
                    value: e.id,
                    child: Text('Edificio ${e.numero}'),
                  )).toList(),
                  onChanged: (val) => setModalState(() => edificioId = val),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widgets compartidos
class _CatalogTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isDark;
  final int index;
  final Widget? trailing;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CatalogTile({
    required this.title,
    required this.subtitle,
    required this.isDark,
    required this.index,
    required this.onEdit,
    required this.onDelete,
    this.trailing,
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                )),
                const SizedBox(height: 4),
                Text(subtitle, style: AppTextStyles.caption.copyWith(
                  color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                )),
              ],
            ),
          ),
          if (trailing != null) ...[
            trailing!,
            const SizedBox(width: 8),
          ],
          GestureDetector(
            onTap: onEdit,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBgOverlay : AppColors.bgSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.borderLight,
                ),
              ),
              child: Icon(Icons.edit_outlined, size: 16,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 8),
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
              child: Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.error),
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

class _EmptyState extends StatelessWidget {
  final bool isDark;
  final String label;

  const _EmptyState({required this.isDark, required this.label});

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
            child: Icon(Icons.folder_outlined,
                color: isDark ? AppColors.darkBlueMid : AppColors.blueMid, size: 32),
          ),
          const SizedBox(height: 20),
          Text(label, style: AppTextStyles.displayLarge.copyWith(
            fontSize: 20,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          )),
          const SizedBox(height: 8),
          Text('Agrega uno con el botón +', style: AppTextStyles.bodyMuted.copyWith(
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          )),
        ],
      ),
    );
  }
}

class _FormSheet extends StatelessWidget {
  final String title;
  final bool isDark;
  final VoidCallback onSave;
  final List<Widget> children;

  const _FormSheet({
    required this.title,
    required this.isDark,
    required this.onSave,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBgSurface : AppColors.bgPrimary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        24, 16, 24,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
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
                  color: isDark ? AppColors.darkBorder : AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(title, style: AppTextStyles.displayLarge.copyWith(
              fontSize: 22,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            )),
            const SizedBox(height: 24),
            ...children,
            const SizedBox(height: 32),
            GestureDetector(
              onTap: onSave,
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.blueMid : AppColors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text('Guardar',
                      style: AppTextStyles.body.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isDark;

  const _FormField({required this.label, required this.controller, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.fieldLabel.copyWith(
          color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
        )),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: AppTextStyles.body.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
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

void _confirmDelete(BuildContext context, bool isDark, VoidCallback onConfirm) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: isDark ? AppColors.darkBgSurface : AppColors.bgPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Eliminar',
          style: AppTextStyles.displayLarge.copyWith(
            fontSize: 18,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          )),
      content: Text('¿Estás seguro? Esta acción no se puede deshacer.',
          style: AppTextStyles.bodyMuted.copyWith(
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          )),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancelar',
              style: AppTextStyles.body.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              )),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            HapticFeedback.mediumImpact();
            onConfirm();
          },
          child: Text('Eliminar',
              style: AppTextStyles.body.copyWith(color: AppColors.error)),
        ),
      ],
    ),
  );
}