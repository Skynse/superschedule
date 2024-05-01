import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scheduleup/models/availability.dart';
import 'package:scheduleup/models/group.dart';
import 'package:scheduleup/pages/createEvent.dart';
import 'package:scheduleup/services/firebase_service.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class GroupView extends StatefulWidget {
  const GroupView({Key? key, required this.group}) : super(key: key);
  final Group group;

  @override
  _GroupViewState createState() => _GroupViewState();
}

class _GroupViewState extends State<GroupView> {
  Future<List<Appointment>?> _getAllGroupMemberAvailabilities() async {
    var group = widget.group;

    var appointments = <Appointment>[];

    for (var member in group.members) {
      var memberDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(member)
          .get();

      var availability = await FirebaseFirestore.instance
          .collection('users')
          .doc(member)
          .collection('availabilities')
          .get();

      for (var element in availability.docs) {
        var data = element.data();
        var startTime = data['start_time'].toDate();
        var endTime = data['end_time'].toDate();
        var weekday = data['week_day'];

        print(startTime);

        appointments.add(Appointment(
          startTime: getWeekDayFromStartTime(startTime, weekday),
          endTime: getWeekDayFromEndTime(endTime, weekday),
          subject: memberDoc['email'],
          color: Colors.green,
        ));
      }
    }

    return appointments;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
              context: context,
              builder: (context) {
                return CreateEventForm(group: widget.group);
              });
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Text(widget.group.groupName),
        actions: [
          widget.group.ownerId == FirebaseAuth.instance.currentUser!.uid
              ? IconButton(
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('groups')
                        .doc(widget.group.id)
                        .delete();

                    // delete events associated with the group

                    await FirebaseFirestore.instance
                        .collection('events')
                        .where('group', isEqualTo: widget.group.id);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.delete))
              : const SizedBox(),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              // navigate to add member page
              showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return AddMemberForm(group: widget.group);
                  });
            },
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder(
          future: _getAllGroupMemberAvailabilities(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No group availabilities found'));
            }

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

            return SfCalendar(
              view: CalendarView.week,
              dataSource: AvailabilityDataSource(snapshot.data!),
              weekNumberStyle: WeekNumberStyle(
                backgroundColor: Colors.blue,
                textStyle: TextStyle(color: Colors.white),
              ),
              monthViewSettings: const MonthViewSettings(
                  appointmentDisplayMode:
                      MonthAppointmentDisplayMode.appointment),
            );
          },
        ),
      ),
    );
  }
}

class AvailabilityDataSource extends CalendarDataSource {
  AvailabilityDataSource(List<Appointment> source) {
    appointments = source;
  }
}

// add member form
// if email exists, add to group

class AddMemberForm extends StatefulWidget {
  AddMemberForm({required this.group});
  Group group;

  @override
  _AddMemberFormState createState() => _AddMemberFormState();
}

class _AddMemberFormState extends State<AddMemberForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  Future<void> addMemberToGroup(String id) async {
    var user = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.group.id)
        .update({
      'members': FieldValue.arrayUnion([id])
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: StreamBuilder(
      stream: FirebaseService().getFriends(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No friends found'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            var friend = snapshot.data![index];
            return ListTile(
              title: Text(friend.name),
              subtitle: Text(friend.email),
              trailing: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () async {
                  await addMemberToGroup(friend.id);
                  Navigator.pop(context);
                },
              ),
              leading: CircleAvatar(
                backgroundImage: NetworkImage(friend.photoUrl ?? ''),
              ),
            );
          },
        );
      },
    ));
  }
}
