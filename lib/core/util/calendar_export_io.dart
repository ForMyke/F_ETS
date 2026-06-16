import 'package:device_calendar/device_calendar.dart' as dc;
import 'package:flutter/material.dart' show Color;
import 'package:timezone/timezone.dart' as tz;

import 'calendar_event_data.dart';

Future<CalendarAddResult> addEventsToDeviceCalendar(
    List<CalendarEventData> events) async {
  final plugin = dc.DeviceCalendarPlugin();

  var perm = await plugin.hasPermissions();
  if (perm.data != true) {
    perm = await plugin.requestPermissions();
  }
  if (perm.data != true) {
    return const CalendarAddResult(
        false, 'Permiso de calendario denegado.');
  }

  final calendarsResult = await plugin.retrieveCalendars();
  final calendars = calendarsResult.data ?? [];

  dc.Calendar? target;
  for (final c in calendars) {
    if (c.isReadOnly != true) {
      target = c;
      break;
    }
  }

  if (target == null) {
    final createResult = await plugin.createCalendar(
      'ETS ESCOM',
      calendarColor: const Color(0xFF1565C0),
      localAccountName: 'ETS ESCOM',
    );
    if (!createResult.isSuccess || createResult.data == null) {
      return const CalendarAddResult(
          false, 'No se pudo crear un calendario en el dispositivo.');
    }
    target = dc.Calendar(id: createResult.data, isReadOnly: false);
  }

  var added = 0;
  for (final e in events) {
    final event = dc.Event(
      target.id,
      title: e.title,
      description: e.description,
      start: tz.TZDateTime.from(e.start, tz.UTC),
      end: tz.TZDateTime.from(e.end, tz.UTC),
      location: e.location,
    );
    final r = await plugin.createOrUpdateEvent(event);
    if (r?.isSuccess == true) added++;
  }

  if (added == 0) {
    return const CalendarAddResult(
        false, 'No se pudo agregar ningún evento al calendario.');
  }
  return CalendarAddResult(
      true,
      added == 1
          ? 'Evento agregado al calendario.'
          : '$added eventos agregados al calendario.');
}
