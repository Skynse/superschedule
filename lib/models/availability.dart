import 'package:syncfusion_flutter_calendar/calendar.dart';

class Availability {
  int weekDay;
  DateTime startTime;
  DateTime endTime;
  String title;
  String? id;
  RecurrenceProperties? recurrenceRule;

  Availability(
      {required this.weekDay,
      required this.startTime,
      required this.endTime,
      required this.title});

  Availability.fromMap(Map<String, dynamic> data, String id)
      : weekDay = data['week_day'],
        startTime = data['start_time'].toDate(),
        endTime = data['end_time'].toDate(),
        title = data['title'],
        id = id;

  Map<String, dynamic> toMap() {
    return {
      'week_day': weekDay,
      'start_time': startTime,
      'end_time': endTime,
      'title': title,
    };
  }
}

DateTime getWeekDayFromStartTime(DateTime startTime, int weekDay) {
  // clamp to this week
  var now = DateTime.now();
  var startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  var endOfWeek = now.add(Duration(days: DateTime.saturday - now.weekday));
  var day = startOfWeek.add(Duration(days: weekDay - 1));
  return DateTime(
      day.year, day.month, day.day, startTime.hour, startTime.minute);
}

DateTime getWeekDayFromEndTime(DateTime endTime, int weekDay) {
  // clamp to this week
  var now = DateTime.now();
  var startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  var endOfWeek = now.add(Duration(days: DateTime.saturday - now.weekday));
  var day = startOfWeek.add(Duration(days: weekDay - 1));
  return DateTime(day.year, day.month, day.day, endTime.hour, endTime.minute);
}
