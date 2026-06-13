import 'package:etsAndroid/features/dashboard/data/models/dashboard_stats_model.dart';
import 'package:etsAndroid/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final tJson = <String, dynamic>{
    'totalExams': 12,
    'periodoNombre': 'ETS Junio 2026',
    'examsByCarrera': {'ISC': 6, 'IIA': 4, 'LCD': 2},
    'proximoExamen': '2026-06-12T09:00:00.000',
    'salonesEnUso': 5,
  };

  final tJsonNullProximo = <String, dynamic>{
    'totalExams': 0,
    'periodoNombre': 'Sin periodo',
    'examsByCarrera': <String, int>{},
    'proximoExamen': null,
    'salonesEnUso': 0,
  };

  final tModel = DashboardStatsModel(
    totalExams: 12,
    periodoNombre: 'ETS Junio 2026',
    examsByCarrera: const {'ISC': 6, 'IIA': 4, 'LCD': 2},
    proximoExamen: DateTime.parse('2026-06-12T09:00:00.000'),
    salonesEnUso: 5,
  );

  group('DashboardStatsModel', () {
    group('fromJson', () {
      test('parses totalExams correctly', () {
        final model = DashboardStatsModel.fromJson(tJson);
        expect(model.totalExams, 12);
      });

      test('parses periodoNombre correctly', () {
        final model = DashboardStatsModel.fromJson(tJson);
        expect(model.periodoNombre, 'ETS Junio 2026');
      });

      test('parses examsByCarrera map correctly', () {
        final model = DashboardStatsModel.fromJson(tJson);
        expect(model.examsByCarrera, {'ISC': 6, 'IIA': 4, 'LCD': 2});
      });

      test('parses proximoExamen as DateTime', () {
        final model = DashboardStatsModel.fromJson(tJson);
        expect(model.proximoExamen, DateTime.parse('2026-06-12T09:00:00.000'));
      });

      test('parses null proximoExamen as null', () {
        final model = DashboardStatsModel.fromJson(tJsonNullProximo);
        expect(model.proximoExamen, isNull);
      });

      test('parses salonesEnUso correctly', () {
        final model = DashboardStatsModel.fromJson(tJson);
        expect(model.salonesEnUso, 5);
      });

      test('model is a subtype of DashboardStats entity', () {
        final model = DashboardStatsModel.fromJson(tJson);
        expect(model, isA<DashboardStats>());
      });
    });

    group('toJson', () {
      test('serialises totalExams', () {
        final json = tModel.toJson();
        expect(json['totalExams'], 12);
      });

      test('serialises periodoNombre', () {
        final json = tModel.toJson();
        expect(json['periodoNombre'], 'ETS Junio 2026');
      });

      test('serialises examsByCarrera map', () {
        final json = tModel.toJson();
        expect(json['examsByCarrera'], {'ISC': 6, 'IIA': 4, 'LCD': 2});
      });

      test('serialises proximoExamen as ISO-8601 string', () {
        final json = tModel.toJson();
        expect(
          json['proximoExamen'],
          DateTime.parse('2026-06-12T09:00:00.000').toIso8601String(),
        );
      });

      test('serialises null proximoExamen as null', () {
        final modelNullProximo = DashboardStatsModel(
          totalExams: 0,
          periodoNombre: 'Sin periodo',
          examsByCarrera: const {},
          proximoExamen: null,
          salonesEnUso: 0,
        );
        final json = modelNullProximo.toJson();
        expect(json['proximoExamen'], isNull);
      });

      test('serialises salonesEnUso', () {
        final json = tModel.toJson();
        expect(json['salonesEnUso'], 5);
      });

      test('round-trip: fromJson -> toJson preserves all fields', () {
        final model = DashboardStatsModel.fromJson(tJson);
        final json = model.toJson();

        expect(json['totalExams'], tJson['totalExams']);
        expect(json['periodoNombre'], tJson['periodoNombre']);
        expect(json['examsByCarrera'], tJson['examsByCarrera']);
        expect(json['salonesEnUso'], tJson['salonesEnUso']);
        // proximoExamen is serialised as ISO string
        expect(
          json['proximoExamen'],
          DateTime.parse(tJson['proximoExamen'] as String).toIso8601String(),
        );
      });
    });
  });
}
