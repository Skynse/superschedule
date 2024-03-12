import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:superschedule/models/group.dart';

import 'package:superschedule/pages/createEvent.dart';
import 'package:superschedule/services/firebase_service.dart';
import 'package:intl/intl.dart' as intl;

class CreateEventForm extends ConsumerStatefulWidget {
  CreateEventForm({Key? key, this.group}) : super(key: key);
  Group? group;

  @override
  ConsumerState<CreateEventForm> createState() => _CreateEventFormState();
}

class _CreateEventFormState extends ConsumerState<CreateEventForm> {
  final _formKey = GlobalKey<FormState>();
  final _eventTitleController = TextEditingController();
  DateTime? _eventDate;
  TimeOfDay? _eventStartTime;
  TimeOfDay? _eventEndTime;

  bool isAfter(TimeOfDay? date1, TimeOfDay? date2) {
    if (date1 == null || date2 == null) {
      return false;
    }
    final time1 = DateTime(0, 0, 0, date1.hour, date1.minute);
    final time2 = DateTime(0, 0, 0, date2.hour, date2.minute);
    return time1.isAfter(time2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _eventTitleController,
                decoration: const InputDecoration(labelText: 'Event Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (selectedDate != null) {
                    setState(() {
                      _eventDate = selectedDate;
                    });
                  }
                },
                child: const Text('Select Event Date'),
              ),
              const SizedBox(height: 16.0),
              if (_eventDate != null)
                ElevatedButton(
                  onPressed: () async {
                    final selectedStartTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (selectedStartTime != null) {
                      setState(() {
                        _eventStartTime = selectedStartTime;
                      });
                    }
                  },
                  child: const Text('Select Event Start Time'),
                ),
              if (_eventStartTime != null)
                ElevatedButton(
                  onPressed: () async {
                    final selectedEndTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (selectedEndTime != null) {
                      setState(() {
                        _eventEndTime = selectedEndTime;
                      });
                    }
                  },
                  child: const Text('Select Event End Time'),
                ),
              if (_eventDate != null &&
                  _eventStartTime != null &&
                  _eventEndTime != null)
                Text(
                    'Event Date: ${intl.DateFormat('yyyy-MM-dd').format(_eventDate!)}'),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() &&
                      _eventDate != null &&
                      _eventStartTime != null &&
                      _eventEndTime != null &&
                      isAfter(_eventEndTime, _eventStartTime)) {
                    ref.read(firebaseServiceProvider).createEvent(
                          _eventTitleController.text,
                          DateTime(
                            _eventDate!.year,
                            _eventDate!.month,
                            _eventDate!.day,
                          ),
                          DateTime(
                            _eventDate!.year,
                            _eventDate!.month,
                            _eventDate!.day,
                            _eventStartTime!.hour,
                            _eventStartTime!.minute,
                          ),
                          DateTime(
                            _eventDate!.year,
                            _eventDate!.month,
                            _eventDate!.day,
                            _eventEndTime!.hour,
                            _eventEndTime!.minute,
                          ),
                          widget.group?.id,
                        );
                    Navigator.of(context).pop();
                  }
                },
                child: isAfter(_eventEndTime, _eventStartTime)
                    ? const Text('Create Event')
                    : const Text('Invalid Time'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
