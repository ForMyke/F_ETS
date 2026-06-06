import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/data/campus_locations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../widgets/campus_map_painter.dart';
import '../widgets/pulsing_pin.dart';

// Tamaño fijo del canvas del mapa — coincide con el viewBox del painter
const double _mapW = 800;
const double _mapH = 480;

class CampusMapPage extends StatefulWidget {
  final String edificioResaltado;

  /// Código del salón donde se aplica el examen (ej: "3CB1")
  final String? salonCodigo;

  /// Hora del examen (ej: "09:00")
  final String? horaExamen;

  const CampusMapPage({
    super.key,
    required this.edificioResaltado,
    this.salonCodigo,
    this.horaExamen,
  });

  @override
  State<CampusMapPage> createState() => _CampusMapPageState();
}

class _CampusMapPageState extends State<CampusMapPage>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  // Controlador para la animación de entrada de la página completa
  late AnimationController _entryController;
  late Animation<double> _entryFade;
  late Animation<Offset> _entrySlide;

  late String _selected;

  final TransformationController _transformController =
      TransformationController();

  @override
  void initState() {
    super.initState();
    _selected = widget.edificioResaltado;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    )..forward();

    // Animación de entrada suave
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _entryFade = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );
    _entrySlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutCubic,
    ));

    // Iniciar animación de entrada tras el primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _entryController.forward();
      _zoomToSelected();
    });
  }

  /// Centra y hace zoom al edificio actualmente seleccionado.
  void _zoomToSelected() {
    final loc = getLocation(_selected);
    if (loc == null) {
      _centerMap();
      return;
    }

    final screenSize = MediaQuery.of(context).size;
    final availableW = screenSize.width - 28;

    const double zoomScale = 2.2;

    final pinX = loc.svgOffset.dx;
    final pinY = loc.svgOffset.dy;

    final baseScale = availableW / _mapW;
    final scale = baseScale * zoomScale;

    final viewportH = screenSize.height * 0.60;

    final tx = (availableW / 2) - (pinX * scale);
    final ty = (viewportH / 2) - (pinY * scale);

    final matrix = Matrix4.identity()
      ..translate(tx, ty)
      ..scale(scale);

    _transformController.value = matrix;
  }

  void _centerMap() {
    final screenW = MediaQuery.of(context).size.width - 28;
    final scale = (screenW / _mapW).clamp(0.5, 1.5);
    final matrix = Matrix4.identity()..scale(scale);
    _transformController.value = matrix;
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    _entryController.dispose();
    _transformController.dispose();
    super.dispose();
  }

  EdificioLocation? get _loc => getLocation(_selected);

  void _selectEdificio(String key) {
    if (_selected == key) return;
    setState(() => _selected = key);
    _fadeController.reset();
    _fadeController.forward();
    _zoomToSelected();
  }

  Future<void> _openMaps() async {
    final loc = _loc;
    if (loc == null) return;
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1'
      '&query=${loc.lat},${loc.lng}',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = _loc;

    // Determinar si el edificio mostrado es el seleccionado originalmente
    final isOriginalBuilding =
        _isMatch(_selected) && _selected == widget.edificioResaltado ||
            getLocation(_selected)?.numeroEdificio ==
                getLocation(widget.edificioResaltado)?.numeroEdificio;

    return FadeTransition(
      opacity: _entryFade,
      child: SlideTransition(
        position: _entrySlide,
        child: Scaffold(
          backgroundColor:
              isDark ? AppColors.darkBgPrimary : AppColors.bgPrimary,
          body: SafeArea(
            child: Column(
              children: [
                // ── Header ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkBgSurface
                                : AppColors.bgSurface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.borderLight,
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 16,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Campus ESCOM',
                              style: AppTextStyles.displayLarge.copyWith(
                                fontSize: 20,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary,
                              ),
                            ),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Text(
                                loc?.nombre ?? 'Selecciona un edificio',
                                key: ValueKey(_selected),
                                style: AppTextStyles.caption.copyWith(
                                  color: isDark
                                      ? AppColors.darkBlueMid
                                      : AppColors.blueMid,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Botón reset zoom
                      GestureDetector(
                        onTap: _centerMap,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkBgSurface
                                : AppColors.bgSurface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.borderLight,
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            Icons.center_focus_strong_outlined,
                            size: 18,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: -0.08, curve: Curves.easeOutCubic),

                const SizedBox(height: 14),

                // ── Mapa con pan/zoom ────────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.borderLight,
                            width: 1.5,
                          ),
                        ),
                        child: InteractiveViewer(
                          transformationController: _transformController,
                          minScale: 0.4,
                          maxScale: 4.0,
                          constrained: false,
                          child: SizedBox(
                            width: _mapW,
                            height: _mapH,
                            child: Stack(
                              children: [
                                // Painter
                                Positioned.fill(
                                  child: GestureDetector(
                                    onTapUp: (d) => _handleTap(d.localPosition),
                                    child: CustomPaint(
                                      painter: CampusMapPainter(
                                        isDark: isDark,
                                        selectedEdificio: _selected,
                                      ),
                                    ),
                                  ),
                                ),

                                // Pines
                                ...campusLocations.entries.map((e) {
                                  final isActive = _isMatch(e.key);
                                  final dx = e.value.svgOffset.dx;
                                  final dy = e.value.svgOffset.dy;
                                  return Positioned(
                                    left: dx - 25,
                                    top: dy - 30,
                                    child: PulsingPin(
                                      controller: _pulseController,
                                      isActive: isActive,
                                      isDark: isDark,
                                      label: e.key,
                                      onTap: () => _selectEdificio(e.key),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 120.ms, duration: 500.ms),
                ),

                const SizedBox(height: 12),

                // ── Info card mejorada ──────────────────────────────
                if (loc != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: FadeTransition(
                      opacity: _fadeController,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkBgSurface
                              : AppColors.bgPrimary,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.borderLight,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Ícono de edificio
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkBlueLight
                                    : AppColors.blueSurface,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Text(
                                  loc.numeroEdificio,
                                  style: AppTextStyles.body.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppColors.darkBlueMid
                                        : AppColors.blueMid,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Nombre del edificio
                                  Text(
                                    loc.nombre,
                                    style: AppTextStyles.body.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  // Fila de datos: salón y hora
                                  Row(
                                    children: [
                                      // Salón
                                      if (widget.salonCodigo != null) ...[
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? AppColors.darkBlueLight
                                                : AppColors.blueSurface,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.meeting_room_outlined,
                                                size: 12,
                                                color: isDark
                                                    ? AppColors.darkBlueMid
                                                    : AppColors.blueMid,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Salón ${widget.salonCodigo}',
                                                style: AppTextStyles.caption
                                                    .copyWith(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: isDark
                                                      ? AppColors.darkBlueMid
                                                      : AppColors.blueMid,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                      // Hora
                                      if (widget.horaExamen != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? AppColors.darkBgOverlay
                                                : AppColors.bgSurface,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                              color: isDark
                                                  ? AppColors.darkBorder
                                                  : AppColors.borderLight,
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.access_time_rounded,
                                                size: 12,
                                                color: isDark
                                                    ? AppColors
                                                        .darkTextSecondary
                                                    : AppColors.textSecondary,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                widget.horaExamen!,
                                                style: AppTextStyles.caption
                                                    .copyWith(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: isDark
                                                      ? AppColors
                                                          .darkTextSecondary
                                                      : AppColors.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                  // Si no hay salón ni hora, mostrar texto de apoyo
                                  if (widget.salonCodigo == null &&
                                      widget.horaExamen == null)
                                    Text(
                                      'Toca los pines para explorar',
                                      style: AppTextStyles.caption.copyWith(
                                        color: isDark
                                            ? AppColors.darkTextMuted
                                            : AppColors.textMuted,
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(
                        begin: 0.12,
                        curve: Curves.easeOutCubic,
                      ),

                const SizedBox(height: 10),

                // ── Botón Google Maps ────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
                  child: GestureDetector(
                    onTap: _openMaps,
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.blueMid : AppColors.blue,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.map_rounded,
                              color: Colors.white, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            'Abrir en Google Maps',
                            style: AppTextStyles.body.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 280.ms, duration: 400.ms)
                    .slideY(begin: 0.15, curve: Curves.easeOutCubic),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isMatch(String key) {
    if (_selected == key) return true;
    final lo = _selected.toLowerCase();
    if (key == 'Lab' && lo.contains('lab')) return true;
    if (key == 'Gob' && (lo.contains('gob') || lo.contains('gobierno')))
      return true;
    final n = RegExp(r'\d+').firstMatch(_selected)?.group(0);
    return n != null && key == n;
  }

  void _handleTap(Offset localPos) {
    String? closest;
    double minDist = 60.0 * 60.0;

    for (final e in campusLocations.entries) {
      final ox = e.value.svgOffset.dx;
      final oy = e.value.svgOffset.dy;
      final dist = (localPos.dx - ox) * (localPos.dx - ox) +
          (localPos.dy - oy) * (localPos.dy - oy);
      if (dist < minDist) {
        minDist = dist;
        closest = e.key;
      }
    }

    if (closest != null) _selectEdificio(closest);
  }
}
