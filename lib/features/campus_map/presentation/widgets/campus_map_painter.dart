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
  Color get _bg => isDark ? const Color(0xFF162030) : const Color(0xFFF7F7F7);
  Color get _borderOuter =>
      isDark ? const Color(0xFF2A3F55) : const Color(0xFFBBBBBB);
  Color get _buildingFill =>
      isDark ? const Color(0xFF1E3A5F) : const Color(0xFFFFFFFF);
  Color get _buildingSel => isDark ? AppColors.blueMid : AppColors.blue;
  Color get _buildingBorder =>
      isDark ? const Color(0xFF3A5A7A) : const Color(0xFF555555);
  Color get _explanadaFill =>
      isDark ? const Color(0xFF1A3020) : const Color(0xFFEEEEEE);
  Color get _specialFill =>
      isDark ? const Color(0xFF1C2A3A) : const Color(0xFFF0F0F0);
  Color get _grassFill =>
      isDark ? const Color(0xFF1A3020) : const Color(0xFFE8F5E9);
  Color get _coffeeFill =>
      isDark ? const Color(0xFF2A1A0A) : const Color(0xFFFFF8F0);
  Color get _labelColor =>
      isDark ? AppColors.darkTextSecondary : const Color(0xFF333333);
  Color get _labelSel => Colors.white;
  Color get _mutedLabel =>
      isDark ? AppColors.darkTextMuted : const Color(0xFF777777);
  Color get _salonTagBg =>
      isDark ? const Color(0xFF0D47A1) : const Color(0xFF3A6B9E);
  Color get _entranceBg =>
      isDark ? const Color(0xFF1E3A5F) : const Color(0xFF2C4A6E);

  // ── viewBox 800 × 480 ──────────────────────────────────────────
  static const double _vW = 800;
  static const double _vH = 480;

  // ── Márgenes y medidas base ─────────────────────────────────────
  static const double _margin = 14.0;
  static const double _rad = 6.0;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / _vW, size.height / _vH);
    _drawBg(canvas);
    _drawZones(canvas);
    _drawBuildings(canvas);
    _drawSalonTags(canvas);
    _drawEntrance(canvas);
    canvas.restore();
  }

  // ── Fondo y borde exterior ───────────────────────────────────────
  void _drawBg(Canvas canvas) {
    final rr = RRect.fromRectAndRadius(
      Rect.fromLTWH(_margin, _margin, _vW - _margin * 2, _vH - _margin * 2),
      const Radius.circular(10),
    );
    canvas.drawRRect(rr, Paint()..color = _bg);
    canvas.drawRRect(
      rr,
      Paint()
        ..color = _borderOuter
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
  }

  // ── Zonas especiales ─────────────────────────────────────────────
  void _drawZones(Canvas canvas) {
    // Explanada (centro-izquierda fila media)
    _zone(canvas,
        rect: const Rect.fromLTWH(222, 152, 188, 148),
        fill: _explanadaFill,
        label: 'Explanada',
        labelColor: _mutedLabel,
        fontSize: 13);

    // Auditorio (izquierda fila media)
    _zone(canvas,
        rect: const Rect.fromLTWH(28, 152, 90, 148),
        fill: _specialFill,
        label: 'Auditorio',
        labelColor: _mutedLabel,
        fontSize: 10);

    // Área de estudio (izquierda fila baja)
    _zone(canvas,
        rect: const Rect.fromLTWH(28, 318, 145, 105),
        fill: _grassFill,
        label: 'Área de\nestudio',
        labelColor: _mutedLabel,
        fontSize: 9);

    // Área deportiva izquierda (abajo izq)
    _zone(canvas,
        rect: const Rect.fromLTWH(28, 380, 100, 70), // comparte con estudio
        fill: _grassFill,
        label: '',
        labelColor: _mutedLabel,
        fontSize: 9);

    // Barra de café
    _zone(canvas,
        rect: const Rect.fromLTWH(182, 398, 72, 52),
        fill: _coffeeFill,
        label: 'Barra\nde Café',
        labelColor: _mutedLabel,
        fontSize: 8);

    // Área deportiva derecha (fila media-baja derecha)
    _zone(canvas,
        rect: const Rect.fromLTWH(648, 318, 122, 105),
        fill: _grassFill,
        label: 'Área\nDeportiva',
        labelColor: _mutedLabel,
        fontSize: 9);

    // Cafetería (abajo derecha)
    _zone(canvas,
        rect: const Rect.fromLTWH(648, 398, 122, 52),
        fill: _coffeeFill,
        label: 'Cafetería',
        labelColor: _mutedLabel,
        fontSize: 9);
  }

  // ── Edificios ────────────────────────────────────────────────────
  void _drawBuildings(Canvas canvas) {
    for (final e in _buildingRects().entries) {
      _building(canvas, e.key, e.value, _isSelected(e.key));
    }
  }

  // Layout basado en el mapa oficial:
  //
  //  [  E/S  ]
  //  [ Edif2 ][       ][ Edif4 ][       ]
  //  [  Aud  ][ EdGob ][ Expl  ][ EdLab ][ Edif5 ]
  //  [       ][       ][ Edif1 ][ Edif3 ][       ]
  //
  Map<String, Rect> _buildingRects() => {
        // ── Fila superior ──────────────────────────────────────────
        '2': const Rect.fromLTWH(222, 34, 168, 110),
        '4': const Rect.fromLTWH(432, 34, 168, 110),

        // ── Fila media ─────────────────────────────────────────────
        'Gob': const Rect.fromLTWH(126, 152, 88, 148),
        'Lab': const Rect.fromLTWH(418, 152, 188, 148),
        '5': const Rect.fromLTWH(618, 34, 152, 266),

        // ── Fila inferior ──────────────────────────────────────────
        '1': const Rect.fromLTWH(222, 310, 168, 110),
        '3': const Rect.fromLTWH(418, 310, 168, 110),
      };

  bool _isSelected(String key) {
    if (selectedEdificio == key) return true;
    final lo = selectedEdificio.toLowerCase();
    if (key == 'Lab' && lo.contains('lab')) return true;
    if (key == 'Gob' && (lo.contains('gob') || lo.contains('gobierno')))
      return true;
    final n = RegExp(r'\d+').firstMatch(selectedEdificio)?.group(0);
    return n != null && key == n;
  }

  void _building(Canvas canvas, String key, Rect rect, bool selected) {
    // Sombra
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          rect.translate(2, 3), const Radius.circular(_rad)),
      Paint()
        ..color = Colors.black.withValues(alpha: isDark ? 0.35 : 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // Cuerpo
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(_rad)),
      Paint()..color = selected ? _buildingSel : _buildingFill,
    );

    // Borde
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(_rad)),
      Paint()
        ..color = selected
            ? (isDark ? AppColors.darkBlueMid : AppColors.blueLight)
            : _buildingBorder
        ..strokeWidth = selected ? 2.5 : 1.2
        ..style = PaintingStyle.stroke,
    );

    // Ventanas cuando no está seleccionado
    if (!selected) _windows(canvas, rect);

    // Texto
    _text(
      canvas,
      label: _buildingLabel(key),
      center: rect.center,
      color: selected ? _labelSel : _labelColor,
      size: (key == 'Lab' || key == 'Gob') ? 9.5 : 11.0,
      bold: selected,
      maxW: rect.width - 10,
    );
  }

  String _buildingLabel(String k) {
    switch (k) {
      case 'Lab':
        return 'Edificio de\nLaboratorios';
      case 'Gob':
        return 'Edificio de\nGobierno';
      default:
        return 'Edificio $k';
    }
  }

  void _windows(Canvas canvas, Rect rect) {
    final p = Paint()
      ..color = isDark
          ? const Color(0xFF2A4A6A)
          : const Color(0xFFDDEEFF).withValues(alpha: 0.8);
    const wW = 6.0, wH = 4.5, padX = 10.0, padY = 12.0, gap = 5.0;
    double x = rect.left + padX;
    while (x + wW < rect.right - padX / 2) {
      double y = rect.top + padY;
      while (y + wH < rect.bottom - padY / 2) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(x, y, wW, wH), const Radius.circular(1)),
          p,
        );
        y += wH + gap;
      }
      x += wW + gap;
    }
  }

  // ── Tags "Salones XYZ" ───────────────────────────────────────────
  void _drawSalonTags(Canvas canvas) {
    // Edificio 2 → Salones 2XYZ (debajo)
    _salonTag(canvas, label: 'Salones 2XYZ', cx: 306, cy: 150);
    // Edificio 4 → Salones 2XYZ (debajo)
    _salonTag(canvas, label: 'Salones 2XYZ', cx: 516, cy: 150);
    // Edificio 5 → Salones 4XYZ (derecha, arriba)
    _salonTag(canvas, label: 'Salones 4XYZ', cx: 694, cy: 148);
    // Edificio 5 → Salones 3XYZ (derecha, abajo)
    _salonTag(canvas, label: 'Salones 3XYZ', cx: 694, cy: 306);
    // Edificio 1 → Salones 1XYZ (debajo)
    _salonTag(canvas, label: 'Salones 1XYZ', cx: 306, cy: 426);
    // Edificio 3 → Salones 1XYZ (debajo)
    _salonTag(canvas, label: 'Salones 1XYZ', cx: 502, cy: 426);
  }

  void _salonTag(Canvas canvas,
      {required String label, required double cx, required double cy}) {
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 7.5,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();

    const padH = 6.0, padV = 3.0;
    final w = tp.width + padH * 2;
    final h = tp.height + padV * 2;
    final rect = Rect.fromCenter(center: Offset(cx, cy), width: w, height: h);

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(3)),
      Paint()..color = _salonTagBg,
    );
    tp.paint(canvas, Offset(rect.left + padH, rect.top + padV));
  }

  // ── Entrada / salida ─────────────────────────────────────────────
  void _drawEntrance(Canvas canvas) {
    const cx = 345.0, cy = 28.0;
    final rr = RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(cx, cy), width: 46, height: 22),
      const Radius.circular(5),
    );
    canvas.drawRRect(rr, Paint()..color = _entranceBg);

    _text(
      canvas,
      label: 'E/S',
      center: const Offset(cx, cy),
      color: Colors.white,
      size: 9.5,
      bold: true,
      maxW: 46,
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────
  void _zone(
    Canvas canvas, {
    required Rect rect,
    required Color fill,
    required String label,
    required Color labelColor,
    double fontSize = 10,
  }) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(5)),
      Paint()..color = fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(5)),
      Paint()
        ..color = _buildingBorder.withValues(alpha: 0.4)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke,
    );
    if (label.isNotEmpty) {
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
  }

  void _text(
    Canvas canvas, {
    required String label,
    required Offset center,
    required Color color,
    required double size,
    required bool bold,
    double maxW = 100,
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

  @override
  bool shouldRepaint(CampusMapPainter old) =>
      old.selectedEdificio != selectedEdificio || old.isDark != isDark;
}
