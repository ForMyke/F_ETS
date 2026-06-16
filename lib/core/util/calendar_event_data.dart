class CalendarEventData {
  final String title;
  final String description;
  final String location;
  final DateTime start;
  final DateTime end;

  const CalendarEventData({
    required this.title,
    required this.description,
    required this.location,
    required this.start,
    required this.end,
  });
}

class CalendarAddResult {
  final bool success;
  final String message;

  const CalendarAddResult(this.success, this.message);
}
