import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:scheduleup/models/availability.dart';
import 'package:intl/intl.dart';
import 'package:weekday_selector/weekday_selector.dart';

class AvailabilityDataSource extends CalendarDataSource {
  AvailabilityDataSource(List<Appointment> source) {
    appointments = source;
  }
}

class AvailabilityPage extends StatefulWidget {
  final String uid;
  const AvailabilityPage({super.key, required this.uid});

  @override
  State<AvailabilityPage> createState() => _AvailabilityPageState();
}

class _AvailabilityPageState extends State<AvailabilityPage> {
  Stream<List<Availability>> _getAvailability() async* {
    var user = FirebaseAuth.instance.currentUser;
    var availability = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .collection('availabilities')
        .get();

    yield availability.docs
        .map((e) => Availability.fromMap(e.data(), e.id))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    RecurrenceProperties recurrence =
        RecurrenceProperties(startDate: DateTime.now());
    recurrence.recurrenceType = RecurrenceType.weekly;
    recurrence.interval = 2;
    recurrence.weekDays = <WeekDays>[
      WeekDays.sunday,
      WeekDays.monday,
      WeekDays.tuesday,
      WeekDays.wednesday,
      WeekDays.thursday,
      WeekDays.friday,
      WeekDays.saturday
    ];
    recurrence.recurrenceRange = RecurrenceRange.count;
    recurrence.recurrenceCount = 10;
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CreateAvailabilityForm()),
            );
          },
        ),
        appBar: AppBar(
          title: Text("My Availability"),
        ),
        body: StreamBuilder<List<Availability>>(
            stream: _getAvailability(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No availability found'));
              }

              List<Appointment> appointments = snapshot.data!
                  // since this is availablilty, limit to this week
                  .map((e) => Appointment(
                        startTime:
                            getWeekDayFromStartTime(e.startTime, e.weekDay),
                        endTime: getWeekDayFromEndTime(e.endTime, e.weekDay),
                        subject: e.title,
                      ))
                  .toList();

              return SfCalendar(
                view: CalendarView.week,
                // show only last sunday to next saturday inclusive
                minDate: DateTime.now()
                    .subtract(Duration(days: DateTime.now().weekday)),
                maxDate: DateTime.now().add(
                    Duration(days: DateTime.saturday - DateTime.now().weekday)),

                dataSource: AvailabilityDataSource(appointments),
                appointmentBuilder: (context, details) {
                  return InkWell(
                    onLongPress: () async {
                      bool confirmDelete = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Confirmation'),
                            content: Text(
                                'Are you sure you want to delete this availability?'),
                            actions: [
                              TextButton(
                                child: Text('Cancel'),
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                },
                              ),
                              TextButton(
                                child: Text('Delete'),
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                              ),
                            ],
                          );
                        },
                      );

                      if (confirmDelete == true) {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(widget.uid)
                            .collection('availabilities')
                            .doc(snapshot.data!
                                .firstWhere(
                                  (element) =>
                                      element.title ==
                                      details.appointments.first.subject,
                                  orElse: () => Availability(
                                    title: '',
                                    startTime: DateTime.now(),
                                    endTime: DateTime.now(),
                                    weekDay: 0,
                                  ),
                                )
                                .id)
                            .delete();

                        setState(() {});
                      }
                    },
                    child: Container(
                      color: Colors.blue,
                      child: Column(
                        children: [
                          Text(details.appointments.first.subject),
                          Text(DateFormat('h:mm a')
                              .format(details.appointments.first.startTime)),
                          Text(DateFormat('h:mm a')
                              .format(details.appointments.first.endTime)),
                        ],
                      ),
                    ),
                  );
                },
              );
            }));
  }
}

class CreateAvailabilityForm extends StatefulWidget {
  const CreateAvailabilityForm({super.key});

  @override
  State<CreateAvailabilityForm> createState() => _CreateAvailabilityFormState();
}

class _CreateAvailabilityFormState extends State<CreateAvailabilityForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now();
  // use binary to store the selected days
  List<bool> values = List.filled(7, false);
  int weekDay = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Availability'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              WeekdaySelector(
                weekdays: ['S', 'M', 'T', 'W', 'T', 'F', 'S'],
                selectedFillColor: Colors.blue,
                values: values,
                onChanged: (int day) {
                  //  toggle only one day
                  setState(() {
                    for (int i = 0; i < 7; i++) {
                      if (i == day) {
                        values[i] = !values[i];
                      } else {
                        values[i] = false;
                      }
                    }
                    weekDay = day;
                  });
                },
              ),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  final selectedStartTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (selectedStartTime != null) {
                    setState(() {
                      _startTime = DateTime(
                        _startTime.year,
                        _startTime.month,
                        _startTime.day,
                        selectedStartTime.hour,
                        selectedStartTime.minute,
                      );
                    });
                  }
                },
                child: const Text('Select Start Time'),
              ),
              _startTime == DateTime.now()
                  ? Text('No start time selected')
                  : Text(
                      'Selected start time: ${DateFormat('HH:mm').format(_startTime)}'),
              ElevatedButton(
                onPressed: () async {
                  final selectedEndTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (selectedEndTime != null) {
                    setState(() {
                      _endTime = DateTime(
                        _endTime.year,
                        _endTime.month,
                        _endTime.day,
                        selectedEndTime.hour,
                        selectedEndTime.minute,
                      );
                    });
                  }
                },
                child: const Text('Select End Time'),
              ),
              _endTime == DateTime.now()
                  ? Text('No end time selected')
                  : Text(
                      'Selected end time: ${DateFormat('HH:mm').format(_endTime)}'),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate() &&
                      weekDay != 0 &&
                      _titleController.text.isNotEmpty) {
                    var user = FirebaseAuth.instance.currentUser;
                    var availability = Availability(
                      weekDay: weekDay,
                      title: _titleController.text,
                      startTime: _startTime,
                      endTime: _endTime,
                    );

                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user!.uid)
                        .collection('availabilities')
                        .add(availability.toMap());

                    if (!mounted) return;
                    // pop until at settings page
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                },
                child: Text('Create Availability'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
