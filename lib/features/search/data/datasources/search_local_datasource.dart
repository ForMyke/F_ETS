import '../models/exam_model.dart';

abstract class SearchLocalDataSource {
  Future<List<ExamModel>> getExams({
    String? carrera,
    int? semestre,
    int? plan,
    String? materia,
  });

  Future<List<String>> getCarreras();
}

class SearchLocalDataSourceImpl implements SearchLocalDataSource {
  static final List<ExamModel> _mockExams = [
    ExamModel(
        id: '1',
        materia: 'Cálculo Diferencial',
        carrera: 'ISC',
        semestre: 1,
        plan: 2020,
        fecha: DateTime(2026, 6, 10),
        turno: 'Matutino',
        salon: '1001',
        profesor: 'Dr. García López'),
    ExamModel(
        id: '2',
        materia: 'Álgebra Lineal',
        carrera: 'ISC',
        semestre: 2,
        plan: 2020,
        fecha: DateTime(2026, 6, 11),
        turno: 'Vespertino',
        salon: '2114',
        profesor: 'Mtra. Ramírez Torres'),
    ExamModel(
        id: '3',
        materia: 'Programación Orientada a Objetos',
        carrera: 'ISC',
        semestre: 3,
        plan: 2020,
        fecha: DateTime(2026, 6, 12),
        turno: 'Matutino',
        salon: '3208',
        profesor: 'Ing. Hernández Cruz'),
    ExamModel(
        id: '4',
        materia: 'Estructuras de Datos',
        carrera: 'ISC',
        semestre: 4,
        plan: 2020,
        fecha: DateTime(2026, 6, 13),
        turno: 'Matutino',
        salon: '1102',
        profesor: 'Dr. Martínez Ruiz'),
    ExamModel(
        id: '5',
        materia: 'Bases de Datos',
        carrera: 'LCD',
        semestre: 3,
        plan: 2020,
        fecha: DateTime(2026, 6, 14),
        turno: 'Vespertino',
        salon: '4201',
        profesor: 'Mtra. López Sánchez'),
    ExamModel(
        id: '6',
        materia: 'Redes de Computadoras',
        carrera: 'ISC',
        semestre: 5,
        plan: 2009,
        fecha: DateTime(2026, 6, 15),
        turno: 'Matutino',
        salon: '2010',
        profesor: 'Dr. Pérez Mendoza'),
    ExamModel(
        id: '7',
        materia: 'Inteligencia Artificial',
        carrera: 'LCD',
        semestre: 5,
        plan: 2020,
        fecha: DateTime(2026, 6, 16),
        turno: 'Vespertino',
        salon: '3114',
        profesor: 'Dr. Flores Vega'),
    ExamModel(
        id: '8',
        materia: 'Sistemas Operativos',
        carrera: 'ISC',
        semestre: 5,
        plan: 2009,
        fecha: DateTime(2026, 6, 17),
        turno: 'Matutino',
        salon: '1205',
        profesor: 'Ing. Castro Díaz'),
    ExamModel(
        id: '9',
        materia: 'Cálculo Integral',
        carrera: 'ISC',
        semestre: 2,
        plan: 2009,
        fecha: DateTime(2026, 6, 18),
        turno: 'Vespertino',
        salon: '4001',
        profesor: 'Mtra. Morales Reyes'),
    ExamModel(
        id: '10',
        materia: 'Estadística',
        carrera: 'LCD',
        semestre: 4,
        plan: 2020,
        fecha: DateTime(2026, 6, 19),
        turno: 'Matutino',
        salon: '2213',
        profesor: 'Dr. Gutiérrez Ávila'),
    ExamModel(
        id: '11',
        materia: 'Investigación de Operaciones',
        carrera: 'IIA',
        semestre: 5,
        plan: 2020,
        fecha: DateTime(2026, 6, 20),
        turno: 'Matutino',
        salon: '3101',
        profesor: 'Dr. Reyes Montes'),
    ExamModel(
        id: '12',
        materia: 'Simulación',
        carrera: 'IIA',
        semestre: 6,
        plan: 2020,
        fecha: DateTime(2026, 6, 21),
        turno: 'Vespertino',
        salon: '1204',
        profesor: 'Mtra. Vargas Díaz'),
  ];

  @override
  Future<List<ExamModel>> getExams({
    String? carrera,
    int? semestre,
    int? plan,
    String? materia,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    return _mockExams.where((exam) {
      final matchCarrera = carrera == null || exam.carrera == carrera;
      final matchSemestre = semestre == null || exam.semestre == semestre;
      final matchPlan = plan == null || exam.plan == plan;
      final matchMateria = materia == null ||
          exam.materia.toLowerCase().contains(materia.toLowerCase());
      return matchCarrera && matchSemestre && matchPlan && matchMateria;
    }).toList();
  }

  @override
  Future<List<String>> getCarreras() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockExams.map((e) => e.carrera).toSet().toList()..sort();
  }
}
