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

  const CampusMapPage({
    super.key,
    required this.edificioResaltado,
  });

  @override
  State<CampusMapPage> createState() => _CampusMapPageState();
}

class _CampusMapPageState extends State<CampusMapPage>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;
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

    // Centrar el mapa al abrir: calcular offset inicial tras el primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _centerMap());
  }

  void _centerMap() {
    // Escala inicial para que el mapa ocupe ~90% del ancho disponible
    final screenW = MediaQuery.of(context).size.width - 28; // padding 14*2
    final scale = (screenW / _mapW).clamp(0.5, 1.5);
    final matrix = Matrix4.identity()..scale(scale);
    _transformController.value = matrix;
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    _transformController.dispose();
    super.dispose();
  }

  EdificioLocation? get _loc => getLocation(_selected);

  void _selectEdificio(String key) {
    if (_selected == key) return;
    setState(() => _selected = key);
    _fadeController.reset();
    _fadeController.forward();
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

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBgPrimary : AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────
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
            ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),

            const SizedBox(height: 14),

            // ── Mapa con pan/zoom ────────────────────────────────────
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
                      constrained:
                          false, // ← clave: el hijo define su propio tamaño
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

                            // Pines — usan coordenadas del viewBox directamente
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

            // ── Info card ────────────────────────────────────────────
            if (loc != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: FadeTransition(
                  opacity: _fadeController,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkBgSurface
                          : AppColors.bgPrimary,
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
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkBlueLight
                                : AppColors.blueSurface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              loc.numeroEdificio,
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                loc.nombre,
                                style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                '${loc.lat.toStringAsFixed(5)}, '
                                '${loc.lng.toStringAsFixed(5)}',
                                style: AppTextStyles.caption.copyWith(
                                  color: isDark
                                      ? AppColors.darkTextMuted
                                      : AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.textMuted,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 10),

            // ── Botón Google Maps ────────────────────────────────────
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
              ).animate().fadeIn(delay: 250.ms, duration: 400.ms).slideY(
                    begin: 0.2,
                    curve: Curves.easeOutCubic,
                  ),
            ),
          ],
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
    // localPos ya está en coordenadas del SizedBox (800×480), sin escalar
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
