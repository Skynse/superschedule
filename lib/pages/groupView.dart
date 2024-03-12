import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:superschedule/models/group.dart';
import 'package:superschedule/pages/createEvent.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class GroupView extends StatefulWidget {
  const GroupView({Key? key, required this.group}) : super(key: key);
  final Group group;

  @override
  _GroupViewState createState() => _GroupViewState();
}

class _GroupViewState extends State<GroupView> {
  Future<List<Appointment>> _getAllGroupMemberAvailabilities() async {
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
        var startTime = data['startTime'].toDate();
        var endTime = data['endTime'].toDate();

        appointments.add(Appointment(
          startTime: startTime,
          endTime: endTime,
          subject: memberDoc['display_name'],
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

            return SfCalendar(
              view: CalendarView.month,
              dataSource: AvailabilityDataSource(snapshot.data!),
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

  Future<void> addMemberToGroup(String email) async {
    var user = FirebaseAuth.instance.currentUser;

    var userDoc = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (userDoc.docs.isNotEmpty) {
      var userId = userDoc.docs.first.id;

      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.group.id)
          .update({
        'members': FieldValue.arrayUnion([userId])
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an email';
              }
              return null;
            },
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // add member to group
                Navigator.pop(context);
              }
            },
            child: const Text('Add Member'),
          ),
        ],
      ),
    );
  }
}
