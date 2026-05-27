import '../models/exam_model.dart';

abstract class SearchLocalDataSource {
  Future<List<ExamModel>> getExams({
    String? carrera,
    int? semestre,
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
      fecha: DateTime(2026, 6, 10),
      turno: 'Matutino',
      salon: 'A-101',
      profesor: 'Dr. García López',
    ),
    ExamModel(
      id: '2',
      materia: 'Álgebra Lineal',
      carrera: 'ISC',
      semestre: 2,
      fecha: DateTime(2026, 6, 11),
      turno: 'Vespertino',
      salon: 'B-205',
      profesor: 'Mtra. Ramírez Torres',
    ),
    ExamModel(
      id: '3',
      materia: 'Programación Orientada a Objetos',
      carrera: 'ISC',
      semestre: 3,
      fecha: DateTime(2026, 6, 12),
      turno: 'Matutino',
      salon: 'C-310',
      profesor: 'Ing. Hernández Cruz',
    ),
    ExamModel(
      id: '4',
      materia: 'Estructuras de Datos',
      carrera: 'ISC',
      semestre: 4,
      fecha: DateTime(2026, 6, 13),
      turno: 'Matutino',
      salon: 'A-102',
      profesor: 'Dr. Martínez Ruiz',
    ),
    ExamModel(
      id: '5',
      materia: 'Bases de Datos',
      carrera: 'LCD',
      semestre: 3,
      fecha: DateTime(2026, 6, 14),
      turno: 'Vespertino',
      salon: 'D-401',
      profesor: 'Mtra. López Sánchez',
    ),
    ExamModel(
      id: '6',
      materia: 'Redes de Computadoras',
      carrera: 'ISC',
      semestre: 5,
      fecha: DateTime(2026, 6, 15),
      turno: 'Matutino',
      salon: 'B-210',
      profesor: 'Dr. Pérez Mendoza',
    ),
    ExamModel(
      id: '7',
      materia: 'Inteligencia Artificial',
      carrera: 'LCD',
      semestre: 5,
      fecha: DateTime(2026, 6, 16),
      turno: 'Vespertino',
      salon: 'C-315',
      profesor: 'Dr. Flores Vega',
    ),
    ExamModel(
      id: '8',
      materia: 'Sistemas Operativos',
      carrera: 'ISC',
      semestre: 5,
      fecha: DateTime(2026, 6, 17),
      turno: 'Matutino',
      salon: 'A-105',
      profesor: 'Ing. Castro Díaz',
    ),
    ExamModel(
      id: '9',
      materia: 'Cálculo Integral',
      carrera: 'ISC',
      semestre: 2,
      fecha: DateTime(2026, 6, 18),
      turno: 'Vespertino',
      salon: 'B-201',
      profesor: 'Mtra. Morales Reyes',
    ),
    ExamModel(
      id: '10',
      materia: 'Estadística',
      carrera: 'LCD',
      semestre: 4,
      fecha: DateTime(2026, 6, 19),
      turno: 'Matutino',
      salon: 'D-405',
      profesor: 'Dr. Gutiérrez Ávila',
    ),
  ];

  @override
  Future<List<ExamModel>> getExams({
    String? carrera,
    int? semestre,
    String? materia,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    return _mockExams.where((exam) {
      final matchCarrera = carrera == null || exam.carrera == carrera;
      final matchSemestre = semestre == null || exam.semestre == semestre;
      final matchMateria = materia == null ||
          exam.materia.toLowerCase().contains(materia.toLowerCase());
      return matchCarrera && matchSemestre && matchMateria;
    }).toList();
  }

  @override
  Future<List<String>> getCarreras() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockExams.map((e) => e.carrera).toSet().toList()..sort();
  }
}
