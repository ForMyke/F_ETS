import 'package:etsAndroid/features/exams/data/models/exam_admin_model.dart';
import 'package:etsAndroid/features/exams/domain/entities/exam_admin.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Nested JSON structure matching ExamListItemModel.fromJson expectations.
  final tJson = <String, dynamic>{
    'id_ets': 'ets-001',
    'fechahorainicio': '2026-06-12T09:00:00.000',
    'fechahorafin': '2026-06-12T11:00:00.000',
    'turno': 'Matutino',
    'estado': 'activo',
    'id_periodoets': 'P1-2026',
    'id_salon': 'salon-1',
    'id_carrera_materia': 'cm-1',
    'id_jefeacademia': 'jefe-1',
    'salon': {
      'codigo': 'A1',
      'edificio': {'numero': '3'},
    },
    'carrera_materia': {
      'id_carrera': 'car-1',
      'id_plan': 'plan-1',
      'semestre': 4,
      'materia': {'nombre': 'Cálculo Diferencial'},
      'carrera': {'acronimo': 'ISC'},
    },
    'jefeacademia': {
      'usuario': {
        'nombre': 'Juan',
        'apellidopaterno': 'López',
        'apellidomaterno': 'Pérez',
      },
    },
  };

  final tModel = ExamListItemModel(
    id: 'ets-001',
    materia: 'Cálculo Diferencial',
    carrera: 'ISC',
    salon: 'A1',
    salonId: 'salon-1',
    edificio: '3',
    turno: 'Matutino',
    fechaInicio: DateTime.parse('2026-06-12T09:00:00.000'),
    fechaFin: DateTime.parse('2026-06-12T11:00:00.000'),
    estado: 'activo',
    periodo: 'P1-2026',
    profesor: 'Juan López Pérez',
    jefeId: 'jefe-1',
    carreraMateriaId: 'cm-1',
    carreraId: 'car-1',
    planId: 'plan-1',
    semestre: 4,
  );

  group('ExamListItemModel', () {
    group('fromJson', () {
      test('parses id correctly', () {
        final model = ExamListItemModel.fromJson(tJson);
        expect(model.id, 'ets-001');
      });

      test('parses materia from nested carrera_materia.materia.nombre', () {
        final model = ExamListItemModel.fromJson(tJson);
        expect(model.materia, 'Cálculo Diferencial');
      });

      test('parses carrera from nested carrera_materia.carrera.acronimo', () {
        final model = ExamListItemModel.fromJson(tJson);
        expect(model.carrera, 'ISC');
      });

      test('parses salon from nested salon.codigo', () {
        final model = ExamListItemModel.fromJson(tJson);
        expect(model.salon, 'A1');
      });

      test('parses edificio from nested salon.edificio.numero', () {
        final model = ExamListItemModel.fromJson(tJson);
        expect(model.edificio, '3');
      });

      test('parses profesor as full name from jefeacademia.usuario', () {
        final model = ExamListItemModel.fromJson(tJson);
        expect(model.profesor, 'Juan López Pérez');
      });

      test('parses fechaInicio as DateTime', () {
        final model = ExamListItemModel.fromJson(tJson);
        expect(model.fechaInicio, DateTime.parse('2026-06-12T09:00:00.000'));
      });

      test('parses fechaFin as DateTime', () {
        final model = ExamListItemModel.fromJson(tJson);
        expect(model.fechaFin, DateTime.parse('2026-06-12T11:00:00.000'));
      });

      test('parses semestre as int', () {
        final model = ExamListItemModel.fromJson(tJson);
        expect(model.semestre, 4);
      });

      test('model is a subtype of ExamListItem entity', () {
        final model = ExamListItemModel.fromJson(tJson);
        expect(model, isA<ExamListItem>());
      });

      test('uses empty string when turno is null', () {
        final jsonNoTurno = Map<String, dynamic>.from(tJson)
          ..remove('turno');
        final model = ExamListItemModel.fromJson(jsonNoTurno);
        expect(model.turno, '');
      });
    });

    group('toJson', () {
      test('serialises id correctly', () {
        final json = tModel.toJson();
        expect(json['id_ets'], 'ets-001');
      });

      test('serialises fechahorainicio as ISO-8601 string', () {
        final json = tModel.toJson();
        expect(
          json['fechahorainicio'],
          DateTime.parse('2026-06-12T09:00:00.000').toIso8601String(),
        );
      });

      test('serialises fechahorafin as ISO-8601 string', () {
        final json = tModel.toJson();
        expect(
          json['fechahorafin'],
          DateTime.parse('2026-06-12T11:00:00.000').toIso8601String(),
        );
      });

      test('serialises turno', () {
        final json = tModel.toJson();
        expect(json['turno'], 'Matutino');
      });

      test('serialises estado', () {
        final json = tModel.toJson();
        expect(json['estado'], 'activo');
      });

      test('serialises flat keys expected by the API', () {
        final json = tModel.toJson();
        expect(json.containsKey('id_salon'), isTrue);
        expect(json.containsKey('id_carrera_materia'), isTrue);
        expect(json.containsKey('id_jefeacademia'), isTrue);
        expect(json.containsKey('id_periodoets'), isTrue);
      });

      test('round-trip: fromJson -> toJson preserves core fields', () {
        final model = ExamListItemModel.fromJson(tJson);
        final json = model.toJson();
        expect(json['id_ets'], tJson['id_ets']);
        expect(json['turno'], tJson['turno']);
        expect(json['estado'], tJson['estado']);
        expect(json['id_salon'], tJson['id_salon']);
      });
    });
  });
}
