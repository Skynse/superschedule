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
