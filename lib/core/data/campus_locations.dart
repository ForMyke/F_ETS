import 'dart:ui';

class EdificioLocation {
  final String numeroEdificio;
  final double lat;
  final double lng;
  final String nombre;
  final Offset svgOffset;

  const EdificioLocation({
    required this.numeroEdificio,
    required this.lat,
    required this.lng,
    required this.nombre,
    required this.svgOffset,
  });
}

const Map<String, EdificioLocation> campusLocations = {
  '1': EdificioLocation(
    numeroEdificio: '1',
    nombre: 'Edificio 1 — Salones 1XYZ',
    lat: 19.504350,
    lng: -99.146700,
    svgOffset: Offset(306, 365),
  ),
  '2': EdificioLocation(
    numeroEdificio: '2',
    nombre: 'Edificio 2 — Salones 2XYZ',
    lat: 19.504850,
    lng: -99.146600,
    svgOffset: Offset(306, 89),
  ),
  '3': EdificioLocation(
    numeroEdificio: '3',
    nombre: 'Edificio 3 — Salones 1XYZ',
    lat: 19.504350,
    lng: -99.146300,
    svgOffset: Offset(502, 365),
  ),
  '4': EdificioLocation(
    numeroEdificio: '4',
    nombre: 'Edificio 4 — Salones 2XYZ',
    lat: 19.504850,
    lng: -99.146300,
    svgOffset: Offset(516, 89),
  ),
  '5': EdificioLocation(
    numeroEdificio: '5',
    nombre: 'Edificio 5 — Salones 3XYZ / 4XYZ',
    lat: 19.504550,
    lng: -99.145900,
    svgOffset: Offset(694, 167),
  ),
  'Lab': EdificioLocation(
    numeroEdificio: 'Lab',
    nombre: 'Edificio de Laboratorios',
    lat: 19.504550,
    lng: -99.146300,
    svgOffset: Offset(512, 226),
  ),
  'Gob': EdificioLocation(
    numeroEdificio: 'Gob',
    nombre: 'Edificio de Gobierno',
    lat: 19.504550,
    lng: -99.147000,
    svgOffset: Offset(170, 226),
  ),
};

EdificioLocation? getLocation(String edificio) {
  if (campusLocations.containsKey(edificio)) return campusLocations[edificio];
  final lower = edificio.toLowerCase();
  if (lower.contains('lab')) return campusLocations['Lab'];
  if (lower.contains('gob') || lower.contains('gobierno')) {
    return campusLocations['Gob'];
  }
  final num = RegExp(r'\d+').firstMatch(edificio)?.group(0);
  if (num != null && campusLocations.containsKey(num)) {
    return campusLocations[num];
  }
  return null;
}
