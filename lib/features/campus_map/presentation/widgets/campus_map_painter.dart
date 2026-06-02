import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CampusMapPainter extends CustomPainter {
  final bool isDark;
  final String selectedEdificio;

  CampusMapPainter({
    required this.isDark,
    required this.selectedEdificio,
  });

  // ── Paleta ──────────────────────────────────────────────────────
  Color get _bg => isDark ? const Color(0xFF162030) : const Color(0xFFF2F5F0);
  Color get _grass =>
      isDark ? const Color(0xFF1A3020) : const Color(0xFFCFE8BB);
  Color get _path => isDark ? const Color(0xFF243545) : const Color(0xFFD8D2C8);
  // FIX 1: Renombrado de _building a _buildingColor para evitar conflicto con el método _building()
  Color get _buildingColor =>
      isDark ? const Color(0xFF1E3A5F) : const Color(0xFFB8D4EA);
  Color get _buildingSel => isDark ? AppColors.blueMid : AppColors.blue;
  Color get _explanada =>
      isDark ? const Color(0xFF1C3530) : const Color(0xFFDDEDD0);
  Color get _special =>
      isDark ? const Color(0xFF2A2040) : const Color(0xFFE0DAEF);
  Color get _coffee =>
      isDark ? const Color(0xFF3A2A1A) : const Color(0xFFEDD9C0);
  Color get _border => isDark ? AppColors.darkBorder : AppColors.border;
  Color get _textSec =>
      isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

  // ── viewBox base 700 × 520 ──────────────────────────────────────
  static const double _vW = 700;
  static const double _vH = 520;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / _vW, size.height / _vH);

    _drawBg(canvas);
    _drawPaths(canvas);
    _drawZones(canvas);
    _drawBuildings(canvas);
    _drawEntrance(canvas);

    canvas.restore();
  }

  // ── Fondo ────────────────────────────────────────────────────────
  void _drawBg(Canvas canvas) {
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, _vW, _vH),
      Paint()..color = _bg,
    );
    // Marco exterior del campus
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(8, 8, 684, 504), const Radius.circular(14)),
      Paint()
        ..color = _border
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
  }

  // ── Calles / caminos ─────────────────────────────────────────────
  void _drawPaths(Canvas canvas) {
    final p = Paint()..color = _path;

    // Horizontal principal (divide fila superior e inferior)
    canvas.drawRect(const Rect.fromLTWH(8, 218, 684, 24), p);

    // Horizontal superior (separa edificios superiores del techo)
    canvas.drawRect(const Rect.fromLTWH(8, 86, 684, 20), p);

    // Horizontal inferior (separa fila inferior de zonas bajas)
    canvas.drawRect(const Rect.fromLTWH(8, 368, 684, 20), p);

    // Vertical izq (entre auditorio y ed.gobierno / ed.1)
    canvas.drawRect(const Rect.fromLTWH(108, 8, 20, 504), p);

    // Vertical centro (entre ed.2/1 y ed.lab/3)
    canvas.drawRect(const Rect.fromLTWH(390, 8, 20, 504), p);

    // Vertical der (entre ed.lab/3 y ed.5)
    canvas.drawRect(const Rect.fromLTWH(560, 8, 20, 504), p);
  }

  // ── Zonas especiales ─────────────────────────────────────────────
  void _drawZones(Canvas canvas) {
    // Explanada
    _zone(
      canvas,
      rect: const Rect.fromLTWH(128, 106, 262, 112),
      color: _explanada,
      label: 'Explanada',
      labelColor: isDark ? const Color(0xFF6DB88A) : const Color(0xFF3A7D44),
      fontSize: 12,
    );

    // Auditorio
    _zone(
      canvas,
      rect: const Rect.fromLTWH(18, 106, 90, 112),
      color: _special,
      label: 'Auditorio',
      labelColor: isDark ? const Color(0xFFB39DDB) : const Color(0xFF5E35B1),
      fontSize: 10,
    );

    // Área de estudio (izq, fila media-baja)
    _zone(
      canvas,
      rect: const Rect.fromLTWH(18, 242, 90, 80),
      color: _grass,
      label: 'Área\nEstudio',
      labelColor: isDark ? const Color(0xFF66BB6A) : const Color(0xFF2E7D32),
      fontSize: 9,
    );

    // Área deportiva izquierda
    _zone(
      canvas,
      rect: const Rect.fromLTWH(18, 388, 110, 108),
      color: _grass,
      label: 'Área\nDeportiva',
      labelColor: isDark ? const Color(0xFF66BB6A) : const Color(0xFF2E7D32),
      fontSize: 9,
    );

    // Barra de café
    _zone(
      canvas,
      rect: const Rect.fromLTWH(138, 388, 80, 55),
      color: _coffee,
      label: 'Barra\nCafé',
      labelColor: isDark ? const Color(0xFFFFB74D) : const Color(0xFF6D4C41),
      fontSize: 8,
    );

    // Área deportiva derecha
    _zone(
      canvas,
      rect: const Rect.fromLTWH(580, 242, 110, 126),
      color: _grass,
      label: 'Área\nDeportiva',
      labelColor: isDark ? const Color(0xFF66BB6A) : const Color(0xFF2E7D32),
      fontSize: 9,
    );

    // Cafetería
    _zone(
      canvas,
      rect: const Rect.fromLTWH(580, 388, 110, 108),
      color: _coffee,
      label: 'Cafetería',
      labelColor: isDark ? const Color(0xFFFFB74D) : const Color(0xFF6D4C41),
      fontSize: 10,
    );
  }

  // ── Edificios ────────────────────────────────────────────────────
  void _drawBuildings(Canvas canvas) {
    for (final e in _rects().entries) {
      _building(canvas, e.key, e.value, _isSelected(e.key));
    }
  }

  bool _isSelected(String key) {
    if (selectedEdificio == key) return true;
    final lo = selectedEdificio.toLowerCase();
    if (key == 'Lab' && (lo.contains('lab'))) return true;
    // FIX 2: if sin llaves corregido con bloque {}
    if (key == 'Gob' && (lo.contains('gob') || lo.contains('gobierno'))) {
      return true;
    }
    final n = RegExp(r'\d+').firstMatch(selectedEdificio)?.group(0);
    return n != null && key == n;
  }

  void _building(Canvas canvas, String key, Rect rect, bool selected) {
    // Sombra
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.translate(3, 4), const Radius.circular(9)),
      Paint()
        // FIX 3: withOpacity reemplazado por withValues
        ..color = Colors.black.withValues(alpha: isDark ? 0.35 : 0.13)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Cuerpo
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(9)),
      // FIX 1: Usando _buildingColor en lugar de _building
      Paint()..color = selected ? _buildingSel : _buildingColor,
    );

    // Borde
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(9)),
      Paint()
        ..color = selected
            ? (isDark ? AppColors.darkBlueMid : AppColors.blueLight)
            : _border
        ..strokeWidth = selected ? 2.5 : 1.5
        ..style = PaintingStyle.stroke,
    );

    // Ventanas (si no seleccionado)
    if (!selected) _windows(canvas, rect);

    // Texto
    _text(
      canvas,
      label: _label(key),
      center: rect.center,
      color: selected ? Colors.white : _textSec,
      size: (key == 'Lab' || key == 'Gob') ? 9.0 : 11.0,
      bold: selected,
      maxW: rect.width - 8,
    );
  }

  String _label(String k) {
    switch (k) {
      case 'Lab':
        return 'Edif.\nLabs';
      case 'Gob':
        return 'Edif.\nGobierno';
      default:
        return 'Edif. $k';
    }
  }

  void _windows(Canvas canvas, Rect rect) {
    final p = Paint()
      ..color = isDark
          // FIX 3: withOpacity reemplazado por withValues
          ? const Color(0xFF2A4A6A)
          : const Color(0xFF90CAF9).withValues(alpha: 0.5);
    const wW = 7.0, wH = 5.0, pad = 10.0, gap = 5.0;
    double x = rect.left + pad;
    while (x + wW < rect.right - pad / 2) {
      double y = rect.top + pad;
      while (y + wH < rect.bottom - pad / 2) {
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTWH(x, y, wW, wH), const Radius.circular(1)),
            p);
        y += wH + gap;
      }
      x += wW + gap;
    }
  }

  // ── Entrada / salida ─────────────────────────────────────────────
  void _drawEntrance(Canvas canvas) {
    const cx = 290.0, cy = 72.0;
    final rr = RRect.fromRectAndRadius(
      const Rect.fromLTWH(cx - 22, cy - 13, 44, 24),
      const Radius.circular(7),
    );
    canvas.drawRRect(
        rr,
        Paint()
          ..color = isDark ? AppColors.darkBlueLight : AppColors.blueSurface);
    canvas.drawRRect(
        rr,
        Paint()
          ..color = isDark ? AppColors.darkBlueMid : AppColors.blueMid
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke);

    _text(
      canvas,
      label: 'E/S',
      center: const Offset(cx, cy),
      color: isDark ? AppColors.darkBlueMid : AppColors.blueMid,
      size: 9,
      bold: true,
      maxW: 44,
    );

    // Flecha abajo
    final ap = Paint()
      ..color = isDark ? AppColors.darkBlueMid : AppColors.blueMid;
    final arrow = Path()
      ..moveTo(cx - 7, cy + 11)
      ..lineTo(cx + 7, cy + 11)
      ..lineTo(cx, cy + 20)
      ..close();
    canvas.drawPath(arrow, ap);
  }

  // ── Helpers ──────────────────────────────────────────────────────
  void _zone(
    Canvas canvas, {
    required Rect rect,
    required Color color,
    required String label,
    required Color labelColor,
    double fontSize = 10,
  }) {
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)),
        Paint()..color = color);
    canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)),
        Paint()
          // FIX 3: withOpacity reemplazado por withValues
          ..color = labelColor.withValues(alpha: 0.25)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke);
    _text(
      canvas,
      label: label,
      center: rect.center,
      color: labelColor,
      size: fontSize,
      bold: false,
      maxW: rect.width - 8,
    );
  }

  void _text(
    Canvas canvas, {
    required String label,
    required Offset center,
    required Color color,
    required double size,
    required bool bold,
    double maxW = 90,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          height: 1.3,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: maxW);
    tp.paint(
        canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  // ── Rectángulos de edificios (coordenadas en viewBox 700×520) ────
  Map<String, Rect> _rects() => {
        // Fila superior
        '2': const Rect.fromLTWH(128, 106, 262, 112),

        // Edificio 4 (arriba derecha, entre calle centro y calle der)
        '4': const Rect.fromLTWH(410, 106, 150, 112),

        // Edificio de Gobierno (izq, fila media)
        'Gob': const Rect.fromLTWH(18, 106, 90, 112),

        // Edificio de Laboratorios (centro-der, fila media)
        'Lab': const Rect.fromLTWH(410, 106, 150, 112),

        // Edificio 5 (columna derecha, ocupa fila media completa)
        '5': const Rect.fromLTWH(580, 106, 110, 248),

        // Fila inferior centro-izq
        '1': const Rect.fromLTWH(128, 242, 262, 112),

        // Fila inferior centro-der
        '3': const Rect.fromLTWH(410, 242, 150, 112),
      };

  @override
  bool shouldRepaint(CampusMapPainter old) =>
      old.selectedEdificio != selectedEdificio || old.isDark != isDark;
}
