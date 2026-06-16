import 'calendar_event_data.dart';

Future<CalendarAddResult> addEventsToDeviceCalendar(
    List<CalendarEventData> events) async {
  return const CalendarAddResult(
      false, 'No soportado en esta plataforma.');
}
